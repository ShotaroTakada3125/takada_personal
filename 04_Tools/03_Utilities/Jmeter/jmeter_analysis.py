import pandas as pd

def analyze_jmeter_results(jtl_filepath, max_timestamp_sec):
    """
    JMeterの結果ファイル(.jtl)を読み込み、指定されたタイムスタンプより
    小さいレコードに絞って統計情報を計算します。

    Args:
        jtl_filepath (str): JMeter結果ファイル(.jtl)のパス
        max_timestamp_sec (int): フィルタリングの上限となるUNIXタイムスタンプ（秒単位）
    """
    
    # JMeterのタイムスタンプはミリ秒なので、秒単位のフィルタ値をミリ秒に変換
    MAX_TIMESTAMP_MS = max_timestamp_sec * 1000
    
    print(f"--- JMeter結果分析 ---")
    print(f"対象ファイル: {jtl_filepath}")
    print(f"フィルタリング条件: timeStamp < {max_timestamp_sec} 秒 ({MAX_TIMESTAMP_MS} ミリ秒)")
    print("-" * 30)

    try:
        # 1. データの読み込み
        # .jtlファイルは一般的にCSV形式として読み込めます
        df = pd.read_csv(jtl_filepath)
    except FileNotFoundError:
        print(f"エラー: ファイル '{jtl_filepath}' が見つかりません。")
        return
    except Exception as e:
        print(f"エラー: ファイルの読み込み中に問題が発生しました: {e}")
        return

    # 2. タイムスタンプによるフィルタリング
    df_filtered = df[df['timeStamp'] < MAX_TIMESTAMP_MS].copy()

    # フィルタリング後のレコード数
    total_samples = len(df_filtered)
    
    if total_samples == 0:
        print("注意: フィルタリング条件に一致するレコードがありませんでした。")
        return

    # フィルタリングされたデータの最小/最大タイムスタンプ（ミリ秒）
    start_time_ms = df_filtered['timeStamp'].min()
    end_time_ms = df_filtered['timeStamp'].max()
    
    # フィルタリングされたデータ内のテスト実行時間（秒）
    # (最大タイムスタンプ + 平均応答時間) - 最小タイムスタンプ
    # 実際には最後のサンプルの終了時間（timeStamp + elapsed）を使うのがより正確ですが、ここでは簡略化のため最大timeStampを使用します。
    # ここでは、データセットの期間として (max(timeStamp) - min(timeStamp)) / 1000.0 を使用します。
    test_duration_sec = (end_time_ms - start_time_ms) / 1000.0

    # 3. 統計量の計算
    
    # エラー率
    # successカラムが'false'のサンプル数をカウント
    error_samples = len(df_filtered[df_filtered['success'] == False])
    error_rate = (error_samples / total_samples) * 100
    
    # 応答速度 (elapsed) とレイテンシ (Latency) の平均
    mean_elapsed = df_filtered['elapsed'].mean()
    mean_latency = df_filtered['Latency'].mean()
    
    # 送受信バイト数の合計
    total_bytes = df_filtered['bytes'].mean()
    total_sent_bytes = df_filtered['sentBytes'].mean()
    
    # スループット (requests/sec)
    # テスト実行時間が0になることを避けるためのガード
    if test_duration_sec > 0:
        throughput = total_samples / test_duration_sec
    else:
        throughput = 0.0

    # 4. 結果の表示
    print(f"✅ フィルタリング後の総レコード数: {total_samples}")
    print(f"⏱️ データの期間: {test_duration_sec:.2f} 秒")
    print("-" * 30)
    print(f"**エラー率**: {error_rate:.2f}% ({error_samples} / {total_samples})")
    print(f"**平均応答速度 (elapsed)**: {mean_elapsed:.2f} ms")
    print(f"**平均レイテンシ (Latency)**: {mean_latency:.2f} ms")
    print(f"**総受信バイト数 (bytes)**: {total_bytes:,} バイト")
    print(f"**総送信バイト数 (sentBytes)**: {total_sent_bytes:,} バイト")
    print(f"**スループット (requests/sec)**: {throughput:.2f} /秒")
    print("-" * 30)


# --- 実行部分 ---
if __name__ == "__main__":
    # TODO: ここをあなたのJTLファイルパスとフィルタリング値に合わせて変更してください
    JTL_FILE_PATH = '/Users/takada/Desktop/takada_personal/toiware_task/adamas_ST/results/1120/01_04_Login_Stress_450_20251120011716_report/01_04_Login_Stress_450_20251120011716.jtl'  # 例: 'results.jtl'
    MAX_TIMESTAMP_SEC = 1763571780                 # フィルタリング上限（秒単位）
    
    # 上の例のデータを使用する場合 (実際のJTLファイルに置き換えてください)
    # MAX_TIMESTAMP_SEC = 1763570700 
    # JTL_FILE_PATH = 'your_results.jtl' 
    
    analyze_jmeter_results(JTL_FILE_PATH, MAX_TIMESTAMP_SEC)