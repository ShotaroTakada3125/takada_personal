# ステーキング報酬受取設定 手動テストケース（統合後）

## 前提

- 起動: `mvn spring-boot:run`（dev profile）、ポート`21002`
- DB接続: `postgresql://signupadmin:signupadmin@localhost:5432/s25signup`（`apitest/dredd-test.sh`と同一）
- テスト対象アカウント: `10000008`（本登録）、`10000001`（仮登録などの本登録以外のステータス）
- マスタデータ（`staking_rewards_currency`・`staking_rewards_conversions`）は別リポジトリのマイグレーションで投入済みであることが前提。以下の銘柄コード（ETH/JPYSC/USDC等）は投入内容に応じて読み替えること。

### 事前確認: マスタデータの投入状況

```sql
SELECT currency, sort_order FROM staking_rewards_currency WHERE delete_flag = false ORDER BY sort_order;
SELECT currency, converted_currency, sort_order FROM staking_rewards_conversions WHERE delete_flag = false ORDER BY currency, sort_order;
```
- 各銘柄について、自己参照行（例: `ETH → ETH`）が最低1件存在することを確認する。

### テスト後のクリーンアップ

```sql
DELETE FROM staking_rewards_entry WHERE account_id = '10000008';
```

---

## E2Eシナリオ

### TC-E01: 初回取得（申請履歴なし）
目的: エントリ未登録時に「暗号資産のまま受取」がデフォルトとして返ることを確認

```bash
curl -X GET "http://localhost:21002/staking/10000008" | jq
```

期待結果:
- `200 OK`
- 各銘柄について `isRewardRejection: false`、`receivedCurrency` が銘柄自身のコードと一致
- `conversions` に選択可能な変換先一覧が入っている
- WARN/ERRORログが出力されないこと（目視）

---

### TC-E02: JPYSC受取への変更 → GETへの反映確認
目的: POSTで変更した内容がGETに正しく反映されることを確認

```bash
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": false, "receivedCurrency": "JPYSC" }
    ]
  }' | jq
```

期待結果: `200 OK`

```bash
curl -X GET "http://localhost:21002/staking/10000008" | jq
```

期待結果: ETHの`receivedCurrency`が`JPYSC`、`isRewardRejection`が`false`

DB確認:
```sql
SELECT id, is_reward_rejection, received_currency, update_datetime
FROM staking_rewards_entry
WHERE account_id = '10000008' AND currency = 'ETH' AND delete_flag = false;
```
- `received_currency = 'JPYSC'`。この行の`id`を記録しておく（次のTC-E03で使用）。

---

### TC-E03: 同日中の再変更（上書き確認）
目的: 当日基準の上書きルールにより、新規レコードが増えず既存行が更新されることを確認

```bash
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": false, "receivedCurrency": "JPYSC" }
    ]
  }' | jq
```

期待結果: `200 OK`

DB確認:
```sql
SELECT id, received_currency FROM staking_rewards_entry
WHERE account_id = '10000008' AND currency = 'ETH' AND delete_flag = false;
```
- 件数が1件のまま（TC-E02と同じ`id`）で、`received_currency`が`JPYSCd`に更新されていること（新規行が増えていないこと）。

---

### TC-E04: 拒否設定への変更（受取銘柄のnull強制の確認）
目的: 拒否設定時、リクエストに`receivedCurrency`を含めてもサーバー側で`null`に強制されることを確認

```bash
curl -s -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": true, "receivedCurrency": "JPYSC" }
    ]
  }' | jq
```

期待結果: `200 OK`

DB確認:
```sql
SELECT is_reward_rejection, received_currency FROM staking_rewards_entry
WHERE account_id = '10000008' AND currency = 'ETH' AND delete_flag = false;
```
- `is_reward_rejection = true`、`received_currency`が`JPYSC`ではなく`NULL`であること。

```bash
curl -X GET "http://localhost:21002/staking/10000008" | jq
```
- ETHの`isRewardRejection: true`、`receivedCurrency: null`。

---

### TC-E05: 複数銘柄の同時変更
目的: `changeList`に複数銘柄を含めた一括更新が正しく反映されることを確認

