# ステーキング報酬受取設定API 変更 - フロントエンド引き継ぎ資料

## 背景

ステーキング報酬の受取設定について、これまで「受取/拒否」と「JPYSC変換の要否」という2つの別設定だったUIを、「拒否 / 受取(暗号資産) / 受取(JPYSC)」の**単一プルダウン**に統合する。これに合わせてAPIも4本から2本に統合した。

## APIエンドポイントの変更

| 旧 | 新 |
|---|---|
| `GET /staking/{accountId}` | `GET /staking/{accountId}`（レスポンス形式変更） |
| `GET /staking/conversion/{accountId}` | **廃止**（GETに統合） |
| `POST /staking/update` | `POST /staking/update`（リクエスト形式変更） |
| `POST /staking/conversion/register` | **廃止**（updateに統合） |

`/staking/conversion/*`の2エンドポイントは呼び出し先として存在しなくなる。

---

## GET /staking/{accountId}

### リクエスト
パス変数`accountId`のみ。ボディなし。

### レスポンス（200 OK）

銘柄ごとの配列。**トップレベルが配列**（オブジェクトではない）点に注意。

```json
[
  {
    "currency": "ETH",
    "conversions": ["ETH", "JPYSC", "USDC"],
    "isRewardRejection": false,
    "receivedCurrency": "JPYSC"
  },
  {
    "currency": "FLR",
    "conversions": ["FLR", "JPYSC"],
    "isRewardRejection": true,
    "receivedCurrency": null
  }
]
```

| フィールド | 型 | 説明 |
|---|---|---|
| `currency` | string | 保持銘柄コード（申込銘柄） |
| `conversions` | string[] | **プルダウンの選択肢**。「暗号資産のまま受取」を表す銘柄自身のコードも含む（上記例のETHなら配列内に`"ETH"`が入っている） |
| `isRewardRejection` | boolean | `true`=拒否設定中 |
| `receivedCurrency` | string \| null | 現在の受取銘柄。**拒否時のみ`null`**、それ以外は必ず`conversions`内のいずれかの値が入る |

### プルダウンの組み立て方

1. 選択肢: `拒否` + `conversions`配列の各要素（`conversions`は既に選択可能なものだけが入っているので、フィルタリング不要）
2. 現在選択されている項目の判定:
   - `isRewardRejection === true` → 「拒否」を選択状態にする
   - `isRewardRejection === false` → `conversions`の中から`receivedCurrency`と一致する項目を選択状態にする（`receivedCurrency`は必ず`conversions`のいずれかと一致する）

### 銘柄が未登録（口座を初めて開いた場合）の扱い

エントリが存在しない銘柄は、`isRewardRejection: false`・`receivedCurrency: 銘柄自身のコード`（＝「暗号資産のまま受取」がデフォルト）として返る。フロント側で「未登録時はどう表示するか」を別途考慮する必要はない。

### エラーレスポンス

| ステータス | ケース | レスポンス例 |
|---|---|---|
| `404` | 口座が存在しない | `{"error": 1004, "message": "..."}` |
| `500` | 想定外のサーバーエラー | `{"error": 2000, "message": "..."}` |

**口座ステータスが「口座開設完了」「本登録」以外の場合はエラーにはならず、`200 OK` + 空配列 `[]` が返る。** この場合の画面表示は別途フロント側で検討が必要（設定変更不可の旨を出す等）。

---

## POST /staking/update

### リクエスト

```json
{
  "accountId": "10000008",
  "changeList": [
    { "currency": "ETH", "isRewardRejection": false, "receivedCurrency": "JPYSC" },
    { "currency": "FLR", "isRewardRejection": true }
  ]
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|---|---|
| `accountId` | string | ○ | 8桁の口座番号 |
| `changeList` | array | ○ | 変更する銘柄の配列（変更しない銘柄は含めなくてよい） |
| `changeList[].currency` | string | ○ | 変更対象の保持銘柄コード |
| `changeList[].isRewardRejection` | boolean | ○ | `true`=拒否に変更 |
| `changeList[].receivedCurrency` | string | **`isRewardRejection: false`のときのみ必須** | 受取銘柄。`isRewardRejection: true`の場合は送っても無視される（サーバー側で強制的に無視） |

**重要:** `isRewardRejection: false`で「暗号資産のまま受取」を選びたい場合も、`receivedCurrency`には**銘柄自身のコードを明示的に指定する**（例: ETHをそのまま受け取るなら`receivedCurrency: "ETH"`）。`null`や省略は許可されず、その場合は下記のバリデーションエラー(400)になる。GET側で`receivedCurrency: null`が返ってくることがあるのは既存顧客の後方互換用の値であり、POST時に送るべき値ではない。

### レスポンス

| ステータス | ケース |
|---|---|
| `200` | 成功（ボディなし） |
| `400` | バリデーションエラー（存在しない銘柄、`receivedCurrency`未指定、`conversions`に無い値を指定、など） |
| `404` | 口座が存在しない |
| `417` | 口座ステータスが不正（下記参照） |
| `500` | 想定外のサーバーエラー |

**`400`のレスポンスの`message`は常に固定の汎用メッセージになり、どの入力が悪かったかはレスポンスからは判別できない。** 個別の理由（銘柄不正／受取銘柄未指定／変換先不正のどれか）はサーバー側のログでのみ判別可能。フロント側でエラー原因ごとに表示を分けたい場合、現状のAPIでは不可能なので、必要であれば別途API側の対応検討が必要（現時点ではその対応は未実施）。

### 口座ステータス不正時の挙動差分（GETとの非対称性に注意）

| API | 口座ステータス不正時 |
|---|---|
| `GET /staking/{accountId}` | `200` + 空配列 |
| `POST /staking/update` | `417` + `{"error": 2008, "message": "..."}` |

GET画面表示は正常応答として空配列が返るが、POST（更新操作）は明確にエラーとして417を返す、という非対称な設計になっている。

---

## エラーコード一覧（今回関連するもののみ）

| コード | 定数名 | 意味 |
|---|---|---|
| 1000 | VALIDATION_ERROR | 入力値不正（400） |
| 1004 | ACCOUNT_NOT_REGISTERED | 口座未登録（404） |
| 2000 | UNEXPECTED_ERROR | 想定外エラー（500） |
| 2008 | INVALID_ACCOUNT_STATE | 口座ステータス不正（417、POSTのみ） |

---

## 動作確認済みcurl例

```bash
# 一覧取得
curl -X GET "http://localhost:21002/staking/10000008"

# JPYSCで受け取るように変更
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": false, "receivedCurrency": "JPYSC" }
    ]
  }'

# 拒否に変更
curl -X POST "http://localhost:21002/staking/update" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "10000008",
    "changeList": [
      { "currency": "ETH", "isRewardRejection": true }
    ]
  }'
```

---

## 未対応・確認事項（フロント実装時に留意）

- `POST /staking/update`の400エラーは原因の判別ができない（上記参照）。原因別にUI表示を分けたい場合は要相談。
- `docs/api-docs.yaml`（Swagger）は現状、このエンドポイントの200レスポンススキーマが正しく生成されない既知の問題があり、修正予定（未対応）。API仕様の正とするのは本資料またはコード。
- 口座ステータス不正時のGET（空配列）の画面表示方針は未定義。フロント側で検討が必要。
