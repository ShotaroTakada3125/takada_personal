#!/bin/bash
#
# JMeter 環境構築スクリプト
#
# このスクリプトは root 権限で実行する必要があります。
# Red Hat 系のディストリビューション (dnf を使用) を想定しています。
# 冪等性を強化し、ファイルが存在する場合はダウンロード/展開をスキップします。
#
# --- Workerノードとして設定する場合 ---
# ./setup_script.sh --worker
#

# --- スクリプト設定 ---

# エラー時に即時終了
set -euo pipefail

# --- グローバル変数・定数定義 ---
readonly JMETER_USER="jmeter"
readonly JMETER_HOME="/home/${JMETER_USER}"
readonly JMETER_VERSION="5.6.3"
readonly JMETER_DIR_NAME="apache-jmeter-${JMETER_VERSION}"
readonly JMETER_PATH="${JMETER_HOME}/${JMETER_DIR_NAME}"
readonly JMETER_TGZ_URL="https://archive.apache.org/dist/jmeter/binaries/${JMETER_DIR_NAME}.tgz"
readonly JMETER_TGZ_FILE="${JMETER_DIR_NAME}.tgz"

readonly AWS_CLI_ZIP_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
readonly AWS_CLI_ZIP_FILE="awscliv2.zip"

readonly S3_LIB_PATH="s3://s25-signup-tools/jmeter/lib/"
readonly S3_SCENARIO_PATH="s3://s25-signup-tools/jmeter/scenarios/"

# --- Workerノードフラグ (グローバル変数) ---
IS_WORKER_NODE="false"

# --- ヘルパー関数 ---

log() {
    # 標準出力 (stdout) にログを出力
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] INFO: $1"
}

error() {
    # 標準エラー出力 (stderr) にエラーを出力
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] ERROR: $1" >&2
    exit 1
}

# エラー発生時に呼び出す関数を登録
trap 'error "スクリプトの実行中にエラーが発生しました (lineno: $LINENO)"' ERR

# --- メイン関数 ---
main() {
    log "JMeter 環境構築スクリプトを開始します。"

    # --- 引数解析 (Workerノード判定) ---
    if [[ "${1:-}" == "--worker" ]]; then
        IS_WORKER_NODE="true"
        log "Worker ノードとして設定します。"
    else
        log "Controller (またはスタンドアロン) ノードとして設定します。"
    fi
    
    check_root_user
    setup_system_and_user
    install_tools_as_jmeter_user
    install_aws_cli_as_root
    configure_jmeter_as_jmeter_user
    create_helper_scripts_as_jmeter_user
    cleanup_as_jmeter_user
    setup_worker_service # Workerノードの場合のみサービスを起動

    log "==========================================================="
    log " JMetere 環境構築が正常に完了しました。"
    log "==========================================================="
    log " ユーザ: ${JMETER_USER}"
    log " JMeter ホーム: ${JMETER_PATH}"
    
    if [[ "${IS_WORKER_NODE}" == "true" ]]; then
        log ""
        log "★ このノードは Worker として設定されました ★"
        log "   jmeter-server サービスが自動起動しています。"
        log "   Controllerノードの jmeter.properties (remote_hosts) に"
        log "   このサーバのIPアドレスを追加してください。"
        log "   (サービス状態確認: systemctl status jmeter-server)"
    else
        log ""
        log " 次のステップ (Controllerノード):"
        log " 1. jmeter ユーザに切り替えてください: su - ${JMETER_USER}"
        log " 2. AWS 認証情報を設定してください: aws configure"
        log " 3. シナリオをダウンロードしてください: ./download_scenarios.sh"
        log " 4. (分散実行時) ${JMETER_PATH}/bin/jmeter.properties の"
        log "    'remote_hosts' に Worker のIPを追加してください。"
    fi
    log "==========================================================="
}

# --- 実行関数 ---

