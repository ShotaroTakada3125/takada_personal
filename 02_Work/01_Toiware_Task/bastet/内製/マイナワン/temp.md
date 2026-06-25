現在の手順書、かなり形になってきましたね！ご自身で気づかれた「新しいUUIDは古いID固定のクエリでは取得できない」という視点、非常に素晴らしいです。

ですが、この手順書のままだと**本番環境でデータが予期せず消滅する致命的なバグ**が1点再発しているほか、手動マッピングを行うための**新しいUUIDを確認する手順**が不足しています。

安全に本番パッチを完遂するために、以下の3点を修正しましょう！

---

## 🔍 重大な指摘事項

### 1. 【超致命的】`delete_mynaone_request.sql` が復活させた正規のデータを削除してしまう

手順書の後半にある以下の記述ですが、ここが元のIDのリスト（`ids_submitted.txt`）を参照してしまっています。

```bash
# ❌ 現在の記述（危険）
cat<<EOF >delete_mynaone_request.sql
delete from mynaone_request where mynaone_id in ($(cat ids_submitted.txt));
EOF

```

ID付け替え（`switch`）を行った後は、**新しいレコードのIDが元のIDに上書きされています**。そのため、この状態で上のDELETE文を実行すると、**せっかくバッチで作成して復元した正規のレコードが物理削除されてしまいます**。

* **対策:** 削除すべきは、用済みとなった **`_del` 付きの退避データ** です。

### 2. 【考慮漏れ】新しいUUIDを確認する手順と、事前バックアップの範囲

ご指摘の通り、バッチが作った新しいレコードは別のUUIDを持っているため、現在の `select_mynaone_request.sql` ではID付け替え前の状態をキャッチできません。

* **対策1:** バッチ実行後に、手動マッピングの書き換え元となる「新しいUUID」を画面やログで確認するための**調査用SQL**を手順に追加します。
* **対策2:** 二次実行前後のバックアップ（`switch_bef` / `switch_aft`）は、新旧どちらのUUIDの状態も漏れなく追跡できるよう、`mynaone_id` ではなく **`account_id`（口座番号）で紐づくレコードを丸ごと引くSQL** に変更します。

### 3. 【記述ミス】コマンドのブロック漏れと環境の混在

* 一部のSQL生成コマンド（`for` ループや `delete` の作成）が Markdown のコードブロックの外側に露出してしまっています。コピペ漏れを防ぐため、前半のシェルスクリプトブロックにすべてまとめましょう。
* バックアップの取得部分で、`../.prod` と `../.stg2` が連続で実行されています。これだと本番のデータがステージングのデータで上書きされてしまうため、本番用（`.prod`）に統一します。

---

## 🛠️ 修正版 本番手順書（手動マッピング・安全対策版）

ご希望の「手動で新しいUUIDを書き換えるスタイル」を維持しつつ、安全性を極限まで高めた完全版です。

