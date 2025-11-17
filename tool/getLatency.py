import pandas as pd

# JTLファイル（CSV形式）を読み込みます。
# JMeterのJTLファイルは通常カンマ区切りです。
file_name = '/Users/takada/Desktop/takada_personal/toiware_task/adamas_ST/results/1116/01_04_Login_Stress_2200_20251116212442_report/01_04_Login_Stress_2200_20251116212442.jtl'
try:
    # ヘッダー行が存在するため、header=0 を指定
    df = pd.read_csv(file_name)

    # Latency列を抽出
    latency_data = df['Latency']

    # Latencyの平均値を計算（ミリ秒単位）
    average_latency_ms = latency_data.mean()

    # 平均値を小数点以下2桁に丸める
    average_latency_ms_rounded = round(average_latency_ms, 2)

    # 秒単位の平均値も計算
    average_latency_sec_rounded = round(average_latency_ms / 1000, 2)

    print(f"Latencyのデータ型:\n{latency_data.dtype}")
    print(f"Latencyの平均値（ミリ秒）: {average_latency_ms_rounded}")
    print(f"Latencyの平均値（秒）: {average_latency_sec_rounded}")

except FileNotFoundError:
    print(f"エラー: ファイル '{file_name}' が見つかりません。")
except KeyError:
    print("エラー: ファイルに 'Latency' という名前の列が見つかりません。")
except Exception as e:
    print(f"データの処理中にエラーが発生しました: {e}")

# # ユーザーの質問に答えるために、Latency列のみを取得する例を提示
# print("\n--- Latency列のみを取得するPythonコードの例 ---")
# print("import pandas as pd")
# print("df = pd.read_csv('test_20251101041348.jtl')")
# print("latency_only = df['Latency']")
# print("print(latency_only.head())")