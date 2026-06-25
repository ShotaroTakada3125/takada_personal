
## 環境一覧および接続先情報

各環境のURL、GitHub Workflow、識別子、およびSXI（バックエンドAPI）の接続先構成は以下の通りです。

| URL | GitHub Workflow | VCT内PJ識別子 | SXI 向き先 |
| --- | --- | --- | --- |
| [https://stg-simple.sbivc.co.jp/](https://stg-simple.sbivc.co.jp/) | stg1 | s7 | stg3-aws-trader |
| [https://stg2-simple.sbivc.co.jp/](https://stg2-simple.sbivc.co.jp/) | stg2 | s15 | stg2-aws-trader |
| [https://stg1-aws-simple.sbivc.co.jp/](https://stg1-aws-simple.sbivc.co.jp/) | stg3 | s28 | stg-aws-trader |




* **注意点（SXI接続先）**
* `stg-simple`は、GitHub Workflowでは「stg1」と呼称されますが、SXIやテスター間では「simple 3面」と呼ばれることがあります。これはSXIの向き先が「3面（stg3-aws-trader）」に接続されているためです。
* 上記テーブルの通り、Workflow上の名称と実際のSXI接続先には乖離があるため、設定変更や調査の際は注意してください。
* ※`stg1-aws-simple` のデフォルトSXI-API向き先は `stg-aws-trader` となっています。