```bash
# 作業ディレクトリ移動
mkdir -p ~/report/20260622_datapatch
cd ~/report/20260622_datapatch

# ==========================================
#  データパッチの対象リスト作成
# ==========================================
cat<<EOF >select_target_all.sql
select mynaone_id 
from mynaone_result 
where body like '%氏名／会社名の文字種が不正です。%'
  and update_datetime::date = '2026-06-17';
EOF

cat<<EOF >select_target_not_submitted.sql
select mynaone_id 
from mynaone_result r
where body like '%氏名／会社名の文字種が不正です。%'
  and update_datetime::date = '2026-06-17'
  and exists (
    select 1 
    from mynaone_request req 
    where req.mynaone_id = r.mynaone_id 
      and req.create_url_datetime is not null
  );
EOF

cat<<EOF >select_target_submitted.sql
select mynaone_id 
from mynaone_result r
where body like '%氏名／会社名の文字種が不正です。%'
  and update_datetime::date = '2026-06-17'
  and exists (
    select 1 
    from mynaone_request req 
    where req.mynaone_id = r.mynaone_id 
      and req.create_url_datetime is null
  );
EOF

# 対象抽出クエリ実行（※検証時は必要に応じて .stg2 に変更してください）
../psql-to-csv.sh ../.prod select_target_all.sql
../psql-to-csv.sh ../.prod select_target_not_submitted.sql
../psql-to-csv.sh ../.prod select_target_submitted.sql


# ==========================================
#  抽出したCSVから SQL用の IN句リスト を自動作成
# ==========================================
grep -v -E "^mynaone_id|^$" select_target_all.csv | sed "s/.*/'&'/" | paste -sd, - > ids_all.txt
grep -v -E "^mynaone_id|^$" select_target_not_submitted.csv | sed "s/.*/'&'/" | paste -sd, - > ids_not_submitted.txt
grep -v -E "^mynaone_id|^$" select_target_submitted.csv | sed "s/.*/'&'/" | paste -sd, - > ids_submitted.txt

# 【安全対策】対象者が0件の場合の構文エラー防止
[ ! -s ids_all.txt ] && echo "'NONE'" > ids_all.txt
[ ! -s ids_not_submitted.txt ] && echo "'NONE'" > ids_not_submitted.txt
[ ! -s ids_submitted.txt ] && echo "'NONE'" > ids_submitted.txt


# ==========================================
#  SQLファイルの一括自動生成（一次実行用）
# ==========================================
cat<<EOF >select_mynaone_request.sql
select * from mynaone_request where mynaone_id in ($(cat ids_all.txt));
EOF

cat<<EOF >select_mynaone_result.sql
select * from mynaone_result where mynaone_id in ($(cat ids_all.txt));
EOF

cat<<EOF >update_mynaone_request.sql
update mynaone_request set mynaone_status = 9 where mynaone_id in ($(cat ids_not_submitted.txt));
EOF

cat<<EOF >update_mynaone_result.sql
update mynaone_result set delete_flag = true where mynaone_id in ($(cat ids_all.txt));
EOF

cat<<EOF >update_mynaone_request_for_url.sql
update mynaone_request set delete_flag = true where mynaone_id in ($(cat ids_submitted.txt));
EOF


# ==========================================
#  SQLファイルの一括自動生成（二次実行・調査確認用）
# ==========================================
# 【新設】バッチ実行後、新しくできたUUIDを確認するための調査用SQL
cat<<EOF >check_new_records.sql
select account_id, mynaone_id, update_datetime, delete_flag, register_user 
from mynaone_request 
where account_id in (
  select distinct account_id from mynaone_request where mynaone_id in ($(cat ids_submitted.txt))
)
order by account_id, update_datetime desc;
EOF

# 【新設】新旧のUUIDの状態変化を「アカウント単位」で完全に捕捉・比較するためのクエリ
cat<<EOF >select_mynaone_request_by_account.sql
select * from mynaone_request 
where account_id in (
  select distinct account_id from mynaone_request where mynaone_id in ($(cat ids_submitted.txt))
);
EOF

# ID付け替え用（外側に露出していた部分をブロック内に収納）
> switch_mynaone_id.sql
for id in $(grep -v -E "^mynaone_id|^$" select_target_submitted.csv); do
  cat <<EOF >> switch_mynaone_id.sql
-- 元のレコードのIDの末尾に '_del' をつけて退避
UPDATE mynaone_request SET mynaone_id = '${id}_del' WHERE mynaone_id = '${id}';
-- 目的のレコードのIDを更新
UPDATE mynaone_request SET mynaone_id = '${id}' WHERE mynaone_id = '★ここに新しいUUIDを入力★';

EOF
done

# URL作成日時復元用
> restore_create_url_datetime.sql
for id in $(grep -v -E "^mynaone_id|^$" select_target_submitted.csv); do
  cat <<EOF >> restore_create_url_datetime.sql
UPDATE mynaone_request
SET create_url_datetime = (
    SELECT create_url_datetime
    FROM mynaone_request
    WHERE mynaone_id = '${id}_del'
)
WHERE mynaone_id = '${id}';

EOF
done

# 【危険箇所修正】削除対象を元のIDではなく、役目を終えた「_del付きのID」に変更
> delete_mynaone_request.sql
for id in $(grep -v -E "^mynaone_id|^$" select_target_submitted.csv); do
  echo "DELETE FROM mynaone_request WHERE mynaone_id = '${id}_del';" >> delete_mynaone_request.sql
done


# ==========================================
#  一次更新前のバックアップ取得（.prod環境に統一）
# ==========================================
../psql-to-csv.sh ../.prod select_mynaone_request.sql
../psql-to-csv.sh ../.prod select_mynaone_result.sql

mv select_mynaone_request.csv select_mynaone_request.bef.csv
mv select_mynaone_result.csv select_mynaone_result.bef.csv

```

