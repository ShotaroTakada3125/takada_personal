import pandas as pd

def filter_jtl_file(input_filepath, output_filepath, max_timestamp_sec):
    """
    JMeterの結果ファイル(.jtl)を読み込み、指定されたタイムスタンプより
    小さいレコードに絞って、新しいCSVファイルとして保存します。

    Args:
        input_filepath (str): 元のJMeter結果ファイル(.jtl)のパス
        output_filepath (str): 出力する新しいCSVファイルのパス
        max_timestamp_sec (int): フィルタリングの上限となるUNIXタイムスタンプ（秒単位）
    """
    
    # JMeterのタイムスタンプはミリ秒なので、秒単位のフィルタ値をミリ秒に変換
    MAX_TIMESTAMP_MS = max_timestamp_sec * 1000
    
    print(f"--- JMeterファイルフィルタリング ---")
    print(f"入力ファイル: {input_filepath}")
    print(f"フィルタリング条件: timeStamp < {max_timestamp_sec} 秒 ({MAX_TIMESTAMP_MS} ミリ秒)")
    print("-" * 40)

    try:
        # 1. データの読み込み
        df = pd.read_csv(input_filepath)
    except FileNotFoundError:
        print(f"エラー: ファイル '{input_filepath}' が見つかりません。")
        return
    except Exception as e:
        print(f"エラー: ファイルの読み込み中に問題が発生しました: {e}")
        return

    # 2. タイムスタンプによるフィルタリング
    # timeStampカラムがMAX_TIMESTAMP_MSより小さい行を抽出
    df_filtered = df[df['timeStamp'] < MAX_TIMESTAMP_MS].copy()

    # フィルタリング後のレコード数
    total_samples = len(df_filtered)
    
    if total_samples == 0:
        print("注意: フィルタリング条件に一致するレコードがありませんでした。")
        return

    # 3. 新しいファイルとして保存
    # index=False は、pandasが自動で付加する行番号をファイルに含めないための設定です。
    df_filtered.to_csv(output_filepath, index=False)
    
    # 4. 結果の表示
    print(f"✅ フィルタリング後の総レコード数: {total_samples}")
    print(f"✅ ファイル出力成功: {output_filepath}")
    print("-" * 40)


# --- 実行部分 ---
if __name__ == "__main__":
    # TODO: ここをあなたのファイルパスとフィルタリング値に合わせて変更してください
    INPUT_FILE_PATH = '/Users/takada/Desktop/takada_personal/toiware_task/adamas_ST/results/1120/01_04_Login_Stress_450_20251120011716_report/01_04_Login_Stress_450_20251120011716.jtl'         # 元のJTLファイル名
    OUTPUT_FILE_PATH = 'filtered_results.csv'          # 新しい出力ファイル名
    MAX_TIMESTAMP_SEC = 1763570700                       # フィルタリング上限（秒単位）
    
    filter_jtl_file(INPUT_FILE_PATH, OUTPUT_FILE_PATH, MAX_TIMESTAMP_SEC)