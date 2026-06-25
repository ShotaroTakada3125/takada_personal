# 口座開設システム ローカル環境起動手順書

**最終更新:** 2025/11/27

**前提:** Docker Desktopがインストール済みであること。

※ 基本的に**各ステップごとに「新しいターミナルタブ（またはウィンドウ）」を開いて**実行する

---

## 1. データベース & 基盤 (Docker)

1. **Docker Desktop** アプリを起動する。
2. ターミナルを開き、以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/10_github/signup-backoffice

# コンテナ起動 (バックグラウンド)
docker-compose up -d

# 確認 (Stateが Up になっていること)
docker-compose ps

```

---

## 2. メール送信機能の設定 (LocalStack)

ローカルでメール送信機能を利用するための設定です。

### 2-1. ツールインストール

1. Homebrewでawslocalをインストールする（未インストールの場合のみ）。

```shell
brew install awscli-local

```

### 2-2. 送信元メールアドレスの認証

FromやBCC等に指定するEメールアドレスを認証済みにします。

1. **新しいタブ**を開き、LocalStackコンテナの中に入る。

```shell
docker exec -it $(docker ps -qf "name=signup-backoffice-localstack") /bin/bash

```

2. コンテナ内でドメイン・メールアドレスの検証コマンドを実行。

```shell
awslocal ses verify-email-identity --email-address no-reply@sbivc.co.jp
awslocal ses verify-email-identity --email-address stg-support@sbivc.co.jp

```

### 2-3. 送信されたメールの確認方法

1. LocalStackのログを表示して、受信メールのファイルパス（例：`/tmp/localstack/state/ses/aaa-bbb-ccc-ddd-eee-fff-ggg.json`）を確認する。

```shell
docker logs $(docker ps -qf "name=signup-backoffice-localstack")

```

2. コンテナ内に入り、`cat`コマンドで内容を確認する。

```shell
docker exec -it $(docker ps -qf "name=signup-backoffice-localstack") /bin/bash
cat /tmp/localstack/state/ses/aaa-bbb-ccc-ddd-eee-fff-ggg.json

```

---

## 3. Mockサーバー (Simplex擬似環境)

フロントエンドやAPIが参照する外部システムのフリをするサーバー。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/10_github/simplex-py-server

# サーバー起動 (Python)
# 依存ライブラリがPython 3.13環境に入っていることを前提としています
TZ='Asia/Tokyo' python -m uvicorn app.main:app --reload --port 8090 --log-config log_config.yaml

```

* **成功確認:** `Uvicorn running on http://127.0.0.1:8090` と表示されればOK。
* **注意:** このタブは閉じない。

---

## 4. Signup API (バックエンド)

フロントエンドからのリクエストを処理するJavaサーバー。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/10_github/signup-api

# 環境変数のセット (asdfのJavaパスを指定)
export JAVA_HOME=$(asdf where java)

# アプリケーション起動
./mvnw clean spring-boot:run -Dspring-boot.run.profiles=dev,ext-stg

```

---

## 5. Signup Backoffice (管理画面API)

社内用管理画面のバックエンド。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# 環境変数を読み込んでから、サーバーを起動
source .envrc.local
./gradlew :inhouse-app:bootRun

cd ~/Desktop/10_github/signup-backoffice/module/inhouse-client
NODE_OPTIONS='--openssl-legacy-provider' yarn serve

```

1行コマンド
```bash
cd ~/Desktop/10_github/signup-backoffice && docker-compose up -d && source .envrc.local && ./gradlew :inhouse-app:bootRun

cd ~/Desktop/10_github/signup-backoffice &&  source .envrc.local && ./gradlew :inhouse-app:bootRun

```

---

## 6. Signup Frontend (申込画面)

ユーザーが触る画面。サーバー側とクライアント側の2つを起動。

### 6-1. フロントエンドサーバー (Express)

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
cd ~/Desktop/10_github/signup-frontend
npm run dev:server

```

### 6-2. フロントエンドクライアント (Webpack)

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
cd ~/Desktop/github/signup-frontend
npm run dev:front

```

---

## 7. (必要に応じて) データベース確認

```bash
docker exec -it signup-postgres psql -U signupadmin -d s25signup

```

---

### ポート番号一覧 (トラブルシューティング用)

| システム | ポート | 用途 |
| --- | --- | --- |
| **Frontend (画面)** | 9000 | ブラウザでアクセスする場所 |
| **Frontend (Server)** | 3000 | フロントエンドの裏側 |
| **Backoffice** | 8084 | 管理画面 |
| **Mock Server** | 8090 | 外部システム連携用 |
| **Signup API** | 21002 | メインAPI |
| **PostgreSQL** | 5432 | データベース |
| **LocalStack** | 4566 | AWS疑似サービス(SES等) |