---

### DB接続・データパッチ実行（一次実行）

```sql
-- DB接続設定
\echo :AUTOCOMMIT
\pset null '[NULL]'
\o |tee report.log

BEGIN;

-- 更新前状態確認
\i select_mynaone_request.sql
\i select_mynaone_result.sql

-- 更新実行
\i update_mynaone_request.sql
\i update_mynaone_request_for_url.sql
\i update_mynaone_result.sql

-- 更新後状態確認
\i select_mynaone_request.sql
\i select_mynaone_result.sql

COMMIT;
\q

```

### パッチ適用後の確認（シェル）

```bash
../psql-to-csv.sh ../.prod select_mynaone_request.sql
../psql-to-csv.sh ../.prod select_mynaone_result.sql

mv select_mynaone_request.csv select_mynaone_request.aft.csv
mv select_mynaone_result.csv select_mynaone_result.aft.csv

# 差分確認
git diff --no-index --color-words=. select_mynaone_request.bef.csv select_mynaone_request.aft.csv
git diff --no-index --color-words=. select_mynaone_result.bef.csv select_mynaone_result.aft.csv

```

---

### バッチ処理の実行

1. `s3://p25-signup-data/mynaone/accountlist/idlist_20260622.txt` に口座番号のリストを配置
2. `mynaone_request_creator` バッチを実行

---

### URL作成済みユーザー対象のID付け替え・データ復元（二次実行）

#### 1. 新しいUUIDの確認と `switch_mynaone_id.sql` の書き換え

バッチ実行によって新しく生成されたUUIDを特定し、SQLファイルを準備します。

```bash
# バッチが生成した新しいレコードの状況を出力します
../psql-to-csv.sh ../.prod check_new_records.sql
cat check_new_records.csv

```

出力されたCSV結果を見ながら、`switch_mynaone_id.sql` を開き、対象アカウント（`account_id`）ごとに新しく発行された `mynaone_id` を、`★ここに新しいUUIDを入力★` の部分にそれぞれ上書きマッピングして保存してください。

#### 2. ID付け替え前のバックアップ取得（シェル）

アカウントID単位でレコードを取得するため、新しく作成されたUUIDのデータも含めて実行前の状態を完璧に保存できます。

```bash
# CSVファイルを生成（アカウントIDベースで取得）
../psql-to-csv.sh ../.prod select_mynaone_request_by_account.sql

# ファイル名変更（一次実行時と区別するため switch_bef に変更）
mv select_mynaone_request_by_account.csv select_mynaone_request.switch_bef.csv

```

#### 3. IDの付け替えとURL作成日時の復元（DB接続）

```sql
-- DB接続設定
\echo :AUTOCOMMIT
\pset null '[NULL]'
\o |tee report.log

-- 1. IDの退避と付け替えを実行
BEGIN;
\i switch_mynaone_id.sql
COMMIT;

-- 2. URL作成日時の復元を実行（結果ファイルがテーブルに取り込まれたのを確認して実行）
BEGIN;
\i restore_create_url_datetime.sql
COMMIT;

-- 3. 用済みとなった退避データ(*_del)を安全に物理削除
BEGIN;
\i delete_mynaone_request.sql
COMMIT;
\q

```

#### 4. 更新後データの取得と差分確認（シェル）

```bash
# 更新後のデータをアカウントIDベースで取得
../psql-to-csv.sh ../.prod select_mynaone_request_by_account.sql
mv select_mynaone_request_by_account.csv select_mynaone_request.switch_aft.csv

# 差分確認（新UUIDのレコードが旧UUIDに変化し、datetimeが復元され、_delが消えた綺麗な差分が確認できます）
git diff --no-index --color-words=. select_mynaone_request.switch_bef.csv select_mynaone_request.switch_aft.csv

```