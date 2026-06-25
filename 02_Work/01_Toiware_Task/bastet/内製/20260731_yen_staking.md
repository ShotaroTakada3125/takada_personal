

/staking/conversion/{accountId} と /staking/conversion/register のレスポンスは以下です。

**1. GET /staking/conversion/{accountId}**
- 成功時
  - HTTP: `200 OK`
  - Body: `List<StakingRewardsConversionDto>`（JSON配列）
  - 要素の形式:
    - `currency` (string)
    - `jpyConversionEnabled` (boolean)

```json
[
  {
    "currency": "BTC",
    "jpyConversionEnabled": true
  },
  {
    "currency": "ETH",
    "jpyConversionEnabled": false
  }
]
```

- 失敗時（例外発生時）
  - HTTP: `404 Not Found`
  - Body: 共通エラー形式
    - `error` (number)
    - `message` (string)

```json
{
  "error": 1004,
  "message": "指定された口座は登録されていません。"
}
```

**2. POST /staking/conversion/register**
- 成功時
  - HTTP: `200 OK`
  - Body: なし（empty body）

- 業務エラー時（`registerConversionList` が `res > 0` を返した場合）
  - HTTP: `417 Expectation Failed`
  - Body: 共通エラー形式

```json
{
  "error": 2008,
  "message": "口座状況が不正です。"
}
```

- 例外発生時
  - HTTP: `500 Internal Server Error`
  - Body: 共通エラー形式

```json
{
  "error": 2000,
  "message": "予期していないエラーが発生しました。"
}
```

補足:
- 共通エラー形式は `createErrorResponse(...)` で生成され、`{"error": <code>, "message": "<text>"}` 固定です。
- `error` の具体値は実行時の条件で変わります（上記は代表例）。