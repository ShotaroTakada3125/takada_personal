# ITb 手動テスト: staking_materialized_refresher AWS Batch ジョブ

- **対象バッチ:** `staking_materialized_refresher`
- **作成日:** 2026-07-22
- **関連PR:** signup-batch#98 / signup-infra#50
- **テスト環境:** STG（s25-signup）

---

## 前提条件

- signup-infra PR#50 がマージ済みで `07-05-batch.sh deploy s25-signup` によるスタック更新が完了していること
- signup-batch PR#98 がマージ済みで、GitHub Actions (`awsbatch-deploy.yml`) による初回デプロイが完了していること（ECR へのイメージ push + JobDefinition の新リビジョン登録）
- EventBridge Scheduler によるスケジュール設定が完了していること（TC-06 のみ）

---

## テスト観点一覧

| # | 観点 | 区分 |
|---|------|------|
| TC-01 | インフラリソースが正しく作成されていること | インフラ確認 |
| TC-02 | ジョブが正常に実行・完了すること | 正常系 |
| TC-03 | CloudWatch Logs にすべての処理ログが出力されること | 正常系 |
| TC-04 | refresh 対象のマテリアライズドビューが 16 件すべて更新されること | 正常系 |
| TC-05 | refresh が途中で失敗した場合、ジョブが即座に失敗すること | 異常系 |
| TC-06 | EventBridge Scheduler による自動起動が正しく動作すること | スケジュール |

---

## TC-01: インフラリソースが正しく作成されていること

**目的:** CloudFormation で定義した 3 リソースが意図した設定値で AWS 上に存在することを確認する。

### 手順

1. AWS コンソール → CloudFormation → スタック一覧を開く
2. `s25-signup-batch` スタックを選択し、ステータスが `UPDATE_COMPLETE` であることを確認する
3. AWS コンソール → AWS Batch → コンピューティング環境 を開く
4. `s25-signup-staking-materialized-refresher-compute-env` が存在することを確認する
5. 同環境の設定を開き、以下を確認する
6. AWS コンソール → AWS Batch → ジョブキュー を開く
7. `s25-signup-staking-materialized-refresher-job-queue` が存在することを確認する
8. AWS コンソール → AWS Batch → ジョブ定義 を開く
9. `s25-signup-staking-materialized-refresher-job-definition` の最新リビジョンを開き、設定を確認する

### 想定結果

| 確認項目 | 期待値 |
|---|---|
| ComputeEnvironment 名 | `s25-signup-staking-materialized-refresher-compute-env` |
| ComputeEnvironment タイプ | MANAGED / EC2 |
| MinvCpus | 0 |
| MaxvCpus | 16 |
| DesiredvCpus | 0 |
| InstanceType | optimal |
| JobQueue 名 | `s25-signup-staking-materialized-refresher-job-queue` |
| JobQueue ステータス | ENABLED |
| JobDefinition 名 | `s25-signup-staking-materialized-refresher-job-definition` |
| JobDefinition コマンド | `python /code/main.py` |
| vCpus | 2 |
| Memory | 1024 MB（STG）|
| ECR イメージ | `{AccountId}.dkr.ecr.ap-northeast-1.amazonaws.com/s25-signup-aws-batch-repo:staking_materialized_refresher-{タグ}` |

---

## TC-02: ジョブが正常に実行・完了すること

**目的:** ジョブを手動 submit し、SUCCEEDED で終了することを確認する。

### 手順

1. AWS コンソール → AWS Batch → ジョブ を開く
2. 「ジョブの送信」をクリックする
3. 以下を設定してジョブを submit する
   - ジョブ名: 任意（例: `test-staking-refresher-20260722`）
   - ジョブ定義: `s25-signup-staking-materialized-refresher-job-definition`（最新リビジョン）
   - ジョブキュー: `s25-signup-staking-materialized-refresher-job-queue`
4. submit 後、ジョブの状態を監視する（SUBMITTED → PENDING → RUNNABLE → STARTING → RUNNING → SUCCEEDED の順に遷移する）
5. ジョブが SUCCEEDED になったことを確認する
6. ジョブ詳細の「実行時間」を記録する

### 想定結果

