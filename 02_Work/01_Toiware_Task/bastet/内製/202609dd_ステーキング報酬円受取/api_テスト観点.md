# ステーキング報酬円転受取設定 手動テストケース

## テストケース一覧

### 1. 円転対象銘柄一覧取得API

#### TC-001: 正常系 - 初回取得（申請履歴なし）
**目的:** 初めて画面を開いたユーザーが銘柄一覧を取得できることを確認

**手順:**
1. APIを実行
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/10000001"
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- レスポンス例:
  ```json
  [
    {
      "currency": "ETH",
      "jpyConversionEnabled": false
    },
    {
      "currency": "XDC",
      "jpyConversionEnabled": false
    }
  ]
  ```
- 全銘柄の`jpyConversionEnabled`が`false`（デフォルト値）

---

#### TC-002: 正常系 - 申請履歴ありの取得
**目的:** 過去に申請した設定が正しく取得できることを確認

**事前条件:**
```sql
-- ETHの円転設定を有効にしたデータを投入
INSERT INTO staking_rewards_conversion_entry (
  account_id, currency, jpy_conversion_enabled, applied_datetime,
  register_datetime, register_user, update_datetime, update_user, delete_flag, version
) VALUES (
  '10000001', 'ETH', 1, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, '10000001', CURRENT_TIMESTAMP, '10000001', 0, 0
);
```

**手順:**
1. APIを実行
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/10000001"
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- レスポンス例:
  ```json
  [
    {
      "currency": "ETH",
      "jpyConversionEnabled": true
    },
    {
      "currency": "XDC",
      "jpyConversionEnabled": false
    }
  ]
  ```

---

#### TC-003: 異常系 - 存在しない口座番号
**目的:** 不正な口座番号でエラーが返ることを確認

