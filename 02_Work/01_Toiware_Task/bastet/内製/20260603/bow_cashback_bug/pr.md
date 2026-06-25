# ステーキング手数料キャッシュバック額照会検索 - システムエラー対応

**作成日**: 2026年4月15日
**対象画面**: ステーキング手数料キャッシュバック額照会検索
**ステータス**: 修正完了

---

## 1. 事象

### ユーザーの操作フロー
1. 銘柄を選択して検索
   - `search-cashback-list` API が実行される ✅
   - `cashback-total` API が実行される ✅
   - 正常終了

2. 入力欄の ×ボタンを押して銘柄をクリア

3. 再度検索ボタンを押下
   - `cashback-total` API のみが実行される ❌
   - **システムエラー（RE）が画面下に表示される** 🚨

### 症状
```
画面下に表示されるエラー：システムエラー（RE）
ユーザーに与える影響：画面操作が中断され、再度操作が必要になる
```

---

## 2. 根本原因

### フロントエンド側の不具合
**ファイル**: `module/inhouse-client/src/views/StakingRewardsCashback.vue`

#### 原因の詳細
```javascript
async searchStakingRewardsList($serverPagination) {
    // 1. 前回の検索で銘柄「ETH」を選択 → rowsNumber に結果件数が保存される

    await this.searchStakingCashbackRewards($serverPagination);
    // 2. 銘柄を×でクリア（currency: null）→ バリデーション失敗
    //    ただし、前回の rowsNumber 値が残ったまま

    if (this.serverPagination.rowsNumber > 0) {  // ← この条件が true
      // 3. 銘柄未選択のまま getCashbackTotal() が呼び出される
      await this.getCashbackTotal();             // ← エラー発生
    }
}
```

**問題点**：
バリデーション失敗時に、前回の検索結果（`rowsNumber`）がクリアされないため、誤ってクオーターバック合計金額を取得しようとする。

---

## 3. API リクエストの比較

### 正常系（銘柄選択時）
```json
{
  "cashbackAccountsCsvData": [],
  "cashbackRatesCsvData": [],
  "currency": "ETH",        // ✅ 銘柄が指定されている
  "accountId": ""
}
```

### 異常系（銘柄未選択で再検索時）
```json
{
  "cashbackAccountsCsvData": [],
  "cashbackRatesCsvData": [],
  "currency": null,         // ❌ 銘柄が null
  "accountId": ""
}
```

---

## 4. 修正内容

### 修正1️⃣: バックエンド側（防御的対策）

**ファイル**: `module/core/src/main/java/jp/co/toiware/cust/domain/logic/StakingRewardsLogic.java`

**修正箇所**: `getCashbackTotal(StakingRewardsCashbackReq req)` メソッド

```java
public StakingCashbackTotalRes getCashbackTotal(StakingRewardsCashbackReq req) {
    // 銘柄の入力チェック
    if (req.getCurrency() == null || req.getCurrency().isEmpty()) {
        throw new AppValidationException(
            "キャッシュバック額の取得には銘柄の指定が必要です。銘柄を選択し、再度お試しください。");
    }
    return getCashbackTotal(req.getCurrency(), req.getPeriod());
}
```

**効果**:
- API 側で入力値バリデーションを実施
- 銘柄未選択の場合、ユーザーフレンドリーなバリデーションエラーメッセージを返す
- システムエラー（RE）ではなく、対処可能なエラーとなる

---

### 修正2️⃣: フロントエンド側（根本的対策）

**ファイル**: `module/inhouse-client/src/views/StakingRewardsCashback.vue`

**修正箇所**: `searchStakingCashbackRewards($serverPagination)` メソッド

```javascript
async searchStakingCashbackRewards($serverPagination) {
    if (!$serverPagination) {
      // バリデーションチェック
      if (!await this.searchValidationCheck()) {
        // ✅ バリデーション失敗時は検索結果をクリア
        this.tableData = [];
        this.serverPagination = new PageObject.Pagination();
        this.totalCashbackRes = '';
        this.totalStakingRewardsRes = '';
        return;
      }
      this.hasMessage = false;
      $serverPagination = new PageObject.Pagination();
    }
    // ...
}
```

**効果**:
- バリデーション失敗時に、前回の検索結果をリセット
- 次の条件分岐 `if (this.serverPagination.rowsNumber > 0)` が false になる
- 銘柄未選択でも `getCashbackTotal()` が呼び出されない
- フロントエンド側で完全に防止できる

---

## 5. 修正後の動作フロー

### 修正前 ❌
```
1. 銘柄「ETH」選択 → 検索実行 → 成功
   状態: rowsNumber = 50（前回の検索結果が保存）

2. 銘柄をクリア（currency = null）→ 再検索
   - searchStakingCashbackRewards() で バリデーション失敗
   - ただし rowsNumber は変わらない

3. if (rowsNumber > 0) → true（前回の値が残っている）
   - getCashbackTotal(currency=null) を呼び出し
   - エラー発生 🚨
```

### 修正後 ✅
```
1. 銘柄「ETH」選択 → 検索実行 → 成功
   状態: rowsNumber = 50

2. 銘柄をクリア（currency = null） → 再検索
   - searchStakingCashbackRewards() で バリデーション失敗
   - ✅ rowsNumber をリセット = 0

3. if (rowsNumber > 0) → false（値がクリアされた）
   - getCashbackTotal() は呼び出されない
   - エラーは発生しない ✅
```

---

## 6. 検証ポイント

修正後の動作を検証するには、以下のステップで確認してください：

### テスト手順

| # | 操作 | 期待結果 | 確認項目 |
|---|------|--------|--------|
| 1 | 銘柄「ETH」選択 → 検索 | データが表示される | API成功 |
| 2 | 入力欄の ×ボタンで銘柄クリア | 検索結果がクリアされる | 画面上の表示がリセット |
| 3 | 再度検索ボタン押下 | バリデーションエラーメッセージ表示 | システムエラーではない |
| 4 | 銘柄を選択後に通常検索 | データが正常に表示される | 機能は正常 |

---

## 7. 影響範囲

### 修正対象画面
- ステーキング手数料キャッシュバック額照会検索

### 利用ユーザー
- オペレーション担当者（管理画面ユーザー）

### ビジネス影響
- **修正前**: 銘柄未選択で再検索するとシステムエラーが発生 → 業務中断
- **修正後**: 入力チェックが機能し、ユーザーに対して適切なエラーメッセージを表示 → 業務継続可能

---

## 8. 機密情報の取り扱い

本修正は、**機密情報を直接ログに出力しない**ようになっています。

- ✅ `currency` などのパラメータもログに記録されない（バリデーションで早期で停止）
- ✅ ユーザーに返すエラーメッセージは、業務的な内容のみ
- ✅ システムレベルの詳細情報は、バックエンドログにのみ記録

---

## 9. 今後の予防措置

同様の問題を防ぐため、以下の対策を検討してください：

1. **入力値バリデーションの統一化**
   - 必須パラメータには、API側でも画面側でも必ずチェックを入れる

2. **状態管理の明確化**
   - フロント側で検索結果の状態(`rowsNumber`など)は、新規検索実行時に必ずリセット

3. **テスト自動化**
   - 銘柄未選択での検索パターンをテストケースに追加

---

**修正完了日**: 2026年4月15日
**テスト実施**: 対応チーム側で確認予定
