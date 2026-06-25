## 対応内容

株主優待キャンペーンの共通化を実装しました。複数の株主優待キャンペーンで共通利用可能なアクション・コンポーネントを整備し、キャンペーン追加時の開発コストを削減します。

### 実装内容

**1. 共通アクション (`client/actions/stockholderCampaign.js`)**
- `simpleLoginForStockholderCampaign()` - 株主優待キャンペーン用ログイン処理
  - Simplexログイン後、申込可否チェックAPIを呼び出し、チェック結果に基づいて分岐
  - チェックOK時は2要素認証画面へ遷移
- `checkUnauthorizedNavigation()` - 不正遷移チェック（直リンク検出）
- `checkAccount()` - 申込可否チェックAPI呼び出し
- `setBasic()` - 入力値検証API呼び出し
- `post()` - 株主優待申込API呼び出し
- `get()` - 申込済みデータ取得API呼び出し
- `validateSetBasic()` - クライアント側バリデーション（`constants/stockholderCampaign.js`の検証スキーマに基づく）
- 各API呼び出しの request/success/failure アクション

**2. 共通コンポーネント**
- `client/components/Form/StockholderCampaign/Input/` - ログイン画面（/{keyword}/{term}/input）
  - メールアドレス・パスワード入力フォーム
  - Simplex ログイン処理呼び出し
- `client/components/Form/StockholderCampaign/Confirm/` - 申込確認画面（/{keyword}/{term}/confirm）
  - API②のレスポンス情報と入力内容の確認表示
  - 申込実行ボタン
- `client/components/Form/StockholderCampaign/Refer/` - 申込照会画面（/{keyword}/{term}/refer）
  - 申込済みデータの表示

**3. Loading コンポーネント修正**
- 新しい株主優待キャンペーン用アクション（`failureCheckAccount`, `failureSetBasic`, `failurePost`, `failureGet`）の追加
- `requestCheckAccount`, `requestSetBasic`, `requestPost`, `requestGet` の追加
- ローディング画面で各種リクエスト状態を適切に表示

### 設計に基づく実装

設計書で定義された以下の画面フロー・API連携を実装：
- ① 株主優待申込ログイン（/{keyword}/{term}/input）→ API①申込可否チェック → 2要素認証 → ②へ遷移
- ② 株主優待申込入力画面（/{keyword}/{term}/entry）→ API②入力値検証 → ③へ遷移
- ③ 株主優待申込確認（/{keyword}/{term}/confirm）→ API③申込実行
- ④ 株主優待申込照会ログイン（/{keyword}/{term}/check）→ ⑤へ遷移
- ⑤ 株主優待申込照会確認画面（/{keyword}/{term}/refer）→ API④申込済みデータ取得

## 対応残

### 実装予定の項目

1. **入力画面（Entry）の共通コンポーネント化**
   - 現在、入力フォームはキャンペーンごとに個別実装が必要
   - 今後、`constants/stockholderCampaign.js`のフィールド定義に基づいて動的にフォームを生成する共通コンポーネント化を検討

2. **constants/stockholderCampaign.js の実装**
   - アクション定数（REQUEST_CHECK_ACCOUNT等）の定義
   - キャンペーン定義とバリデーション定義の整備

3. **reducers/stockholderCampaign.js の実装**
   - 共通 Reducer の実装

4. **キャンペーン固有ロジックの分離**
   - 入力画面②では、文字種・桁数・同意チェックボックスのバリデーション等、キャンペーンごとに異なるロジックは個別実装が必要
   - 各キャンペーン用 actions/validators の準備

## 影響範囲・類似事象の確認

### 既存機能への影響
- **なし** - 新規ファイルの追加であり、既存のキャンペーン実装に対する変更はありません

### 今後のキャンペーン追加時

新規キャンペーン追加時は、以下の最小限の実装で対応可能：

1. **constants/stockholderCampaign.js** に新キャンペーンの定義を追加
2. **components/Form/StockholderCampaign/Entry/** に入力フォーム（キャンペーン固有）を実装
3. **actions/stockholderCampaign.js** に必要に応じてキャンペーン固有のバリデーションロジックを追加
4. ルーティング設定（共通で対応予定）

### 類似事象
- 他の申し込みフロー（DMM、ANAP等）でも同様の共通化を検討できますが、現時点では株主優待に限定します

## テスト内容

### ユーザー操作フロー

**パターン1: 正常な申込フロー**
1. ログイン画面でメールアドレス・パスワードを入力してログイン
2. 2要素認証を完了
3. 入力画面に遷移し、申込コード・パスワードを入力
4. 確認画面で内容を確認して「申込む」をクリック
5. 申込完了アラートが表示され、ログイン画面に遷移

**パターン2: 申込可否チェック NG**
1. ログイン画面でメールアドレス・パスワードを入力
2. APIからエラーメッセージが返却（例：既に申込済み）
3. エラーメッセージをアラート表示
4. 通常ログイン画面に遷移

**パターン3: 直リンク（不正遷移）**
1. 直接 `/{keyword}/{term}/entry` にアクセス
2. 不正遷移チェックで検出
3. ログイン画面に遷移

**パターン4: 申込済みデータ照会**
1. 照会用ログイン画面でログイン
2. 2要素認証を完了
3. 照会画面に遷移し、申込済みデータを表示

### API テスト

- 各APIエンドポイントの呼び出し成功
  - `/api/stockholder_bonus_entry/account_check` (GET)
  - `/api/stockholder_bonus_entry/entry_check` (POST)
  - `/api/stockholder_bonus_entry` (GET: 申込実行、POST: データ取得)

- エラーハンドリング
  - API返却値 status !== 200 時の適切なエラーメッセージ表示
  - null 返却値への対応

### レグレッション テスト

- 既存キャンペーン（DMM、ANAP等）の正常動作確認
- Loading コンポーネント修正による、他アクションのローディング表示確認
