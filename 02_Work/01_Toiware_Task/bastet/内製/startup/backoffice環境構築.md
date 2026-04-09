# 📝 備忘録：signup-backoffice 環境構築ログ
1. 前提・ツール準備
- リポジトリ: signup-backoffice を使用
- ブランチ: adamas ブランチを使用（READMEの古い指示 change-readme は無視）
- バージョン管理ツール (asdf):
    - asdf をインストールし、プロジェクトディレクトリで以下を設定。
    - Node.js: v22.11.0
    - Java: zulu-8.82.0.21 (Java 8)
- パッケージマネージャー:
    - npm の代わりに yarn を使用（エラー回避のため npm install -g yarn で導入）

2. 実施した手順と回避策
    1. DB構築:
        - Oracleの手順は無視し、DockerでPostgreSQLを起動
        - コマンド: docker-compose up
    2. フロントエンドの依存解決:
        - Gradle自動実行の npm install が失敗するため、手動で対応。
        - module/inhouse-client に移動し、node_modules を削除してから yarn install を実行。
    3. バックエンド起動:
        - コマンド: ./gradlew :inhouse-app:bootRun
    4. フロントエンド起動（開発用）:
        - コマンド: npm run serve --prefix ./module/inhouse-client


## 今後の起動手順
1. Docker Desktopアプリ起動~DB立ち上げ
```bash
cd ~/Desktop/10_github/signup-backoffice
docker-compose up -d
docker-compose ps
```

2. サーバサイド起動
プロジェクト直下で以下コードを実行。これは起動しっぱなしにする。
Started InhouseAppApplication... と出たら起動成功。
```bash
source .envrc.local
./gradlew :inhouse-app:bootRun
```
Started InhouseAppApplication... と出たら起動成功

3. フロントエンド起動
```bash
cd ~/Desktop/10_github/signup-backoffice
npm run serve --prefix ./module/inhouse-client
```