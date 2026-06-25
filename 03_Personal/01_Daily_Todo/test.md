

お疲れ様です。
6月より参画される方（計5名）の各種アカウント・権限のご用意をお願いしたく、ご連絡させていただきました。

全員分、GitHubアカウントが未連携のため、現時点で作成できないアカウントや権限は改めて依頼させていただきます。
お忙しい中恐縮ですが、よろしくお願いいたします。:bow:

---

### 【対象者】

■ 開発メンバー（2名）

* 氏名：坂井 蓮 ／ メールアドレス：sakai.ren@toiware.co.jp
* 氏名：生井 祐弥 ／ メールアドレス：namai.yuya@toiware.co.jp
* 氏名：佐藤 健翔 ／ メールアドレス：sato.kensho@toiware.co.jp
※佐藤さんの役割はテスターですが、STGの権限（AWSやGitHub等）は開発者向けでお願いいたします。

■ テスターメンバー（3名）

* 氏名：増崎 匠美 ／ メールアドレス：masuzaki.narumi@toiware.co.jp
* 氏名：上野 紘 ／ メールアドレス：ueno.ko@toiware.co.jp

---

### 【依頼内容】

#### 1. 全員共通で必要なアカウント・権限（5名全員）

* [ ] 開発VPN
* [ ] Redmine
* [ ] Box権限【社内外共有】サービス開発チーム
* [ ] Googleドライブ権限1001_VCTパートナー共有
* [ ] Figma
* [ ] GitHub（simon-arg/toiware） ※後ほど改めて連携いたします:bow:
* [ ] #テスト口座用メール受信箱（Slackチャンネル）への招待

#### 2. 開発メンバー・佐藤さんに「追加」で必要なアカウント・権限（計3名）

【対象者：坂井、生井、佐藤】

* [ ] AWSアカウント（vct-custodian）
* No_iam_AdminRole
* p25-signup-developer-role
* [ ] GitHub（simon-arg/custteam） ※後ほど改めて連携いたします:bow:



---
お疲れ様です。
6月より参画される方（計5名）の各種アカウント・権限のご用意をお願いしたく、ご連絡させていただきました。

全員分、GitHubアカウントが未連携のため、現時点で作成できないアカウントや権限は改めて依頼させていただきます。
お忙しい中恐縮ですが、よろしくお願いいたします。:bow:

---

### 【依頼内容】

#### ■ 1. 開発者権限（3名）

【対象者】

* 氏名：坂井 蓮 ／ メールアドレス：sakai.ren@toiware.co.jp
* 氏名：生井 祐弥 ／ メールアドレス：namai.yuya@toiware.co.jp
* 氏名：佐藤 健翔 ／ メールアドレス：sato.kensho@toiware.co.jp
  ※役割はテスターですが、STGの権限（AWSやGitHub等）は開発者向けでお願いいたします。

【必要なアカウント・権限】

* [ ] AWSアカウント（vct-custodian）
  * No_iam_AdminRole
  * p25-signup-developer-role
* [ ] 開発VPN
* [ ] Redmine
* [ ] Box権限【社内外共有】サービス開発チーム
* [ ] Figma
* [ ] GitHub（simon-arg/custteam, simon-arg/toiware） ※後ほど改めて連携いたします:bow:
* [ ] #テスト口座用メール受信箱（Slackチャンネル）への招待

---

#### ■ 2. テスター権限（2名）

【対象者】

* 氏名：増崎 匠美 ／ メールアドレス：masuzaki.narumi@toiware.co.jp
* 氏名：上野 紘 ／ メールアドレス：ueno.ko@toiware.co.jp

【必要なアカウント・権限】

* [ ] 開発VPN
* [ ] Redmine
* [ ] Box権限【社内外共有】サービス開発チーム
* [ ] Googleドライブ権限1001_VCTパートナー共有
* [ ] Figma
* [ ] GitHub（simon-arg/toiware） ※後ほど改めて連携いたします:bow:
* [ ] #テスト口座用メール受信箱（Slackチャンネル）への招待


### 1. 初回ご案内