```bash
curl -s -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": false, "receivedCurrency": "ETH" },
      { "currency": "FLR", "isRewardRejection": false, "receivedCurrency": "JPYSC" }
    ]
  }' | jq
```

期待結果: `200 OK`。GETで両銘柄の変更が反映されていることを確認。

---

### TC-E06: 存在しない口座番号（GET/POST共通で404になることを確認）
目的: 口座未登録(`NoSuchElementException`)は、入力バリデーションエラーとは別に404として扱われることを確認する

```bash
curl -v -X GET "http://localhost:21002/staking/99999999" | jq
```
期待結果: `404`、
`{
  "error": 1004,
  "message": "指定された口座は登録されていません。"
}`。ログに`account fetch failed: accountId=99999999`のWARNが出力されること（目視）。

```bash
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"99999999","changeList":[{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"ETH"}]}' | jq
```
期待結果: `404`、
`{
  "error": 1004,
  "message": "指定された口座は登録されていません。"
}`。ログに`account fetch failed: accountId=99999999`のWARNが出力されること（目視）。

---

### TC-E07: 口座ステータス不正時のGET/POSTの挙動差分確認
目的: GETは空リスト、POSTは417になるという既知の仕様差分を確認する

```bash
curl -X GET "http://localhost:21002/staking/10000001" | jq
```
期待結果: `200 OK`、レスポンス`[]`。ログに`口座ステータスが正しくありません。: accountId=10000001, status=...`のWARNが出力されること。

```bash
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId": "10000001", "changeList": [{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"ETH"}]}' | jq
```
期待結果: `417`、`{
  "error": 2008,
  "message": "口座状況が不正です。"
}`。

---

### TC-E08: 不正な変更内容（バリデーションエラー）
目的: 銘柄不正・受取銘柄未指定・変換先不正のいずれも400が返り、既存データが変更されないことを確認する。

注意: レスポンスの`message`は3パターンとも`error=1000`に対応する固定の汎用メッセージ（例:「パラメーターが正しくありません。」）になり、レスポンス上では区別できない。個別の原因はサーバー側のWARNログでのみ確認できる（`createErrorResponse(HttpStatus.BAD_REQUEST, VALIDATION_ERROR)`が例外メッセージをレスポンスに渡さない仕様のため）。

```bash
# ① 存在しない銘柄
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"10000008","changeList":[{"currency":"XXX","isRewardRejection":false,"receivedCurrency":"XXX"}]}' | jq
```
期待結果: `400`、レスポンスは`{"error":1000,"message":"パラメーターが正しくありません。"}`（固定文言）。ログに`staking rewards change invalid request: accountId=10000008`のWARNが出力され、その例外メッセージが「暗号資産情報が存在しません。」であること。

```bash
# ② 非拒否なのにreceivedCurrencyを未指定(null)
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"10000008","changeList":[{"currency":"ETH","isRewardRejection":false}]}' | jq
```
期待結果: `400`、レスポンスは①と同じ固定文言。ログの例外メッセージが「受け取り銘柄を指定してください。」であること（①・③とは異なる、未指定であることを示す文言）。

```bash
# ③ 存在しない変換先(マッピングにない銘柄コードを指定)
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"10000008","changeList":[{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"存在しない銘柄コード"}]}' | jq
```
期待結果: `400`、レスポンスは①と同じ固定文言。ログの例外メッセージが「受け取り銘柄情報が存在しません。」であること（②とは異なり「未指定」ではなく「存在しない」という文言）。

- 3ケースともDBの既存行が変更されていないことを確認（他行への影響がないこと）。

---

### TC-E09: リクエスト自体のバリデーションエラー
```bash
# accountIdが8桁でない
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"123","changeList":[{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"ETH"}]}' | jq
```
期待結果: `400`、`accountId must match`系のメッセージ。

```bash
# changeList欠如
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"10000008"}' | jq
```
期待結果: {
  "error": 1000,
  "message": "accountId must match \"\\d{8}\""
}

---

### TC-E09b: changeList内の要素がnull（既知の制約）

上記TC-E09（`changeList`という入れ物自体が無い/nullの場合）とは別のケース。`changeList`はあるが、中の要素がnullの場合。

```bash
curl -v -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"10000008","changeList":[null]}' | jq
```

期待結果: `500`、`{
  "error": 2008,
  "message": "口座状況が不正です。"
}`。

