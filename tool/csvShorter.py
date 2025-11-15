

import pandas as pd

# 1. CSVファイルを読み込む
file_name = "/Users/takada/Desktop/adamas/性能テスト/シナリオ/シナリオ/csv_for_test/test_03_AccountOpening_Personal.csv"
# CSVファイルが存在しない場合は、ファイル名を 'test04.csv' などに修正してください。
# 例: file_name = "test04.csv"
df = pd.read_csv(file_name)

# 2. 残したいカラムのリストを定義
columns_to_keep = [
    'email',
    'givenNameAlphabet'
]

# 3. 指定されたカラムだけを抽出して、それ以外のカラムを削除
df_filtered = df[columns_to_keep]

# 4. 結果のデータを確認（to_string()に変更）
print("--- 抽出後のデータフレームの最初の5行 ---")
# to_string() は外部ライブラリなしで動作し、整形されたテキストを出力します。
print(df_filtered.head().to_string(index=False))

# 5. 結果を新しいCSVファイルとして保存
output_file_name = "/Users/takada/Desktop/adamas/性能テスト/シナリオ/シナリオ/csv_for_test/03_filtered_corporation_data.csv"
df_filtered.to_csv(output_file_name, index=False, encoding='utf-8')

print(f"\n✅ 必要なカラムのみを含むデータが '{output_file_name}' に保存されました。")