toiware入場時のご案内 を確認いただいたら、連携されたtoiwareのアカウントでgithubアカウントの作成をお願いいたします。
プロジェクトについては概要資料 に記載があります。


### 2. アカウント・権限について

必要なアカウント（VPN, Github, Box, Figma等）は順次発行されます。
アカウント情報は個別にご連絡します。
連携されましたら、それぞれ以下ご確認よろしくお願いいたします


---

---
:memo: sql


select * from mynaone_request where mynaone_id = 'd75205b9-86b9-4c70-bbea-868971cbfc55';
update mynaone_request
set mynaone_status = 1
where mynaone_id = 'd75205b9-86b9-4c70-bbea-868971cbfc55';
select * from mynaone_result where mynaone_id = 'd75205b9-86b9-4c70-bbea-868971cbfc55';
insert into mynaone_result (file_name, file_type, mynaone_id, body)
values (
  '20260410140000IFS002',
  'IFS002',
  '1a95a1ca-1436-43e2-a5c5-b163cd7af015',
  '"8011001116594","1a95a1ca-1436-43e2-a5c5-b163cd7af015","","1:取得","20260410","20260410","個人番号カード（正常）"'
);
.
select * from mynaone_request where mynaone_id = 'ab5a8e1e-124e-49b2-b464-a56fb7396598';
update mynaone_request
set mynaone_status = 1
where mynaone_id = 'ab5a8e1e-124e-49b2-b464-a56fb7396598';
select * from mynaone_result where mynaone_id = 'ab5a8e1e-124e-49b2-b464-a56fb7396598';
insert into mynaone_result (file_name, file_type, mynaone_id, body)
values (
  '20260410140000IFS002',
  'IFS002',
  '1a95a1ca-1436-43e2-a5c5-b163cd7af015',
  '"8011001116594","1a95a1ca-1436-43e2-a5c5-b163cd7af015","","1:取得","20260410","20260410","個人番号カード（正常）"'
);

select * from mynaone_result where mynaone_id = 'd75205b9-86b9-4c70-bbea-868971cbfc55';
select * from mynaone_request where mynaone_id = 'd75205b9-86b9-4c70-bbea-868971cbfc55';

select * from mynaone_result where mynaone_id = 'ab5a8e1e-124e-49b2-b464-a56fb7396598';
select * from mynaone_request where mynaone_id = 'ab5a8e1e-124e-49b2-b464-a56fb7396598';









---


了解です。s25前提で、クラスタ名とECS接続の型を実運用向けに直した版を下に置きます。
ポイントは、まずシェル接続型で入ってから中でcurlする型に統一することです（クォート崩れを避けやすい）。

修正版（s25基準）

1. 前提固定
- クラスタ: s25-signup-cluster
- コンテナ:
  - フロント: s25-signup-frontend-container
  - API: s25-signup-api-container
- 対象ホスト: stg-trader.sbivc.co.jp
- API検証はPOST event/data形式を主とする（GETは参考値）

2. タスクID取得（s25）
- frontendタスクID
  $ aws ecs describe-tasks --cluster s25-signup-cluster --tasks $(aws ecs list-tasks --cluster s25-signup-cluster --query "taskArns" --output text) --query "tasks[?containers[?name=='s25-signup-frontend-container']].taskArn" --output text | tr '\t' '\n' | awk -F'/' '{print $NF}'

- apiタスクID
  $ aws ecs describe-tasks --cluster s25-signup-cluster --tasks $(aws ecs list-tasks --cluster s25-signup-cluster --query "taskArns" --output text) --query "tasks[?containers[?name=='s25-signup-api-container']].taskArn" --output text | tr '\t' '\n' | awk -F'/' '{print $NF}'

3. ECS接続の型（推奨）
- 推奨: シェル接続型（中で複数コマンドを実行）
  $ aws ecs execute-command --cluster s25-signup-cluster --task 5e2e5f4f0b14415e859c717863127bdf --container s25-signup-frontend-container --command "/bin/sh" --interactive
  $ aws ecs execute-command --cluster s25-signup-cluster --task <API_TASK_ID> --container s25-signup-api-container --command "/bin/sh" --interactive

