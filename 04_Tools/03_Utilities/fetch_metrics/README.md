# rename_metrics_screenshots 取扱説明書

スクリーンショット画像を、決められた8個のファイル名へ一括リネームするツールです。

## 1. できること

- 対象ファイル名パターン
  - スクリーンショット YYYY-MM-DD HH.MM.SS
  - スクリーンショット YYYY-MM-DD HH.MM.SS.png
- 対象日付のファイルのうち最新8件を取得し、時刻の古い順に固定順でリネーム
- ファイル名は `YYYYMMDD_午前/午後_メトリクス名.png` の形式
- 午前/午後の接頭辞を指定、または自動判定
- 設定ファイルで以下を分離管理
  - 対象フォルダ
  - リネーム順（8件）

## 2. 必要環境

- Python 3.8 以上

## 3. ファイル構成

- `rename_metrics_screenshots.py`: 実行スクリプト
- `rename_metrics_config.json`: 設定ファイル

## 4. 設定ファイル

`rename_metrics_config.json` を編集してください。

```json
{
  "target_folder": "/path/to/your/folder",
  "rename_order": [
    "口座開設_ECS_CPUUtilization.png",
    "口座開設_ECS_MemoryUtilization.png",
    "口座開設_DB_CPUUtilization.png",
    "口座開設_DB_FreeableMemory.png",
    "シンプル等_ECS_CPUUtilization.png",
    "シンプル等_ECS_MemoryUtilization.png",
    "シンプル等_DB_CPUUtilization.png",
    "シンプル等_DB_FreeableMemory.png"
  ]
}
```

注意:

- `rename_order` は必ず8件にしてください。
- `target_folder` が存在しない場合はエラーになります。

## 5. 実行方法

作業フォルダへ移動して実行します。

```bash
cd /Users/takada/Desktop/20_takada_personal/04_Tools/03_Utilities/fetch_metrics
```

### 5-1. まずは dry-run（変更内容の確認）

```bash
python3 rename_metrics_screenshots.py auto 20260608 --dry-run
```

以下2つは同じ意味です。

```bash
python3 rename_metrics_screenshots.py --period am --date 20260714 --dry-run
python3 rename_metrics_screenshots.py auto 20260608 --dry-run
```

### 5-2. 本実行

```bash
python3 rename_metrics_screenshots.py auto 20260608
```

## 6. 引数一覧

- 位置引数
  - `period_pos`: `auto | am | pm`
  - `date_pos`: `YYYY-MM-DD` または `YYYYMMDD`
- オプション引数
  - `--config`: 設定ファイルパス（未指定時はスクリプトと同じフォルダの `rename_metrics_config.json`）
  - `--folder`: 対象フォルダを一時的に上書き
  - `--period`: `auto | am | pm`（位置引数の代替）
  - `--date`: `YYYY-MM-DD` または `YYYYMMDD`（位置引数の代替）
  - `--dry-run`: 実際には変更しない
  - `--use-state`: 前回処理時刻より新しいものだけ対象にする

## 7. 自動判定（period=auto）のルール

- 対象フォルダ内に `午前_*.png` が1つでも存在する: 接頭辞は `午後`
- 存在しない: 接頭辞は `午前`

## 8. リネーム順

対象日付の候補のうち最新8件を取得し、時刻の古い順に次の形式で割り当てます。

1. `YYYYMMDD_午前/午後_口座開設_ECS_CPUUtilization.png`
2. `YYYYMMDD_午前/午後_口座開設_ECS_MemoryUtilization.png`
3. `YYYYMMDD_午前/午後_口座開設_DB_CPUUtilization.png`
4. `YYYYMMDD_午前/午後_口座開設_DB_FreeableMemory.png`
5. `YYYYMMDD_午前/午後_シンプル等_ECS_CPUUtilization.png`
6. `YYYYMMDD_午前/午後_シンプル等_ECS_MemoryUtilization.png`
7. `YYYYMMDD_午前/午後_シンプル等_DB_CPUUtilization.png`
8. `YYYYMMDD_午前/午後_シンプル等_DB_FreeableMemory.png`

※ 実際のメトリクス名部分は `rename_metrics_config.json` の `rename_order` を使います。
※ `YYYYMMDD` は対象日付（ハイフンなし）に置き換えられます。

## 9. よくあるエラー

- `対象スクリーンショットが見つかりません。`
  - ファイル名形式が一致しているか確認してください。
- `候補が不足しています。... 候補数=...`
  - 対象日付に一致するファイルが8件未満です。
- `既存ファイルと衝突します: ...`
  - リネーム先の同名ファイルが既に存在します。

## 10. 推奨運用

- 本実行前に必ず `--dry-run` を実施してください。
- 日付は毎回明示指定する運用を推奨します。