**手順:**
1. APIを実行
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/99999999"
   ```

**期待結果:**
- HTTPステータス: `404 Not Found`
- エラーメッセージに「口座が存在しません」が含まれる

---

#### TC-004: 異常系 - 口座ステータスが仮口座
**目的:** 本口座以外のステータスで空リストが返ることを確認

**手順:**
1. APIを実行（仮口座の口座番号を使用）
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/10000002"
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- レスポンス: `[]` (空配列)
- ログに警告メッセージが出力される

---

### 2. 円転申請登録API

#### TC-101: 正常系 - 初回申請（ETHのみ円転有効）
**目的:** 初めて円転設定を行う場合の正常動作を確認

**手順:**
1. APIを実行
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": true
         },
         {
           "currency": "XDC",
           "jpyConversionEnabled": false
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- DBに新規レコードが作成される
  ```sql
  SELECT * FROM staking_rewards_conversion_entry
  WHERE account_id = '10000001'
  AND currency = 'ETH'
  AND delete_flag = 0;
  ```
- `jpy_conversion_enabled` = `1`
- `applied_datetime` が現在日時
- ログに「新規登録しました」が出力される

---

#### TC-102: 正常系 - 同月内の設定変更（上書き）
**目的:** 同じ月内に設定を変更した場合、既存レコードが上書きされることを確認

**事前条件:**
```sql
-- 今月のデータを投入
INSERT INTO staking_rewards_conversion_entry (
  id, account_id, currency, jpy_conversion_enabled, applied_datetime,
  register_datetime, register_user, update_datetime, update_user, delete_flag, version
) VALUES (
  100, '10000001', 'ETH', 1, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, '10000001', CURRENT_TIMESTAMP, '10000001', 0, 0
);
```

**手順:**
1. APIを実行（ETHの設定をfalseに変更）
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": false
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- 既存レコード（ID=100）の`jpy_conversion_enabled`が`0`に更新される
- `applied_datetime`が更新される
- **新規レコードは作成されない**（既存レコードの上書き）
- ログに「上書きしました」が出力される

---

#### TC-103: 正常系 - 別月の設定変更（新規作成）
**目的:** 月をまたいで設定を変更した場合、新規レコードが作成されることを確認

**事前条件:**
```sql
-- 先月のデータを投入
INSERT INTO staking_rewards_conversion_entry (
  id, account_id, currency, jpy_conversion_enabled, applied_datetime,
  register_datetime, register_user, update_datetime, update_user, delete_flag, version
) VALUES (
  200, '10000001', 'ETH', 1, '2026-05-15 10:00:00',
  '2026-05-15 10:00:00', '10000001', '2026-05-15 10:00:00', '10000001', 0, 0
);
```

**手順:**
1. APIを実行（ETHの設定をfalseに変更）
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": false
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- **新規レコードが作成される**
- 先月のレコード（ID=200）は変更されない
  ```sql
  SELECT COUNT(*) FROM staking_rewards_conversion_entry
  WHERE account_id = '10000001'
  AND currency = 'ETH'
  AND delete_flag = 0;
  -- 結果: 2件（先月と今月のレコード）
  ```
- ログに「新規登録しました」が出力される

---

#### TC-104: 正常系 - 設定変更なし（保存されない）
**目的:** 既存の設定と同じ値を送信した場合、DBが更新されないことを確認

**事前条件:**
```sql
INSERT INTO staking_rewards_conversion_entry (
  id, account_id, currency, jpy_conversion_enabled, applied_datetime,
  register_datetime, register_user, update_datetime, update_user, delete_flag, version
) VALUES (
  300, '10000001', 'ETH', 1, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, '10000001', CURRENT_TIMESTAMP, '10000001', 0, 0
);
```

**手順:**
1. 既存と同じ値でAPIを実行
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": true
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- DBのレコード（ID=300）の`update_datetime`が**更新されない**
- 新規レコードも作成されない

---

#### TC-105: 正常系 - 複数銘柄の一括更新
**目的:** 複数銘柄の設定を同時に変更できることを確認

**手順:**
1. APIを実行
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": true
         },
         {
           "currency": "XDC",
           "jpyConversionEnabled": true
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `200 OK`
- ETHとXDCの両方のレコードが作成される
  ```sql
  SELECT currency, jpy_conversion_enabled FROM staking_rewards_conversion_entry
  WHERE account_id = '10000001'
  AND delete_flag = 0;
  ```

---

#### TC-106: 異常系 - 円転対象外の銘柄を指定
**目的:** 円転対象でない銘柄を指定した場合のエラー処理を確認

**手順:**
1. APIを実行（BTCは円転対象外と仮定）
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000008",
       "changeList": [
         {
           "currency": "BTC",
           "jpyConversionEnabled": true
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `400 Bad Request`
- エラーメッセージ: 「暗号資産情報が存在しません。」

---

#### TC-107: 異常系 - バリデーションエラー（口座番号不正）
**目的:** リクエストパラメータのバリデーションが動作することを確認

**手順:**
1. 不正な口座番号でAPIを実行
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "123",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": true
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `400 Bad Request`
- バリデーションエラーメッセージ {"error":1000,"message":"accountId must match \"\\d{8}\""}

---

#### TC-108: 異常系 - 必須パラメータ欠如
**目的:** 必須パラメータが欠けている場合のエラー処理を確認

**手順:**
1. changeListを送信しない
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001"
     }'
   ```

**期待結果:**
- {"error":1000,"message":"changeList must not be null"}

---

#### TC-109: 異常系 - 口座ステータスが不正
**目的:** 仮口座など不正なステータスの場合のエラー処理を確認

**手順:**
1. 仮口座の口座番号でAPIを実行
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000002",
       "changeList": [
         {
           "currency": "ETH",
           "jpyConversionEnabled": true
         }
       ]
     }'
   ```

**期待結果:**
- HTTPステータス: `417 Expectation Failed`
- エラーコード: `INVALID_ACCOUNT_STATE`
- {"error":2008,"message":"口座状況が不正です。"}

---

### 3. 統合シナリオテスト

#### TC-201: E2Eシナリオ - 初回申請から設定変更まで
**目的:** 実際のユーザー操作を想定した一連の流れを確認

**手順:**
1. 円転設定一覧を取得（初回）
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/10000001"
   ```
   → 全てfalse