- 補助: ワンショット型（1コマンドだけ実行）
  $ aws ecs execute-command --cluster s25-signup-cluster --task <FRONT_TASK_ID> --container s25-signup-frontend-container --command "curl -s https://ipinfo.io/json" --interactive

4. 手順1: NAT出口IP確認（各コンテナ内）
- 実行
  $ curl -s https://ipinfo.io/json

- 確認
  - ipがfrontend/apiでどう違うか
  - 固定化されているか
  - 先方許可IPと照合可能か

5. 手順2: DNS実解決（各コンテナ内）
- 実行
  $ getent hosts stg-trader.sbivc.co.jp || nslookup stg-trader.sbivc.co.jp

- 確認
  - A: 104.18.30.179 / 104.18.31.179
  - AAAA有無
  - frontend/apiで差分有無

6. 手順3: L4/L7分離（各コンテナ内）
- 通常接続
  $ curl -v --connect-timeout 5 --max-time 20 https://stg-trader.sbivc.co.jp/cccmdipresen/gw/login -o /dev/null -s -w "code=%{http_code} ip=%{remote_ip} tls=%{ssl_verify_result} time_connect=%{time_connect} time_appconnect=%{time_appconnect} time_total=%{time_total}\n"

- IP固定
  $ curl -v --resolve stg-trader.sbivc.co.jp:443:104.18.30.179 --connect-timeout 5 --max-time 20 https://stg-trader.sbivc.co.jp/cccmdipresen/gw/login -o /dev/null -s -w "code=%{http_code} ip=%{remote_ip} time_connect=%{time_connect} time_appconnect=%{time_appconnect} time_total=%{time_total}\n"
  $ curl -v --resolve stg-trader.sbivc.co.jp:443:104.18.31.179 --connect-timeout 5 --max-time 20 https://stg-trader.sbivc.co.jp/cccmdipresen/gw/login -o /dev/null -s -w "code=%{http_code} ip=%{remote_ip} time_connect=%{time_connect} time_appconnect=%{time_appconnect} time_total=%{time_total}\n"

- 判定
  - ETIMEDOUT: 経路/FW寄り
  - 403: Cloudflare/WAFまたは先方制御
  - 500: 先方アプリ層到達

7. 手順4: 実API形式で再現（各コンテナ内、重要）
- priceFeedList
  $ curl -v --connect-timeout 5 --max-time 20 -H "Content-Type: application/json" -X POST https://stg-trader.sbivc.co.jp/cccmdipresen/gw/market -d "{\"event\":\"priceFeedList\",\"data\":{\"reqList\":{\"0\":{\"productId\":\"EX_BTC/JPY\",\"isAuction\":false}}}}" -o /dev/null -s -w "code=%{http_code} ip=%{remote_ip} time_total=%{time_total}\n"

- chart
  $ curl -v --connect-timeout 5 --max-time 20 -H "Content-Type: application/json" -X POST https://stg-trader.sbivc.co.jp/cccmdipresen/gw/market -d "{\"event\":\"chart\",\"data\":{\"fxProductId\":\"EX_BTC/JPY\",\"bidAskType\":\"ASK\",\"isAuction\":\"false\",\"chartIntervalType\":\"HOUR\",\"numOfBars\":\"50\"}}" -o /dev/null -s -w "code=%{http_code} ip=%{remote_ip} time_total=%{time_total}\n"

8. 手順5: AWS側ログ確認
- NAT Gateway Flow Logsで対象時刻を確認
- 宛先 104.18.30.179:443 / 104.18.31.179:443 の action確認
- 判定
  - REJECT: NACL/Network Firewall/経路
  - ACCEPTかつtimeout: 先方無応答や中間経路
  - ACCEPTかつ403/500: L7要因

9. 比較軸（s25内）
- 実行元: s25 frontend / s25 api
- 送信元IP
- remote_ip
- HTTP code
- cf-ray
- time_connect / time_appconnect / time_total

補足
- あなたの質問どおり「s25固定」でまず完了させるなら、比較対象は p25 ではなく frontend と api の2系統で十分です。
- その後に必要なら同じ手順を p25-signup-cluster に横展開して差分比較すればOKです。






