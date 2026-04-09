#!/bin/bash

# 設定(フォルダの位置は適宜変更してください)
BASE_DIR="$HOME/Desktop/10_github"
DIR_BACKOFFICE="$BASE_DIR/signup-backoffice"
DIR_MOCK="$BASE_DIR/simplex-py-server"
DIR_SIGNUP_API="$BASE_DIR/signup-api"
DIR_FRONTEND="$BASE_DIR/signup-frontend"

echo "口座開設システムのフロントエンドローカル環境を起動します..."

# データベース & 基盤 (Docker)

echo "Step1: Dockerコンテナを起動します..."

cd $DIR_BACKOFFICE
docker compose -p signup-backoffice up -d
# dockerが立ち上がるまで少し待機
sleep 5

# 新しいターミナルタブでコマンドを実行
# Macのターミナルアプリ専用の命令
open_tab() {
    local title="$1"
    local dir="$2"
    local cmd="$3"

    # 新しいウィンドウでタブを開いてコマンドを実行する
    # osascript -e "tell application \"Terminal\" to do script \"cd $dir && echo '--- $title ---' && $cmd\""
    # 同一ウィンドウ内で新しいタブを開いてコマンドを実行する
    osascript -e "
        tell application \"Terminal\"
            activate
            tell application \"System Events\" to keystroke \"t\" using {command down}
            delay 0.5
            do script \"cd $dir && echo '--- $title ---' && $cmd\" in front window
        end tell"
}

# Mockサーバー　(Simplex擬似環境)

echo "Step2: Mockサーバーを起動します..."
open_tab "Mockサーバー" "$DIR_MOCK" "TZ='Asia/Tokyo' python -m uvicorn app.main:app --reload --port 8090 --log-config log_config.yaml"

# Signup API (バックエンド)

echo "Step3: Signup APIを起動します..."
open_tab "Signup API" "$DIR_SIGNUP_API" "source .envrc.local && export JAVA_HOME=\$(asdf where java) && ./mvnw clean spring-boot:run -Dspring-boot.run.profiles=dev,ext-stg"
# Signup Frontend (申込画面)

# フロントエンドサーバー
echo "Step4-1: Frontend Serverを起動します..."
open_tab "Signup Frontend Server" "$DIR_FRONTEND" "npm run dev:server"

# フロントエンドクライアント
echo "Step4-2: Frontend Clientを起動します..."
open_tab "Signup Frontend Client" "$DIR_FRONTEND" "npm run dev:front"

echo "口座開設フロントのすべての環境が起動しました。"