# root で実行されているか確認
check_root_user() {
    log "実行ユーザを確認します..."
    if [[ "$(id -u)" -ne 0 ]]; then
        error "このスクリプトは root 権限で実行する必要があります。"
    fi
    log "root ユーザで実行されています。"
}

# システムアップデートとユーザ作成、パッケージインストール
setup_system_and_user() {
    log "システムのセットアップを開始します (root 権限)..."

    # ユーザ 'jmeter' が存在しない場合のみ作成
    if ! id "${JMETER_USER}" &>/dev/null; then
        log "ユーザ '${JMETER_USER}' を作成します (ホーム: ${JMETER_HOME})..."
        useradd -m -d "${JMETER_HOME}" "${JMETER_USER}"
    else
        log "ユーザ '${JMETER_USER}' は既に存在します。"
    fi

    log "DNF パッケージキャッシュをアップデートします..."
    dnf update -y > /dev/null

    log "必要なパッケージ (Java 11, wget, unzip, tree, vim) をインストールします..."
    dnf install -y java-11-openjdk unzip wget tree vim > /dev/null

    log "Java バージョンを確認します:"
    java -version
}

# jmeter ユーザとして JMeter と AWS CLI インストーラをダウンロード・展開
install_tools_as_jmeter_user() {
    log "JMeter と AWS CLI インストーラのダウンロード/展開を '${JMETER_USER}' ユーザとして実行します..."

    su - "${JMETER_USER}" -c "
        set -euo pipefail
        cd \"${JMETER_HOME}\"

        # 1. JMeter のインストール
        # 展開後のディレクトリの有無でインストールを判断
        if [ ! -d \"${JMETER_DIR_NAME}\" ]; then
            echo \"INFO [\${USER}]: JMeter ディレクトリ (${JMETER_DIR_NAME}) が見つかりません。インストールを開始します。\"
            
            # Tgz がなければダウンロード
            if [ ! -f \"${JMETER_TGZ_FILE}\" ]; then
                echo \"INFO [\${USER}]: JMeter (v${JMETER_VERSION}) をダウンロードします...\"
                wget -q -O \"${JMETER_TGZ_FILE}\" \"${JMETER_TGZ_URL}\"
            else
                echo \"INFO [\${USER}]: 既存の JMeter Tgz (${JMETER_TGZ_FILE}) を使用します。\"
            fi
            
            echo \"INFO [\${USER}]: JMeter を展開します...\"
            tar -xzf \"${JMETER_TGZ_FILE}\"
        else
            echo \"INFO [\${USER}]: JMeter ディレクトリ (${JMETER_DIR_NAME}) は既に存在します。インストールをスキップします。\"
        fi

        # 2. AWS CLI v2 のインストール
        # 展開後のディレクトリの有無でインストールを判断
        if [ ! -d \"aws\" ]; then
            echo \"INFO [\${USER}]: AWS CLI ディレクトリ (aws) が見つかりません。インストールを開始します。\"

            if [ ! -f \"${AWS_CLI_ZIP_FILE}\" ]; then
                echo \"INFO [\${USER}]: AWS CLI v2 をダウンロードします...\"
                curl -s \"${AWS_CLI_ZIP_URL}\" -o \"${AWS_CLI_ZIP_FILE}\"
            else
                echo \"INFO [\${USER}]: 既存の AWS CLI Zip (${AWS_CLI_ZIP_FILE}) を使用します。\"
            fi
            
            echo \"INFO [\${USER}]: AWS CLI v2 を展開します...\"
            unzip -q \"${AWS_CLI_ZIP_FILE}\"
        else
            echo \"INFO [\${USER}]: AWS CLI ディレクトリ (aws) は既に存在します。インストールをスキップします。\"
        fi
    "
}

# root ユーザとして AWS CLI をシステムにインストール
install_aws_cli_as_root() {
    log "AWS CLI v2 をシステムにインストールします (root 権限)..."
    
    # AWS CLIがインストール済みか確認
    if ! command -v aws &> /dev/null; then
        "${JMETER_HOME}/aws/install" --update
    else
        log "AWS CLI は既にインストールされています。バージョンを確認します:"
    fi
    
    log "jmeter ユーザとして AWS CLI のバージョンを確認します..."
    su - "${JMETER_USER}" -c "aws --version"
}

# jmeter ユーザとしてライブラリの配置と設定ファイルの変更
configure_jmeter_as_jmeter_user() {
    log "JMeter のライブラリダウンロードと設定を '${JMETER_USER}' ユーザとして実行します..."
    
    # --- ★★★ エラー修正箇所 ★★★ ---
    # su -c '...' (シングルクォート) を "..." (ダブルクォート) に変更。
    # これにより ${JMETER_HOME} 等が root シェルによって展開され、jmeter ユーザに渡る。
    # jmeter ユーザ側で展開する変数は \$ のようにエスケープする。
    su - "${JMETER_USER}" -c "
        set -euo pipefail
        
        # IS_WORKER_NODE は root シェルの変数を参照する
        is_worker_node=\"${IS_WORKER_NODE}\"
        
        cd \"${JMETER_HOME}\" # エラー箇所。root シェルが展開するように修正

        # 1. S3 からライブラリをダウンロード (ext がなければ)
        if [ ! -d \"ext\" ]; then
            echo \"INFO [\${USER}]: S3 から JMeter ライブラリをダウンロードします...\" # \${USER}
            aws s3 cp \"${S3_LIB_PATH}\" . --recursive # root シェルが展開
        else
            echo \"INFO [\${USER}]: S3 ライブラリ (ext ディレクトリ) は既に存在します。ダウンロードをスキップします。\" # \${USER}
        fi

        # 2. ライブラリを適切な場所に移動
        echo \"INFO [\${USER}]: ダウンロードしたライブラリを JMeter パスに移動します...\" # \${USER}
        
        # ext ディレクトリが存在し、かつ中身が空でない場合のみ移動
        if [ -d \"ext\" ] && [ -n \"\$(ls -A ext)\" ]; then # \$(ls -A ext)
            echo \"INFO [\${USER}]: lib/ext/ フォルダに .jar を移動します...\" # \${USER}
            mkdir -p \"${JMETER_PATH}/lib/ext/\" # root シェルが展開
            mv ext/* \"${JMETER_PATH}/lib/ext/\" # root シェルが展開
        elif [ -d \"ext\" ]; then
             echo \"INFO [\${USER}]: lib/ext/ への移動は既に完了しています (ext ディレクトリは空です)。\" # \${USER}
        else
            echo \"WARN [\${USER}]: 'ext' ディレクトリが見つかりませんでした。S3 のダウンロード内容を確認してください。\" # \${USER}
        fi

        # ルートにダウンロードされた jar ファイルを lib/ に移動
        echo \"INFO [\${USER}]: lib/ フォルダに .jar を移動します...\" # \${USER}
        mv jmeter-plugins-cmn-jmeter-0.7.jar javax.mail.jar \"${JMETER_PATH}/lib/\" 2>/dev/null || echo \"INFO [\${USER}]: (jmeter-plugins-cmn-jmeter-0.7.jar または javax.mail.jar が見つかりませんでした。スキップします)\" # \${USER}

        # 3. system.properties の設定
        echo \"INFO [\${USER}]: system.properties にメール設定を追記します...\" # \${USER}
        
        system_props_path=\"${JMETER_PATH}/bin/system.properties\" # root シェルが展開
        config_line='mail.imaps.ssl.protocols=TLSv1.2 TLSv1.3'
        
        # 既に設定が存在しないか確認してから追記
        if ! grep -qF -- \"\${config_line}\" \"\${system_props_path}\"; then # \${config_line}, \${system_props_path}
            echo -e \"\n# メールを取得するための設定 (スクリプトによる追記)\n\${config_line}\" >> \"\${system_props_path}\" # \${config_line}, \${system_props_path}
            echo \"INFO [\${USER}]: system.properties に設定を追記しました。\" # \${USER}
        else
            echo \"INFO [\${USER}]: メール設定は既に system.properties に存在します。\" # \${USER}
        fi

        # 4. Workerノード用の設定 (RMI SSL無効化)
        if [[ \"\${is_worker_node}\" == \"true\" ]]; then # \${is_worker_node}
            echo \"INFO [\${USER}]: Worker ノードとして jmeter.properties の RMI SSL を無効化します...\" # \${USER}
            
            jmeter_props_path=\"${JMETER_PATH}/bin/jmeter.properties\" # root シェルが展開
            rmi_config_line='server.rmi.ssl.disable=true'
            
            # 既に設定が有効 (コメントアウトされていない) か確認
            if grep -qE \"^\s*\${rmi_config_line}\" \"\${jmeter_props_path}\"; then # \${rmi_config_line}, \${jmeter_props_path}
                echo \"INFO [\${USER}]: \${rmi_config_line} は既に設定済みです。\" # \${USER}, \${rmi_config_line}
            
            # コメントアウトされている行が存在するか確認
            elif grep -qE \"^\s*#\s*\${rmi_config_line}\" \"\${jmeter_props_path}\"; then # \${rmi_config_line}, \${jmeter_props_path}
                # コメントアウトを解除 (sed)
                sed -i \"s|^\s*#\s*\${rmi_config_line}|\${rmi_config_line}|\" \"\${jmeter_props_path}\" # \${rmi_config_line} (2回), \${jmeter_props_path}
                echo \"INFO [\${USER}]: \${rmi_config_line} のコメントアウトを解除しました。\" # \${USER}, \${rmi_config_line}
            
            # 存在しない場合は追記
            else
                echo -e \"\n# Workerノード設定 (RMI SSL無効化)\n\${rmi_config_line}\" >> \"\${jmeter_props_path}\" # \${rmi_config_line}, \${jmeter_props_path}
                echo \"INFO [\${USER}]: \${rmi_config_line} を追記しました。\" # \${USER}, \${rmi_config_line}
            fi
        else
            echo \"INFO [\${USER}]: Controller モードです。jmeter.properties (RMI) の変更はスキップします。\" # \${USER}
        fi
    "
    # ↑ 引数 'bash "${IS_WORKER_NODE}"' を削除
}

# jmeter ユーザとしてヘルパースクリプトとディレクトリを作成
create_helper_scripts_as_jmeter_user() {
    log "'${JMETER_USER}' ユーザ用のヘルパースクリプトとディレクトリを作成します..."

    # 1. download_scenarios.sh の内容を変数 (テンプレート) に格納する
    #    'EOF' (シングルクォート) を使い、変数展開を一切行わない
    #    ★★★ 終端の 'EOF' はインデントしないでください ★★★
script_content=$(cat << 'EOF'
#!/bin/bash
#
# S3からJMeterシナリオフォルダを同期するスクリプト
#
set -euo pipefail

# S3のソースパス (末尾のスラッシュが重要)
S3_SOURCE="S3_PATH_PLACEHOLDER"

# EC2の保存先パス (末尾のスラッシュが重要)
EC2_DEST="JMETER_HOME_PLACEHOLDER/scenarios/"

echo "S3からシナリオの同期を開始します..."
echo "  Source: $S3_SOURCE"
echo "  Destination: $EC2_DEST"

# aws s3 sync を実行
aws s3 sync "$S3_SOURCE" "$EC2_DEST"

echo "同期が完了しました。"
EOF
)

    # 2. プレースホルダーを実際の値に置換する
    script_content=$(echo "${script_content}" | sed "s@S3_PATH_PLACEHOLDER@${S3_SCENARIO_PATH}@g")
    script_content=$(echo "${script_content}" | sed "s@JMETER_HOME_PLACEHOLDER@${JMETER_HOME}@g")

    # 3. jmeter ユーザに切り替えて、変数の内容をファイルに書き込む
    #    su -c '...' (シングルクォート) を使い、シェルスクリプトを安全に渡す
    #    'bash' が $0 (実行シェル名) になる
    #    "${script_content}" (Rootシェルが展開) が $1 (第1引数) になる
    su - "${JMETER_USER}" -c '
        # jmeter ユーザのシェルとして実行されるコマンド
        set -eo pipefail 
        cd "$HOME"

        echo "INFO [jmeter]: results と reports ディレクトリを作成します..."
        mkdir -p results reports
        
        echo "INFO [jmeter]: シナリオダウンロードスクリプト (download_scenarios.sh) を作成します..."
        
        # $1 (su に渡された第1引数) の内容をファイルに書き出す
        echo "$1" > "$HOME/download_scenarios.sh"
        
        chmod +x "$HOME/download_scenarios.sh"
    ' bash "${script_content}" # $0="bash", $1="${script_content}"
    
    # 4. 一時変数を解除する
    unset script_content
}


# jmeter ユーザとして不要なインストーラファイルを削除
cleanup_as_jmeter_user() {
    log "不要なインストーラファイルを '${JMETER_USER}' ユーザとしてクリーンアップします..."
    
    su - "${JMETER_USER}" -c "
        set -eu
        cd \"${JMETER_HOME}\"
        
        # 'ext' を削除対象に追加
        echo \"INFO [\${USER}]: 不要なファイルを削除します (${AWS_CLI_ZIP_FILE}, aws/, ${JMETER_TGZ_FILE}, ext/)...\"
        rm -rf \"${AWS_CLI_ZIP_FILE}\" aws \"${JMETER_TGZ_FILE}\" ext
    "
}

# Workerノードの場合、jmeter-server を systemd サービスとして登録
setup_worker_service() {
    # IS_WORKER_NODE が "true" でない場合は、何もせず終了
    if [[ "${IS_WORKER_NODE}" != "true" ]]; then
        log "Controller モードのため、systemd サービス設定をスキップします。"
        return
    fi

    log "Worker ノードの systemd サービス (jmeter-server.service) を設定します (root 権限)..."

    # systemd サービスファイルの内容を定義
    # ★★★ 終端の 'EOF' はインデントしないでください ★★★
local service_content=$(cat << EOF
[Unit]
Description=Apache JMeter Server (Worker)
After=network.target

[Service]
Type=simple
User=${JMETER_USER}
Group=${JMETER_USER}
WorkingDirectory=${JMETER_PATH}/bin
ExecStart=${JMETER_PATH}/bin/jmeter-server
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
)

    # サービスファイルを配置
    echo "${service_content}" > /etc/systemd/system/jmeter-server.service
    chmod 644 /etc/systemd/system/jmeter-server.service

    log "systemd デーモンをリロードします..."
    systemctl daemon-reload

    log "jmeter-server サービスを有効化 (自動起動設定) します..."
    systemctl enable jmeter-server

    log "jmeter-server サービスを起動 (または再起動) します..."
    # 既に起動している場合も考慮して restart を使用
    systemctl restart jmeter-server

    log "jmeter-server サービスの起動状態を確認します (数秒待機)..."
    sleep 3
    # サービスが active でない場合は警告を出す
    if ! systemctl is-active --quiet jmeter-server; then
        log "WARN: jmeter-server サービスが active 状態ではありません。 (status: $(systemctl is-active jmeter-server))"
        log "WARN: ログを確認してください: journalctl -u jmeter-server -n 50"
    else
        log "jmeter-server サービスは正常に起動しています。"
    fi
}


# --- スクリプト実行 ---
main "$@"