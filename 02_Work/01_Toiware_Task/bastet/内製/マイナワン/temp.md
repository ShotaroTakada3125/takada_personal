
現ブランチ feature/yen_staking_client の実装を前提に、staking_rewards_total の列と、通常報酬の最終付与額計算との関係を整理します。

**staking_rewards_total の各カラム**
定義元: V20250226_1089__create_staking_rewards_total.sql

1. id  
管理番号（主キー、自動採番）

2. currency  
通貨コード。例: DOT, ETH など。  
同一期間での一意制約は currency + period

3. period  
対象期間（YYYYMM）。  
実運用上は先月分を扱う設計で、CSV登録時も先月を使います。  
参照: TotalStakingRewardsReq.java

4. total_rewards  
顧客報酬総額。  
通常報酬の按分計算の元になる「全体原資」です。

5. customer_rewards_rate  
顧客報酬割合（%）。  
total_rewards に掛けて、顧客向け配賦総額を作るための割合です。

6. register_datetime  
登録日時

7. register_user  
登録者

8. update_datetime  
更新日時

9. update_user  
更新者

10. delete_flag  
論理削除フラグ

11. version  
楽観ロックなどで使うバージョン

補足: 一意制約は currency, period  
参照: V20250226_1089__create_staking_rewards_total.sql

**どこで値が入るか**
1. 画面のCSV入力は currency, totalRewards, customerRewardsRate を送信  
参照: StakingRewardsList.vue

2. サーバで currency + period をキーに upsert し、totalRewards と customerRewardsRate を保存  
参照: StakingRewardsLogic.java

**最終付与額計算の登場人物**
計算本体: R__staking_rewards__view.sql

1. ccy  
口座ごとの先月現金残高合計（分母/分子の元データ）

2. staking_rewards_total (srt)  
total_rewards, customer_rewards_rate を供給（今回の主役テーブル）

3. srx  
除外設定（is_exclusion）

4. sre_latest  
受取拒否設定（is_reward_rejection）の最新値

5. srd  
付与設定（is_distribution）

6. sum_sraa  
追加口座分の残高合計（分母に加算）

7. total_calc  
通常口座（除外除く）の合計残高（分母）

**計算方法（通常報酬）**
R__staking_rewards__view.sql で次の順に計算されます。

1. received_rewards  
条件:
- srt.total_rewards が null または 0 なら 0
- 除外口座なら 0
それ以外:
- (ROUND(total_rewards × customer_rewards_rate / 100, 6) / (通常口座合計残高 + 追加口座合計残高)) × 当該口座残高

2. distribution_rewards  
受取拒否なら 0、それ以外は received_rewards

3. last_distribution_rewards  
受取拒否 または 付与しない設定 なら 0、それ以外は received_rewards

根拠: R__staking_rewards__view.sql

**集計側（合計金額）**
最終付与総額は staking_rewards_view の last_distribution_rewards を通貨・期間で SUM した値です。  
参照: R__staking_rewards_total_view.sql

補足として、このブランチの staking_rewards_total には jpy_rate カラムは存在しません（少なくとも PostgreSQL DDL と Entity 上）。  
参照: V20250226_1089__create_staking_rewards_total.sql, StakingRewardsTotal.java

必要なら次に、実データ例を1口座分で数式に代入して、どの値がどこから来るかを表形式で具体化します。










- フロント修正方針検討：0.5日
- 3択プルダウンの新規コンポーネント作成（既存のSelectfieldを流用）：0.5日
- 拒否設定と受取銘柄設定をcurrencyキーで統合し、表示用の3択（拒否/暗号資産/JPYSC）に変換するロジック：0.5日
- 送信ロジック：1日
  - 3択の選択値→2つのPOST APIのリクエスト(changeList)へ分解
  - 呼び出し順序（update→conversion/register）
  - 拒否時はupdateのみ（conversion呼び出しをスキップ）
  - 失敗時にGET apiを2つ ＋エラーアラート
- マイページの差し替え（個人/法人）：0.5日
- 動作確認＋レビュー修正：1日






これから新しくチームに参加するメンバーが、迷わず一発で環境構築を完了できるように手順をまとめました！

このリポジトリ（`bastet-ai-workbench`）には、すでにチーム共通の設定ファイル（`workspace.yml`）が用意されているため、新メンバーは**ダウンロードして初期化スクリプトを流すだけ**で構築が完了します。

そのままSlackやWikiにコピペして使える形式にしていますので、ぜひご活用ください！

---

# 🚀 bastet-ai-workbench ローカル環境構築手順

この手順は、`bastet` プロジェクトでAIアシスタント（Claude Code）を使った開発・レビュー環境をローカルに構築するためのガイドです。

## 📋 STEP 0. 事前準備（前提ツールの導入）

まずは、ワークベンチを動かすために必要なツールを Mac にインストールします。ターミナルを開き、以下のコマンドを順番に実行してください。

```bash
# 1. Homebrew が入っていない場合は先にインストールしてください
# 2. 必要な共通ツールをまとめてインストール
brew install yq jq gh

# 3. Claude Code（AIアシスタント本体）をインストール
brew install --cask claude-code

```

> ⚠️ **注意**: `gh` CLI をインストールした後は、必ず `gh auth login` を実行して、GitHub へのログインと認証を済ませておいてください。

---

## 🛠️ 構築の3ステップ

### STEP 1. リポジトリをクローンする

普段、開発用のソースコードを置いている親ディレクトリ（例: `~/Desktop/10_github` や `~/src` など）に移動し、リポジトリをクローンします。

```bash
# 普段コードを置いている場所に移動（ご自身の環境に合わせて変えてください）
cd ~/Desktop/10_github

# リポジトリをクローン
git clone git@github.com:toiware/bastet-ai-workbench.git

```

---

### STEP 2. チーム用初期化スクリプトを実行する

クローンしたフォルダに入り、チームメンバー用の初期化スクリプトを実行します。これ一本で、必要なツールの検査と、開発対象となる13個のサブリポジトリの自動ダウンロードがすべて行われます!

```bash
# フォルダに移動
cd bastet-ai-workbench

# チーム用の初期化を実行
./scripts/init.sh

```

実行後、画面の一番下に **「初期セットアップ結果：クローン成功 (13)」** とズラリと表示されれば成功です！

---

### STEP 3. AIアシスタント（Claude）を起動する

セットアップが完了したら、さっそく起動してみましょう。

```bash
claude

```

これでチーム共通のルールや便利な自動コマンドが搭載された、最新の Claude Code セッションが立ち上がります。

---

## 💡 トラブルシューティング & 補足

* **「`workspace.yml` は既に存在します... 作り直しますか？」と聞かれたら？**
もし誤って `./scripts/setup.sh` を実行してしまうと、この質問が出ます。これは初回構築者用のコマンドなので、必ず **`N`（いいえ）** で終了し、代わりに **`./scripts/init.sh`** を実行してください。


* **サブリポの更新や最新ルールの取得は？**
チームの誰かがルールやサブリポの設定を変更した場合は、このフォルダ（`bastet-ai-workbench`）で `git pull` を行ったあと、再度 `./scripts/init.sh` を実行すれば手元が最新状態に同期されます。