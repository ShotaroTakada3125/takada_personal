# issue_prod_access_month 使い方

このドキュメントは `issue_prod_access_month` スクリプトの実行方法を説明します。

`.env` を毎回書き換えずに、実行時の環境変数上書きでメンバー切替する方法も記載しています。

## 概要

`issue_prod_access_month` は、指定した月（`YYYYMM`）を週単位（営業日: 月〜金）に分割し、
内部で `issue_prod_access START_DATE END_DATE` を順番に実行するラッパースクリプトです。

- 日付フォーマットは `YYYYMMDD`
- 週末（土日）はスキップされます
- `--dry-run` を付けると実行コマンド表示のみで、実際の処理は行いません

## 前提条件

- `bash` で実行可能であること
- `python3` が利用可能であること
- 同じディレクトリに `issue_prod_access` が存在し、実行権限があること

## 実行方法

スクリプトのあるディレクトリで実行します。

```bash
./issue_prod_access_month YYYYMM [--start-date YYYYMMDD] [--dry-run]
```

### 例

```bash
# 2026年6月分を実行
./issue_prod_access_month 202606

# 2026年6月の9日以降を実行
./issue_prod_access_month 202606 --start-date 20260609

# 実行内容だけ確認（実処理なし）
./issue_prod_access_month 202606 --dry-run

# 2026年7月の2週目以降だけ確認
./issue_prod_access_month 202607 --start-date 20260706 --dry-run
```

## 引数

- `YYYYMM`（必須）
  - 対象月を6桁で指定します（例: `202606`）
- `--start-date YYYYMMDD`（任意）
  - 指定日以降の週だけを対象にします
  - 指定日は対象月の範囲内である必要があります
  - 土日を指定した場合は次の月曜日から開始されます
- `--dry-run`（任意）
  - 実行対象の期間とコマンドだけを表示します

## `.env` を書き換えないメンバー切替

`issue_prod_access` は環境変数を参照するため、実行時だけ以下を上書きできます。

- `REDMINE_AUTHOR_ID`
- `REDMINE_AUTHOR_NAME`

単体実行例:

```bash
REDMINE_AUTHOR_ID=4731 REDMINE_AUTHOR_NAME="髙田 祥太朗" \
  ./issue_prod_access_month 202607 --start-date 20260706 --dry-run
```

この方法なら `.env` は固定のままで運用できます。

## 全メンバー一括実行

同梱の `issue_prod_access_month_members` を使うと、`members.csv` の全員分を順番に実行できます。

1. `members.csv` を編集

```csv
# author_id,author_name
4731,髙田 祥太朗
3774,メンバーA
```

2. 一括実行

```bash
./issue_prod_access_month_members 202607 --start-date 20260706 --dry-run
```

必要に応じてファイルを指定:

```bash
./issue_prod_access_month_members 202607 --members-file ./members.csv
```

## 出力イメージ

```text
Running: ./issue_prod_access 20260601 20260605
Running: ./issue_prod_access 20260608 20260612
Running: ./issue_prod_access 20260615 20260619
...
```

`--dry-run` 時は最後に以下が表示されます。

```text
Dry run completed.
```

## 注意点

- 月末の週が翌月にまたがる場合、終了日は翌月の日付になることがあります。
  - 例: 対象月の最終営業週が月曜始まりの場合、終了日が翌月の金曜になる
- 不正な引数（例: `YYYYMM` 以外の形式、未知オプション）の場合は Usage を表示して終了します
- `issue_prod_access` が存在しない、または実行権限がない場合はエラー終了します

## トラブルシュート

- `Command not found or not executable` が出る場合
  - `issue_prod_access` に実行権限を付与してください

```bash
chmod +x ./issue_prod_access
```

- `python3` が見つからない場合
  - `python3 --version` で確認し、必要に応じてインストールしてください
