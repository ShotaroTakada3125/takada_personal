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

## 2. Mockサーバー (Simplex擬似環境)
フロントエンドやAPIが参照する外部システムのフリをするサーバー。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/github/simplex-py-server

# サーバー起動 (Python)
# 依存ライブラリがPython 3.13環境に入っていることを前提としています
TZ='Asia/Tokyo' python -m uvicorn app.main:app --reload --port 8090 --log-config log_config.yaml
```

* **成功確認:** `Uvicorn running on http://127.0.0.1:8090` と表示されればOK。
* **注意:** このタブは閉じない。

---

## 3. Signup API (バックエンド)
フロントエンドからのリクエストを処理するJavaサーバー。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/github/signup-api

# 環境変数のセット (asdfのJavaパスを指定)
export JAVA_HOME=$(asdf where java)

# アプリケーション起動
./mvnw clean spring-boot:run -Dspring-boot.run.profiles=dev,ext-stg
```

* **成功確認:** ログが流れ、最後に `Started Application in ... seconds` と表示されればOK。
* **注意:** このタブは閉じない。

---

## 4. Signup Backoffice (管理画面API)
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
```

* **成功確認:** `Started InhouseAppApplication in ... seconds` と表示されればOK。
* **アクセス:** [http://localhost:8084/inhouse/login](http://localhost:8084/inhouse/login)
* **注意:** このタブは閉じない。

---

## 5. Signup Frontend (申込画面)
ユーザーが触る画面。サーバー側とクライアント側の2つを起動。

### 5-1. フロントエンドサーバー (Express)
1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/github/signup-frontend

# サーバー起動
npm run dev:server
```

* **成功確認:** `App listening on port 3000!` と表示されればOK。

### 5-2. フロントエンドクライアント (Webpack)
1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# ディレクトリ移動
cd ~/Desktop/github/signup-frontend

# クライアントビルド & 起動
npm run dev:front
```

* **成功確認:** `Compiled successfully` と表示され、ブラウザが起動。
* **アクセス:** [http://localhost:9000/signup](http://localhost:9000/signup)

---

## 6. (必要に応じて) データベース確認
DBの中身を見たい場合は、以下のコマンドを使用。

1. **新しいタブ**を開く (`Cmd + T`)
2. 以下のコマンドを実行。

```bash
# DBコンテナに入る (ユーザー名: signupadmin / DB名: s25signup)
docker exec -it signup-postgres psql -U signupadmin -d s25signup
```

**よく使うSQL:**

```sql
-- アカウントステータス確認
SELECT * FROM account;

-- DBから出る
\q
```

---

### ポート番号一覧 (トラブルシューティング用)

| システム | ポート | 用途 |
| :--- | :--- | :--- |
| **Frontend (画面)** | 9000 | ブラウザでアクセスする場所 |
| **Frontend (Server)** | 3000 | フロントエンドの裏側 |
| **Backoffice** | 8084 | 管理画面 |
| **Mock Server** | 8090 | 外部システム連携用 |
| **Signup API** | 21002 | メインAPI |
| **PostgreSQL** | 5432 | データベース |