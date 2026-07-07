
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