----

口座開設フロント
  追加
    マイページ (個人/法人) - ステーキング報酬の受取方法
      機能
        ・対象銘柄の申請情報の取得
          マイページにログインした顧客のステーキング報酬の受取方法の設定情報を銘柄単位で取得する。
          取得した銘柄の設定情報についてそれぞれ、マイページ左のメニュー欄に追加する。（ステーキング報酬受取設定の下）

        ・申請情報の更新機能
          画面に表示された銘柄の受取方法を選択し、「更新する」ボタンを押下することで、申請情報を更新する。
          更新が完了した場合は、「ステーキング報酬の受取方法を更新しました。」とダイアログを表示する。
          更新後は申請情報を再度取得し、最新の情報を画面に反映する。

    画面デザインについては「画面イメージシート」を参照

口座開設バックエンド
  追加
    円転対象銘柄の顧客申請情報の取得
      処理の流れ
        ① ステーキング報酬受付管理テーブルの以下の条件に該当する銘柄情報を取得する
          ・円転対象フラグ: 1
          ・削除フラグ:  0
        ② 取得した銘柄に対して、APIを実行した顧客が登録しているステーキング報酬円転受取設定のうち、最新の情報を取得する。

    円転申請情報の登録
      処理の流れ
        円転申請があった各銘柄について、以下の処理を行う。
          ①APIを実行した顧客が登録した最新の円転情報を取得する。
          ②登録情報がない、または異なる設定を申請している場合のみ、新規に円転申請情報を登録する
          ③過去に同月内で申請があった情報が登録されている場合は論理削除する
          ※ 同月内で論理削除されていないレコードは１件のみとなるようにする

DB
  修正
    ステーキング報酬対象銘柄テーブル
      詳細は`ステーキング報酬対象銘柄テーブル`を参照
      円転対象フラグを追加
        0 の場合は未申請、1の場合は申請済みとして扱う
        デフォルトは 0 で設定される

  追加
    ステーキング報酬円転受取管理テーブル
      以下の項目で定義する
        項目名								説明
        ID								レコードの管理番号
        口座番号								申請した顧客の口座番号
        銘柄								申請した銘柄
        報酬円転設定								円転設定 (0は暗号資産、1は円で受け取る)
        円転申請日時								マイページから「更新する」ボタンを押下した日時
        登録日時								レコード登録日時
        登録者								DB登録者
        更新日時								レコード更新日時
        更新者								DB更新者
        バージョン								DBの更新回数
    詳細は`ステーキング報酬円転受取管理テーブル`を参照


---

エンティティ情報
  論理エンティティ名	ステーキング報酬円転受付管理		タグ
  物理エンティティ名	staking_rewards_conversion_entry
  備考

カラム情報
No.	論理名	物理名	データ型	Not Null	デフォルト	備考
1	管理番号	id	NUMBER(8)	Yes (PK)
2	口座番号	account_id	VARCHAR2(8 CHAR)	Yes
3	通貨名	currency	VARCHAR2(10 CHAR)	Yes
4	報酬円転設定	is_reward_rejection	NUMBER(1)	Yes	0	0:未設定,1:設定済
5	円転申請日時	applied_datetime	TIMESTAMP	Yes
6	登録日時	register_datetime	TIMESTAMP	Yes
7	登録者	register_user	VARCHAR2(20 CHAR)	Yes
8	更新日時	update_datetime	TIMESTAMP	Yes
9	更新者	update_user	VARCHAR2(20 CHAR)	Yes
10	削除フラグ	delete_flag	NUMBER(1)	Yes	0
11	バージョン	version	NUMBER(10, 0)	Yes	0

インデックス情報
No.	インデックス名	カラムリスト			ユニーク	備考

リレーションシップ情報(FK側)
No.	動詞句	カラムリスト		参照先エンティティ名		参照先カラムリスト
1		account_id		account		account_id
2		currency		staking_rewards_currency		currency

---

エンティティ情報
  物理エンティティ名	staking_rewards_currency
  備考
  暗号資産テーブルに登録されている値を参考にステーキング報酬対象となる銘柄とソート順を登録する。

