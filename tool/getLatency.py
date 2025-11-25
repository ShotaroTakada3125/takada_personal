import pandas as pd
import os # os.path.basename を使用するためにインポート

# JTLファイル（CSV形式）を読み込みます。
# JMeterのJTLファイルは通常カンマ区切りです。
file_path = '/Users/takada/Desktop/takada_personal/toiware_task/adamas_ST/results/1116/01_01_Login_Load_20251116212442_report/01_01_Login_Load_20251116212442.jtl'

# ファイルのパスからファイル名（basename）を抽出
file_name_only = os.path.basename(file_path)

try:
    # ヘッダー行が存在するため、header=0 を指定
    df = pd.read_csv(file_path)

    # Latency列を抽出
    latency_data = df['Latency']

    # Latencyの平均値を計算（ミリ秒単位）
    average_latency_ms = latency_data.mean()

    # 平均値を小数点以下2桁に丸める
    average_latency_ms_rounded = round(average_latency_ms, 2)

    # 秒単位の平均値も計算
    average_latency_sec_rounded = round(average_latency_ms / 1000, 2)

    # 修正されたprint文 (ファイル名のみを表示)
    print(f"--- 処理結果 ---")
    print(f"対象ファイル: {file_name_only}")
    print(f"Latencyのデータ型: {latency_data.dtype}")
    print(f"Latencyの平均値（ミリ秒）: {average_latency_ms_rounded}")
    print(f"Latencyの平均値（秒）: {average_latency_sec_rounded}")
    print(f"----------------")

except FileNotFoundError:
    print(f"エラー: ファイル '{file_path}' が見つかりません。")
except KeyError:
    print(f"エラー: ファイル '{file_name_only}' に 'Latency' という名前の列が見つかりません。")
except Exception as e:
    print(f"データの処理中にエラーが発生しました: {e}")