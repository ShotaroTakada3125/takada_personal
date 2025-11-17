#!/bin/bash

# --- 設定変数 ---

# JMeterの実行ファイルへのフルパス
# ※ご提示のパスに 'jmeter' コマンド自体を含める必要があります。
#   ここでは便宜上、ご提示のディレクトリに 'jmeter' があると仮定します。
JMETER_BIN="/opt/homebrew/Cellar/jmeter/5.6.3/libexec/bin/jmeter"

# .jtlファイルとレポート出力ディレクトリがあるベースディレクトリ
BASE_DIR="/Users/takada/Desktop/takada_personal/toiware_task/adamas_ST/results/1117"

# --- スクリプト本体 ---

echo "🚀 JMeterレポート生成を開始します..."
echo "検索ディレクトリ: ${BASE_DIR}"

# BASE_DIR内のすべての .jtl ファイルをループ処理
find "${BASE_DIR}" -maxdepth 1 -type f -name "*.jtl" | while read JTL_FILE
do
    # JTLファイル名から拡張子 (.jtl) を取り除く
    FILENAME=$(basename "${JTL_FILE}")
    REPORT_NAME="${FILENAME%.jtl}"

    # レポート出力ディレクトリを JTL ファイル名 (拡張子なし) に基づいて作成
    REPORT_DIR="${BASE_DIR}/${REPORT_NAME}_report"

    echo "---"
    echo "📄 JTLファイル: ${FILENAME}"

    # 出力ディレクトリが存在しない場合は作成
    if [ -d "${REPORT_DIR}" ]; then
        echo "⚠️ 出力ディレクトリ (${REPORT_DIR}) は既に存在します。上書きします。"
    else
        echo "📂 出力ディレクトリ (${REPORT_DIR}) を作成します。"
        mkdir -p "${REPORT_DIR}"
    fi

    # JMeterレポート生成コマンドを実行
    echo "⚙️ JMeterコマンドを実行中..."
    # 注意: jmeterコマンドのパスが正しいか確認してください。
    "${JMETER_BIN}" -g "${JTL_FILE}" -o "${REPORT_DIR}"
     sort -t, -k1,1n ${JTL_FILE} | TZ='Asia/Tokyo' gawk -F, 'NR == 1 {print $1; next} {print strftime("%Y-%m-%d %H:%M:%S", $1/1000)}'
    if [ $? -eq 0 ]; then
        echo "✅ レポート生成が完了しました: ${REPORT_DIR}/index.html"
    else
        echo "❌ エラーが発生しました。レポートの生成に失敗しました: ${JTL_FILE}"
    fi
done

echo "---"
echo "🎉 全てのレポート生成処理が終了しました。"