カラム情報
No.	論理名	物理名	データ型	Not Null	デフォルト	備考
1	通貨コード	currency	VARCHAR2(10 CHAR)	Yes(PK)		e.g. BTC
2	ソート順	sort_order	NUMBER(9)	Yes		2025/04/14 PKではないため修正
3	円転対象フラグ	is_conversion	NUMBER(1)	Yes	0	0: 未申請, 1: 申請済み
4	登録日時	register_datetime	TIMESTAMP	Yes
5	登録者	register_user	VARCHAR2(20 CHAR)	Yes
6	更新日時	update_datetime	TIMESTAMP	Yes
7	更新者	update_user	VARCHAR2(20 CHAR)	Yes
8	削除フラグ	delete_flag	NUMBER(1)	Yes	0
9	バージョン	version	NUMBER(10, 0)	Yes	0

インデックス情報
No.	インデックス名	カラムリスト			ユニーク	備考

リレーションシップ情報(FK側)
No.	動詞句	カラムリスト		参照先エンティティ名		参照先カラムリスト

No.	動詞句	カラムリスト		参照先エンティティ名		参照先カラムリスト
1		currency		staking_rewards_currency		currency


---
同種の漏れを一括で洗い出すため、まず `web` 配下を機械的にスキャンして「`ResponseEntity<?>` なのに `ResponseEntity.ok(List...)` を返すメソッド」と「`EXPECTATION_FAILED(417)` を返すメソッド」を抽出します。これで他Controllerの対応対象を具体化します。

Ran terminal command:  rg -n --no-heading "public ResponseEntity<\?> .*\(|ResponseEntity\.ok\(|EXPECTATION_FAILED|HttpStatus\.EXPECTATION_FAILED" src/main/java/com/bitargx/signup/api/web | sed -n '1,260p'

