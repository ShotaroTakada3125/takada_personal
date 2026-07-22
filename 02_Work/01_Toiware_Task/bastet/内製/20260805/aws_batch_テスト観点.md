flr-yearly-report バッチ STG 検証手順

全体の流れ

① (変更がある場合) GHA で STG へイメージをデプロイ
② AWS Batch でジョブを手動サブミット
③ ログ・S3 出力を確認

---
① イメージデプロイ（コード変更がある場合のみ）

GitHub Actions の Deploy aws-batch image ワークフローを手動実行します。

- Repository: signup-batch
- Workflow: Deploy aws-batch image
- パラメータ:
  - env: staging（または staging2 / staging3）
  - function: flr_yearly_report

実行すると以下が自動で行われます:
1. ECR へ Docker イメージをビルド・プッシュ
2. s25-signup-flr-yearly-report-job-definition の新リビジョンを登録

---
② AWS Batch でジョブを手動サブミット

AWS コンソール または AWS CLI で以下のリソースにジョブをサブミットします。

┌────────────────┬─────────────────────────────────────────────┐
│    リソース    │                    名前                     │
├────────────────┼─────────────────────────────────────────────┤
│ Job Queue      │ s25-signup-flr-yearly-report-job-queue      │
├────────────────┼─────────────────────────────────────────────┤
│ Job Definition │ s25-signup-flr-yearly-report-job-definition │
└────────────────┴─────────────────────────────────────────────┘

AWS CLI の場合:

aws batch submit-job \
  --job-name "flr-yearly-report-stg-test" \
  --job-queue "s25-signup-flr-yearly-report-job-queue" \
  --job-definition "s25-signup-flr-yearly-report-job-definition" \
  --container-overrides '{
    "command": ["./get-report-data.sh", "-l", "logs/get-report-data.log", "--utils-dir", "../utils", "2024"]
  }'

- 2024 の部分が 対象年 です。検証したい年に変更してください。
- Job Definition のデフォルトコマンドも 2024 固定なので、年を変える場合は --container-overrides で上書きが必要です。

---
③ 結果確認

ジョブの状態確認:
- AWS コンソール → Batch → Jobs → s25-signup-flr-yearly-report-job-queue
- ステータス: SUBMITTED → PENDING → RUNNABLE → STARTING → RUNNING → SUCCEEDED

ログ確認:
- CloudWatch Logs に出力されます（/aws/batch/job ロググループ）

S3 出力確認:
- バッチ成功後、STG の S3 バケット（s3://<S3_BUCKET>/yearly_trade_report/flr/）に  CSV・PDF が生成されていることを確認
---
注意点

- DB に対象年のデータが必要です。 FLR_EVALUATION_PRICE / FLR_LENDING_OPERATIONAL_STATUS テーブルに指定年のレコードがないと CSV が空になります。
- VDI から AWS CLI を使う場合は、s25-signup-flr-yearly-report-job-queue への b ロールに付与されていることを確認済みです。