# テーブル仕様書作成ガイド

SchemaSpy を用いてテーブル仕様書（スキーマドキュメント）を生成する手順です。

## 📋 前提条件

- Docker がインストールされていること
- ローカル環境で PostgreSQL が起動していること

## 🚀 手順

### 1. PostgreSQL をローカルで起動

```bash
docker-compose up -d postgres
```

既に起動している場合はスキップしてください。

### 2. テーブル仕様書を生成

シェルスクリプトを実行します：

```bash
cd docs/schemaspy
bash generate-db-docs.sh
```

スクリプトが実行する内容：
- Docker で SchemaSpy コンテナを起動
- PostgreSQL データベース `s25signup` からスキーマ情報を取得
- メタデータファイル (`schemaspy-meta.xml`) を適用
- `db_docs_html` ディレクトリに HTML ドキュメントを生成

### 3. 生成されたドキュメントを確認

ブラウザで HTML ファイルを開きます：

```bash
open db_docs_html/index.html
```

またはファイルパスを直指定：
```
docs/schemaspy/db_docs_html/index.html
```

### 4. ドキュメントを圧縮

外部に展開する場合は、`db_docs_html` ディレクトリを ZIP ファイルに圧縮します：

```bash
cd docs/schemaspy
zip -r db_docs.zip db_docs_html/
```

### 5. 圧縮ファイルを確認・移動

圧縮ファイルのサイズを確認：

```bash
ls -lh db_docs.zip
```

必要に応じて他の場所に移動：

```bash
# ホームディレクトリに移動
mv db_docs.zip ~/

# デスクトップに移動
mv db_docs.zip ~/Desktop/
```

## 📝 スクリプト設定

`generate-db-docs.sh` のハードコード値：

| 項目 | 値 |
|------|-----|
| DB ホスト | `host.docker.internal` |
| DB ポート | `5432` |
| データベース名 | `s25signup` |
| ユーザー名 | `signupadmin` |
| パスワード | `signupadmin` |
| スキーマ | `public` |
| SchemaSpy バージョン | `6.2.4` |

## ⚠️ 注意事項

- スクリプト実行時に古い `db_docs_html` ディレクトリは自動的に削除・再生成されます
- PostgreSQL への接続設定を変更する場合は、`generate-db-docs.sh` を編集してください
- `schemaspy-meta.xml` でテーブルやカラムのコメント情報を管理しています

## 🔗 関連ファイル

- `generate-db-docs.sh` - SchemaSpy 実行スクリプト
- `schemaspy-meta.xml` - メタデータ定義ファイル
- `db_docs_html/` - 生成されたドキュメント（ディレクトリ）