2. ETHの円転を有効化
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {"currency": "ETH", "jpyConversionEnabled": true},
         {"currency": "XDC", "jpyConversionEnabled": false}
       ]
     }'
   ```

3. 再度一覧を取得して確認
   ```bash
   curl -X GET "http://localhost:21002/staking/conversion/10000001"
   ```
   → ETHがtrue

4. 同月内にETHを無効化（上書き）
   ```bash
   curl -X POST "http://localhost:21002/staking/conversion/register" \
     -H "Content-Type: application/json" \
     -d '{
       "accountId": "10000001",
       "changeList": [
         {"currency": "ETH", "jpyConversionEnabled": false}
       ]
     }'
   ```

5. DBで同月内のレコード数を確認
   ```sql
   SELECT COUNT(*) FROM staking_rewards_conversion_entry
   WHERE account_id = '10000001'
   AND currency = 'ETH'
   AND DATE_FORMAT(applied_datetime, '%Y-%m') = DATE_FORMAT(CURRENT_TIMESTAMP, '%Y-%m')
   AND delete_flag = 0;
   ```
   → 1件のみ（上書きされている）

**期待結果:**
- 全ステップが正常に完了
- 同月内の設定変更は上書き、別月は新規作成

---

## 境界値・特殊ケース

### TC-301: 月末最終日から月初への跨ぎ
**目的:** 月をまたぐタイミングでの動作確認

**手順:**
1. 月末（例: 2026/06/30 23:59）にデータ投入
2. 月初（例: 2026/07/01 00:01）に設定変更
3. 新規レコードが作成されることを確認

---

### TC-302: 削除済みレコードの扱い
**目的:** 削除フラグがtrueのレコードが取得されないことを確認

**事前条件:**
```sql
-- 削除フラグがtrueのレコードを投入
INSERT INTO staking_rewards_conversion_entry (
  account_id, currency, jpy_conversion_enabled, applied_datetime,
  register_datetime, register_user, update_datetime, update_user, delete_flag, version
) VALUES (
  '10000001', 'ETH', 1, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, '10000001', CURRENT_TIMESTAMP, '10000008', 1, 0
);
```

**手順:**
1. 一覧取得APIを実行

**期待結果:**
- 削除フラグがtrueのレコードは取得されない
- ETHはデフォルト値（false）で返る

---

## APIテスト実行用スクリプト

### 一括実行スクリプト（bash）
```bash
#!/bin/bash

BASE_URL="http://localhost:21002"
ACCOUNT_ID="10000001"

echo "=== TC-001: 初回取得 ==="
curl -X GET "${BASE_URL}/staking/conversion/${ACCOUNT_ID}"
echo -e "\n"

echo "=== TC-101: 初回申請 ==="
curl -X POST "${BASE_URL}/staking/conversion/register" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "'${ACCOUNT_ID}'",
    "changeList": [
      {"currency": "ETH", "jpyConversionEnabled": true},
      {"currency": "XDC", "jpyConversionEnabled": false}
    ]
  }'
echo -e "\n"

echo "=== 設定確認 ==="
curl -X GET "${BASE_URL}/staking/conversion/${ACCOUNT_ID}"
echo -e "\n"
```

---

## チェックリスト

- [ ] TC-001 ~ TC-004: 一覧取得APIの正常系・異常系
- [ ] TC-101 ~ TC-109: 登録APIの正常系・異常系
- [ ] TC-201: E2Eシナリオテスト
- [ ] TC-301 ~ TC-302: 境界値・特殊ケース
- [ ] DBの状態確認（レコード数、値の正確性）
- [ ] ログ出力の確認
- [ ] フロントエンドとの連携確認（別リポジトリ）

---

## 備考

### デバッグ用SQLクエリ

```sql
-- 口座の全申請履歴を時系列で確認
SELECT 
  id,
  currency,
  jpy_conversion_enabled,
  applied_datetime,
  update_datetime,
  delete_flag
FROM staking_rewards_conversion_entry
WHERE account_id = '10000001'
ORDER BY currency, applied_datetime DESC;

-- 同月内の重複レコード確認（本来1銘柄1件のはず）
SELECT 
  currency,
  DATE_FORMAT(applied_datetime, '%Y-%m') as month,
  COUNT(*) as count
FROM staking_rewards_conversion_entry
WHERE account_id = '10000001'
  AND delete_flag = 0
GROUP BY currency, DATE_FORMAT(applied_datetime, '%Y-%m')
HAVING count > 1;
```

### テストデータクリーンアップ

```sql
-- テストデータの削除
DELETE FROM staking_rewards_conversion_entry
WHERE account_id IN ('10000001', '10000002');
```