- ジョブのステータスが **SUCCEEDED** になること
- SUBMITTED から SUCCEEDED までの全遷移が完了すること
- 実行時間がSTG環境で現実的な範囲（目安: 数分以内）に収まること

---

## TC-03: CloudWatch Logs にすべての処理ログが出力されること

**目的:** 各マテリアライズドビューの refresh 開始・終了ログが正しく記録されていることを確認する。

### 手順

1. TC-02 でジョブが SUCCEEDED になった後、ジョブ詳細画面を開く
2. 「ログ」タブを選択し、CloudWatch Logs のリンクを開く（または AWS コンソール → CloudWatch → ロググループ で対象ロググループを直接開く）
3. ログストリームを開き、全ログを確認する
4. 以下のログが出力されていることを確認する

### 想定結果

以下のログが**この順番で**出力されていること（計 34 行 + 開始・終了ログ）:

```
staking_materialized_refresher start
refresh materialized view start: fx_c_day_margin_status_ccy_dot
refresh materialized view done: fx_c_day_margin_status_ccy_dot
refresh materialized view start: fx_c_day_margin_status_ccy_ada
refresh materialized view done: fx_c_day_margin_status_ccy_ada
refresh materialized view start: fx_c_day_margin_status_ccy_avax
refresh materialized view done: fx_c_day_margin_status_ccy_avax
refresh materialized view start: fx_c_day_margin_status_ccy_eth
refresh materialized view done: fx_c_day_margin_status_ccy_eth
refresh materialized view start: fx_c_day_margin_status_ccy_sol
refresh materialized view done: fx_c_day_margin_status_ccy_sol
refresh materialized view start: fx_c_day_margin_status_ccy_oas
refresh materialized view done: fx_c_day_margin_status_ccy_oas
refresh materialized view start: fx_c_day_margin_status_ccy_atom
refresh materialized view done: fx_c_day_margin_status_ccy_atom
refresh materialized view start: fx_c_day_margin_status_ccy_xdc
refresh materialized view done: fx_c_day_margin_status_ccy_xdc
refresh materialized view start: fx_c_day_margin_status_ccy_flr
refresh materialized view done: fx_c_day_margin_status_ccy_flr
refresh materialized view start: fx_c_day_margin_status_ccy_apt
refresh materialized view done: fx_c_day_margin_status_ccy_apt
refresh materialized view start: fx_c_day_margin_status_ccy_hbar
refresh materialized view done: fx_c_day_margin_status_ccy_hbar
refresh materialized view start: fx_c_day_margin_status_ccy_near
refresh materialized view done: fx_c_day_margin_status_ccy_near
refresh materialized view start: fx_c_day_margin_status_ccy_trx
refresh materialized view done: fx_c_day_margin_status_ccy_trx
refresh materialized view start: fx_c_day_margin_status_ccy_sui
refresh materialized view done: fx_c_day_margin_status_ccy_sui
refresh materialized view start: fx_c_day_margin_status_ccy_ton
refresh materialized view done: fx_c_day_margin_status_ccy_ton
refresh materialized view start: fx_c_day_margin_status_ccy_algo
refresh materialized view done: fx_c_day_margin_status_ccy_algo
staking_materialized_refresher done
```

- `start` と `done` のペアが **16 件すべて** 出力されていること
- エラーログ（`ERROR` / `Exception` / `Traceback` 等）が出力されていないこと
- `get SIGNUP_DSN value from secrets` のログが出力されていること（Secrets Manager から DSN 取得成功の確認）

---

## TC-04: refresh 対象のマテリアライズドビューが 16 件すべて更新されること

**目的:** DB 上でマテリアライズドビューのデータが実際に更新されていることを確認する。

### 手順

1. TC-02 のジョブ実行**前**に、STG DB に接続し、以下の SQL を実行して各マテリアライズドビューの存在と件数を記録する

   ```sql
   -- マテリアライズドビューの存在確認
   SELECT matviewname
   FROM pg_matviews
   WHERE matviewname LIKE 'fx_c_day_margin_status_ccy_%'
   ORDER BY matviewname;
   ```

   ```sql
   -- 代表ビュー（例: dot）の行数確認
   SELECT count(*) FROM fx_c_day_margin_status_ccy_dot;
   ```

2. TC-02 のジョブを実行する（SUCCEEDED まで待つ）