Bean Validationの`@Valid`カスケード検証は、リストの要素自体がnullの場合を検出しない仕様上の制約があるため、このリクエストはバリデーションを通過してServiceまで到達し、`NullPointerException`が発生してControllerの`catch(Exception e)`経由で500になる。これは今回意図的にプロダクションコードは修正せず、自動テストで実際の挙動として固定している（`StakingRewardsControllerValidationTest#update_doesNotRejectChangeListElementNullAtValidationLayer`、`StakingRewardsServiceTest#update_throwsNullPointerExceptionWhenChangeListElementIsNull`）。手動テストで500が返ってきても、新規バグではなく既知の制約なので混同しないこと。

---

## ログ目視確認ポイント一覧
w
| ログ文言（先頭部分） | HTTPステータス | 出現するはずのケース |
|---|---|---|
| `account fetch failed: accountId=` | 404 | TC-E06（GET/POST共通） |
| `口座ステータスが正しくありません。: accountId=` | 200(空リスト)/417 | TC-E07 |
| `staking rewards change invalid request: accountId=` | 400 | TC-E08（①②③いずれも） |
| `staking rewards fetch failed.: accountId=` | 500 | GET側の想定外エラー時のみ。手動では再現困難なため、自動テスト（`getStakingRewardsEntryList_returnsInternalServerErrorOnException`）でのみ検証済み |
| `staking rewards change failed.: accountId=` | 500 | POST側の想定外エラー時のみ。TC-E09bはこのログを経由して500になる（想定内）。それ以外のケースでは出現しないことを確認する |

---

## 一括実行スクリプト（bash）

```bash
#!/bin/bash
BASE_URL="http://localhost:21002"
ACCOUNT_ID="10000008"

echo "=== TC-E01: 初回取得 ==="
curl -s -X GET "${BASE_URL}/staking/${ACCOUNT_ID}" | jq

echo "=== TC-E02: JPYSC受取へ変更 ==="
curl -s -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{
  "accountId": "'${ACCOUNT_ID}'",
  "changeList": [{"currency": "ETH", "isRewardRejection": false, "receivedCurrency": "JPYSC"}]
}' | jq

echo "=== 反映確認 ==="
curl -s -X GET "${BASE_URL}/staking/${ACCOUNT_ID}" | jq

echo "=== TC-E03: 同日中に別の値へ再変更(上書き確認) ==="
curl -s -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{
  "accountId": "'${ACCOUNT_ID}'",
  "changeList": [{"currency": "ETH", "isRewardRejection": false, "receivedCurrency": "USDC"}]
}' | jq

echo "=== TC-E04: 拒否設定へ変更 ==="
curl -s -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{
  "accountId": "'${ACCOUNT_ID}'",
  "changeList": [{"currency": "ETH", "isRewardRejection": true, "receivedCurrency": "JPYSC"}]
}' | jq

echo "=== 反映確認(receivedCurrencyがnullになっているか) ==="
curl -s -X GET "${BASE_URL}/staking/${ACCOUNT_ID}" | jq

echo "=== TC-E06: 存在しない口座番号(GET/POSTとも404になることを確認) ==="
curl -s -o /dev/null -w "GET  status=%{http_code}\n" -X GET "${BASE_URL}/staking/99999999"
curl -s -o /dev/null -w "POST status=%{http_code}\n" -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{"accountId":"99999999","changeList":[{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"ETH"}]}'

echo "=== TC-E08: receivedCurrency未指定と変換先不正でメッセージが異なることを確認 ==="
curl -s -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{"accountId":"'${ACCOUNT_ID}'","changeList":[{"currency":"ETH","isRewardRejection":false}]}' | jq
curl -s -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{"accountId":"'${ACCOUNT_ID}'","changeList":[{"currency":"ETH","isRewardRejection":false,"receivedCurrency":"存在しない銘柄コード"}]}' | jq

echo "=== TC-E09b: changeList要素がnull(既知の制約、500が返るのが正常) ==="
curl -s -o /dev/null -w "status=%{http_code}\n" -X POST "${BASE_URL}/staking/update" -H "Content-Type: application/json" -d '{"accountId":"'${ACCOUNT_ID}'","changeList":[null]}'
```