Read [](file:///Users/takada/Library/Application%20Support/Code/User/workspaceStorage/bb7ebecd94e0db598126a19e770f4552/GitHub.copilot-chat/chat-session-resources/e1be1487-7420-4b82-835c-19414c0dfb77/call_v1Z8gLDdbvtz8swH8khgPVvd__vscode-1781487565578/content.txt#1-1), lines 1 to 320

候補を絞るため、次は「実際にListを返している可能性」と「417返却を実装しているAPI」をそれぞれ抽出して、優先度順に対応対象を出します。

Ran terminal command:  echo '--- list-like ok returns ---'; rg -n --no-heading "ResponseEntity\.ok\((resList|.*List\)|.*\.get[A-Za-z0-9_]*\(.*\))" src/main/java/com/bitargx/signup/api/web/*Controller.java | sed -n '1,220p'; echo '--- explicit 417 returns ---'; rg -n --no-heading "HttpStatus\.EXPECTATION_FAILED|createErrorResponse\(HttpStatus\.EXPECTATION_FAILED" src/main/java/com/bitargx/signup/api/web/*Controller.java | sed -n '1,220p'

Ran terminal command:  ops='registerConversion getConversion getCampaignList entry getPaymentSpecialCaseCurrencies get registerConversion issueSbiCryptId submitPdf getInsiderCurrencies getStakingRewardsEntryList'; for op in $ops; do echo "===== $op ====="; rg -n --no-heading "operationId: $op|"417"|type: array|/staking/conversion/\{accountId\}|/staking/conversion/register|/campaign/\{|/payment_special_case/\{|/primeprogram/\{|/util/insider_currencies|/trustdock/\{accountId\}/submit-pdf" docs/api-docs.yaml | sed -n '1,200p'; done

現状の api-docs.yaml にはすでに 417 と配列定義が一部反映されている可能性が見えたので、対象コントローラの現行コードと生成結果を突き合わせて「他にも同様の未整備が残っている箇所」を正確に一覧化します。

Read [](file:///Users/takada/Desktop/10_github/signup-api/src/main/java/com/bitargx/signup/api/web/StakingRewardsController.java)

Read [](file:///Users/takada/Desktop/10_github/signup-api/docs/api-docs.yaml#1040-1040), lines 1040 to 1115

Read [](file:///Users/takada/Desktop/10_github/signup-api/docs/api-docs.yaml#4000-4000), lines 4000 to 4060

横展開対象を確定するため、417 を返す全エンドポイントについて api-docs.yaml 側に 417 定義があるかをパス単位で自動チェックします。結果として「要対応/不要」を一覧化します。

Ran terminal command:  paths=(
'/bank_transfer_special_case/entry/{accountId}'
'/invitation/{accountId}/mail/code/use'
'/invitation/{accountId}/code/use'
'/invitation/{accountId}/code/check'
'/invitation/mail/code/check'
'/staking/update'
'/staking/conversion/register'
'/payment_special_case/entry/{accountId}'
'/campaign/entry'
'/trustdock/{accountId}/submit-pdf'
'/individual/{accountId}/register'
)
for p in "${paths[@]}"; do
  start=$(rg -n --no-heading "^  ${p/////}:$" docs/api-docs.yaml | cut -d: -f1 | head -n1)
  if [[ -z "$start" ]]; then
    echo "MISSING_PATH $p"
    continue
  fi
  end=$(awk -v s="$start" 'NR>s && /^  // {print NR; exit}' docs/api-docs.yaml)
  [[ -z "$end" ]] && end=$(wc -l < docs/api-docs.yaml)
  if sed -n "${start},${end}p" docs/api-docs.yaml | rg -q '"417"'; then
    echo "OK_417 $p"
  else
    echo "NG_417 $p"
  fi
done

Ran terminal command:  paths=(
'/bank_transfer_special_case/entry/{accountId}'
'/invitation/{accountId}/mail/code/use'
'/invitation/{accountId}/code/use'
'/invitation/{accountId}/code/check'
'/invitation/mail/code/check'
'/staking/update'
'/staking/conversion/register'
'/payment_special_case/entry/{accountId}'
'/campaign/entry'
'/trustdock/{accountId}/submit-pdf'
'/individual/{accountId}/register'
)
for p in "${paths[@]}"; do
  start=$(rg -n --no-heading -F "  $p:" docs/api-docs.yaml | cut -d: -f1 | head -n1)
  if [[ -z "$start" ]]; then
    echo "MISSING_PATH $p"
    continue
  fi
  end=$(awk -v s="$start" 'NR>s && /^  // {print NR; exit}' docs/api-docs.yaml)
  [[ -z "$end" ]] && end=$(wc -l < docs/api-docs.yaml)
  if sed -n "${start},${end}p" docs/api-docs.yaml | rg -q '"417"'; then
    echo "OK_417 $p"
  else
    echo "NG_417 $p"
  fi
done

Ran terminal command:  paths=(
'/campaign/{accountId}'
'/payment_special_case/{accountId}'
'/primeprogram/{accountId}'
'/util/insider_currencies'
'/staking/{accountId}'
'/staking/conversion/{accountId}'
)
for p in "${paths[@]}"; do
  start=$(rg -n --no-heading -F "  $p:" docs/api-docs.yaml | cut -d: -f1 | head -n1)
  if [[ -z "$start" ]]; then
    echo "MISSING_PATH $p"
    continue
  fi
  end=$(awk -v s="$start" 'NR>s && /^  // {print NR; exit}' docs/api-docs.yaml)
  [[ -z "$end" ]] && end=$(wc -l < docs/api-docs.yaml)
  block=$(sed -n "${start},${end}p" docs/api-docs.yaml)
  if echo "$block" | rg -q 'operationId:'; then :; fi
  if echo "$block" | rg -q '"200"'; then
    if echo "$block" | rg -q 'type: array'; then
      echo "OK_ARRAY $p"
    else
      echo "NG_ARRAY $p"
    fi
  else
    echo "NO_200 $p"
  fi
done

対応対象をすぐ着手できる形にするため、最後に候補エンドポイントの行番号を拾って一覧化します。これで「どこを同じ方針で直すか」を明確にします。

Ran terminal command:  rg -n --no-heading -F "public ResponseEntity<?> getCampaignList" src/main/java/com/bitargx/signup/api/web/CampaignController.java; rg -n --no-heading -F "public ResponseEntity<?> getPaymentSpecialCaseCurrencies" src/main/java/com/bitargx/signup/api/web/PaymentSpecialCaseController.java; rg -n --no-heading -F "public ResponseEntity<?> get(@PathVariable String accountId)" src/main/java/com/bitargx/signup/api/web/PrimeProgramEntryController.java; rg -n --no-heading -F "public ResponseEntity<?> getInsiderCurrencies" src/main/java/com/bitargx/signup/api/web/UtilController.java; rg -n --no-heading -F "public ResponseEntity<?> getStakingRewardsEntryList" src/main/java/com/bitargx/signup/api/web/StakingRewardsController.java; rg -n --no-heading -F "HttpStatus.EXPECTATION_FAILED" src/main/java/com/bitargx/signup/api/web/{BankTransferSpecialCaseController.java,InvitationController.java,StakingRewardsController.java,PaymentSpecialCaseController.java,CampaignController.java,TrustdockController.java,IndividualController.java}; rg -n --no-heading -F "  /campaign/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /payment_special_case/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /primeprogram/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /util/insider_currencies:" docs/api-docs.yaml; rg -n --no-heading -F "  /staking/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /staking/update:" docs/api-docs.yaml; rg -n --no-heading -F "  /campaign/entry:" docs/api-docs.yaml; rg -n --no-heading -F "  /payment_special_case/entry/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /bank_transfer_special_case/entry/{accountId}:" docs/api-docs.yaml; rg -n --no-heading -F "  /trustdock/{accountId}/submit-pdf:" docs/api-docs.yaml; rg -n --no-heading -F "  /individual/{accountId}/register:" docs/api-docs.yaml; rg -n --no-heading -F "  /invitation/{accountId}/mail/code/use:" docs/api-docs.yaml; rg -n --no-heading -F "  /invitation/{accountId}/code/use:" docs/api-docs.yaml; rg -n --no-heading -F "  /invitation/{accountId}/code/check:" docs/api-docs.yaml; rg -n --no-heading -F "  /invitation/mail/code/check:" docs/api-docs.yaml

あります。現状の生成済み api-docs.yaml を確認すると、同種の候補が複数あります。

1. 417定義漏れの候補
実装側で 417 を返しているのに、OpenAPI 側に 417 が見当たらないパスです。

1. CampaignController.java
2. PaymentSpecialCaseController.java
3. BankTransferSpecialCaseController.java
4. TrustdockController.java
5. IndividualController.java
6. InvitationController.java ほか, api-docs.yaml, api-docs.yaml, api-docs.yaml
7. StakingRewardsController.java の /staking/update 側

補足:
- /staking/conversion/register は 417 が既に入っています（api-docs.yaml）。

2. 200レスポンスが配列でない候補
実装上は List を返しているのに、OpenAPI の 200 schema が object になっている候補です。

1. CampaignController.java
2. PaymentSpecialCaseController.java
3. PrimeProgramEntryController.java
4. UtilController.java
5. StakingRewardsController.java の /staking/{accountId} 側

3. なぜ起きるか
1. 戻り型が ResponseEntity<?> だと 200 の具体スキーマ推論が弱くなり、object になりやすいです。
2. 417 のような業務エラーは実装分岐内の createErrorResponse だけでは生成器が拾いきれない場合があります。

同じ対応方針で統一するなら、次の2点を横展開するのが最短です。
1. List返却の GET は戻り型を具体化（例: ResponseEntity<List<...>>）。
2. 417 を返すメソッドには 417 レスポンスを明示（アノテーションで定義）。

必要ならこの対象に対して、こちらで一括修正まで進めます。
---

### 単体テスト (JUnit)
#### Repository層
- StakingRewardsConversionEntryRepositoryTest
  - 正常系：findTopByCurrencyAndAccountIdAndDeleteFlagFalseOrderByAppliedDatetimeDesc 
  - 異常系：findTopByCurrencyAndAccountIdAndDeleteFlagFalseOrderByAppliedDatetimeDesc_NotFound

- StakingRewardsCurrencyRepositoryTest
  - 円転対象銘柄の取得：findByJpyConversionEnabledTrueAndDeleteFlagFalseOrderBySortOrderAsc 
  - 円転対象銘柄のカウント：countByCurrencyAndJpyConversionEnabledTrueAndDeleteFlagFalse

#### Service層

- StakingRewardsServiceTest
  - 同月内の上書き更新：registerConversionList_overwritesInSameMonth
  - 別月での新規作成：registerConversionList_createsNewEntryAcrossMonth
  - 変更なしの場合は保存しない：registerConversionList_doesNotSaveWhenNoChange 
テストカバレッジ:
正常系: 初回登録、同月内更新、別月更新
異常系: 変更なし、口座不存在、口座ステータス不正


#### Controller層
- StakingRewardsControllerTest
  - 正常系(200)：getConversion_returnsOk
  - 異常系(404)：getConversion_returnsNotFoundOnException

  - 正常系(200)：registerConversion_returnsOk
  - ビジネスエラー(417)：registerConversion_returnsExpectationFailedOnBusinessError 
  - システムエラー(500)：registerConversion_returnsInternalServerErrorOnException 



---

### 1. 円転対象銘柄一覧取得API

#### TC-001: 正常系 - 初回取得（申請履歴なし）
  - **観点:** 初めて画面を開いたユーザーが銘柄一覧を取得できることを確認
#### TC-002: 正常系 - 申請履歴ありの取得
  - **観点:** 過去に申請した設定が正しく取得できることを確認
#### TC-003: 異常系 - 存在しない口座番号
  - **観点:** 不正な口座番号でエラーが返ることを確認
#### TC-004: 異常系 - 口座ステータスが仮口座
  - **観点:** 本口座以外のステータスで空リストが返ることを確認

### 2. 円転申請登録API

#### TC-101: 正常系 - 初回申請（ETHのみ円転有効）
  - **観点:** 初めて円転設定を行う場合の正常動作を確認
#### TC-102: 正常系 - 同月内の設定変更（上書き）
  - **観点:** 同じ月内に設定を変更した場合、既存レコードが上書きされることを確認
#### TC-103: 正常系 - 別月の設定変更（新規作成）
  - **観点:** 月をまたいで設定を変更した場合、新規レコードが作成されることを確認
#### TC-104: 正常系 - 設定変更なし（保存されない）
  - **観点:** 既存の設定と同じ値を送信した場合、DBが更新されないことを確認
#### TC-105: 正常系 - 複数銘柄の一括更新
  - **観点:** 複数銘柄の設定を同時に変更できることを確認
#### TC-106: 異常系 - 円転対象外の銘柄を指定
  - **観点:** 円転対象でない銘柄を指定した場合のエラー処理を確認
#### TC-107: 異常系 - バリデーションエラー（口座番号不正）
  - **観点:** リクエストパラメータのバリデーションが動作することを確認
#### TC-108: 異常系 - 必須パラメータ欠如
  - **観点:** 必須パラメータが欠けている場合のエラー処理を確認
#### TC-109: 異常系 - 口座ステータスが不正
  - **観点:** 仮口座など不正なステータスの場合のエラー処理を確認

### 3. 統合シナリオテスト

#### TC-201: E2Eシナリオ - 初回申請から設定変更まで
  - **観点:** 実際のユーザー操作を想定した一連の流れを確認
**手順:**
1. 円転設定一覧を取得（初回）
   → 全てfalse

2. ETHの円受取を有効化
3. 再度一覧を取得して確認
   → ETHがtrue

4. 同月内にETHを暗号資産で受け取りに上書き
5. DBで同月内のレコード数を確認
   → 1件のみ（上書きされている）

**期待結果:**
- 全ステップが正常に完了
- 同月内の設定変更は上書き、別月は新規作成

---
## 境界値・特殊ケース

### TC-301: 削除済みレコードの扱い
  - **観点:** 削除フラグがtrueのレコードが取得されないことを確認
**手順:**
1. 一覧取得APIを実行

**期待結果:**
- 削除フラグがtrueのレコードは取得されない
- ETHはデフォルト値（false）で返る