3. ジョブ完了後、TC-03 の CloudWatch Logs で 16 件すべての `refresh materialized view done:` ログが出力されていることを確認する（ログが更新成功の主要エビデンス）

4. 必要に応じて、ジョブ実行後に DB の行数を再確認し、データが消えていないことを確認する

### 想定結果

- 対象の 16 マテリアライズドビューが DB に存在すること（16 件返却）
- ジョブ実行後、各マテビューの行数が 0 でないこと（データが空にならないこと）
- TC-03 のログで 16 件すべての `done` が確認できること（これが実質的な「更新成功」の確認）

> **補足:** PostgreSQL ではマテリアライズドビューの最終 refresh 時刻を標準的に取得する手段がないため、更新成功の確認は主に TC-03（ログ）で行う。

---

## TC-05: refresh が途中で失敗した場合、ジョブが即座に失敗すること

**目的:** autocommit 設定により成功済みビューはロールバックされず、かつ失敗検知後にジョブが FAILED になることを確認する。（STG 確認済みのため、エビデンスの確認で代替可）

### 手順（エビデンス確認による代替）

1. signup-batch PR#98 の「テスト内容」セクションにある「refreshが失敗したときにジョブが即座に失敗すること」のエビデンス画像を確認する
   - ジョブが FAILED になっていることをスクリーンショットで確認する
   - CloudWatch Logs でエラーが発生した銘柄名と、その前に成功済みの銘柄ログが出力されていることを確認する

2. （オプション：直接確認したい場合）STG DB で対象マテリアライズドビューのうち 1 件を一時的に DROP し、ジョブを実行する
   - ジョブが FAILED になることを確認する
   - DROP していないビューのrefreshはコミット済みであることを DB で確認する
   - テスト後、DROP したビューを再作成する

### 想定結果

- 失敗した銘柄の時点でジョブが即座に FAILED になること
- 失敗した銘柄より前に処理された銘柄の refresh 結果はロールバックされず、DB に反映されたままであること
- CloudWatch Logs に失敗した銘柄名と例外メッセージが出力されること
- `refresh materialized view done:` が出力されていない銘柄（失敗した銘柄以降）が存在すること

---

## TC-06: EventBridge Scheduler による自動起動が正しく動作すること

**目的:** 深夜帯のスケジュールに従ってジョブが自動実行されることを確認する。

### 前提

EventBridge Scheduler の設定が完了していること。

### 手順

1. AWS コンソール → Amazon EventBridge → スケジューラ → スケジュール を開く
2. `staking-materialized-refresher` に関連するスケジュールが存在することを確認する
3. スケジュールの設定を開き、以下を確認する
4. スケジュールの次回実行時刻を確認し、その時刻を記録する
5. 次回実行時刻を過ぎた後、AWS Batch → ジョブ 画面で自動実行されたジョブを確認する

### 想定結果

| 確認項目 | 期待値 |
|---|---|
| スケジュール状態 | ENABLED |
| ターゲット | `s25-signup-staking-materialized-refresher-job-queue` |
| 実行するジョブ定義 | `s25-signup-staking-materialized-refresher-job-definition` |
| スケジュール時刻 | 深夜帯（要確認：設定値に従う） |
| タイムゾーン | Asia/Tokyo（JST）|

- 設定したスケジュール時刻にジョブが自動的に submit されること
- 自動実行されたジョブが SUCCEEDED になること（TC-02 と同様の確認）
- CloudWatch Logs に TC-03 と同様のログが出力されること

---

## 確認エビデンスの記録

テスト実施時は以下のエビデンスを取得・保管すること。

| TC | 取得するエビデンス |
|---|---|
| TC-01 | AWS コンソールの ComputeEnvironment / JobQueue / JobDefinition の設定画面スクリーンショット |
| TC-02 | ジョブ詳細画面（SUCCEEDED 表示）のスクリーンショット、実行時間のメモ |
| TC-03 | CloudWatch Logs の全ログのスクリーンショット（または エクスポート） |
| TC-04 | ジョブ実行前後の SQL 実行結果のスクリーンショット |
| TC-05 | PR#98 エビデンス画像、または直接確認した場合はジョブ FAILED 画面とログ |
| TC-06 | スケジュール設定画面と、自動実行されたジョブの SUCCEEDED 画面のスクリーンショット |
