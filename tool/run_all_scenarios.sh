#!/bin/bash

# 実行ファイル群
BASE_DIR=$(pwd)
# jmeter実行環境
JMETER_EXEC="${BASE_DIR}/apache-jmeter-5.6.3/bin/jmeter"
# シナリオ
SCENARIO_DIR="${BASE_DIR}/scenarios"
# レポートファイル(.jtl)
REPORT_BASE_DIR="${BASE_DIR}/results"
#分散環境
JMETER_EXTRA_OPTS=""

#削除対象のファイルパス
CSV_TO_DELETE="/home/jmeter/scenarios/csv_for_test/sessionInfo.csv"
# ループ処理用のカウンタを初期化
COUNTER=0
#現在日時
DATETIME=$(date "+%Y%m%d%H%M%S")
DATEONLY=$(date "+%Y%m%d")

while getopts "r" opt; do
    case $opt in
        r)
            JMETER_EXTRA_OPTS="-r"
            echo "INFO: JMeterを分散環境で実行します。"
            ;;
        \?)
            echo "ERROR: 無効なオプションを指定しています。"
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "開始"
echo "カレントディレクトリ (BASE_DIR): ${BASE_DIR}"

DATE_DIR="${REPORT_BASE_DIR}/${DATEONLY}"
mkdir -p "${DATE_DIR}"

# 実行ファイルの存在確認
if [ ! -x "${JMETER_EXEC}" ]; then
    echo "ERROR: 実行ファイルが見つからないか、実行権限がありません。"
    echo "PATH: ${JMETER_EXEC}"
    exit 1
fi

for JMX_PATH in "${SCENARIO_DIR}"/*.jmx; do
    COUNTER=$((COUNTER + 1))

    # ファイルが見つからなかった場合
    if [ ! -f "${JMX_PATH}" ]; then
        echo "INFO: シナリオディレクトリに .jmx ファイルが見つかりませんでした。"
        break
    fi

    #ファイル名
    ORIGINAL_IDENTIFIER=$(basename "${JMX_PATH}" .jmx)
    REPORT_IDENTIFIER="${ORIGINAL_IDENTIFIER}_${DATETIME}"
    #HTMLレポート
    # REPORT_DIR="${DATE_DIR}/${REPORT_IDENTIFIER}"
    #JTLファイル
    JTL_FILE="${DATE_DIR}/${REPORT_IDENTIFIER}.jtl"

    # mkdir -p "${REPORT_DIR}"

    echo ""
    echo "--- 処理開始(${COUNTER}番目): ${ORIGINAL_IDENTIFIER}.jmx ---"
    # echo "HTML出力先: ${REPORT_DIR}"
    echo "JTL ファイル: ${JTL_FILE}"

    echo "INFO:実行コマンド:${JMETER_EXEC} -n ${JMETER_EXTRA_OPTS} -t ${JMX_PATH} -l ${JTL_FILE}"

    # コマンド実行:
    "${JMETER_EXEC}" -n ${JMETER_EXTRA_OPTS} -t "${JMX_PATH}" -l "${JTL_FILE}"

    # コマンドが正常に終了したか確認
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] ${ORIGINAL_IDENTIFIER} のループ処理が完了しました。"
    else
        echo "[FAILURE] ${ORIGINAL_IDENTIFIER} の実行中にエラーが発生しました。"
    fi

    # 偶数番目の.jmx実行後の処理 (2, 4, 6, ... 番目の実行後)
    # COUNTERを2で割った余りが0なら偶数
    if [ $((COUNTER % 2)) -eq 0 ]; then
        echo "--- 偶数番目処理: CSVファイルの削除判定 ---"
        if [ -f "${CSV_TO_DELETE}" ]; then
            echo "INFO: 偶数番目実行後のため、CSVファイルを削除します: ${CSV_TO_DELETE}"
            rm -f "${CSV_TO_DELETE}"
            if [ $? -eq 0 ]; then
                echo "[SUCCESS] CSVファイルの削除が完了しました。"
            else
                echo "[FAILURE] CSVファイルの削除中にエラーが発生しました。"
            fi
        else
            echo "INFO: 削除対象のCSVファイルが見つかりませんでした: ${CSV_TO_DELETE}"
        fi
    fi
done

echo "完了"

exit 0

