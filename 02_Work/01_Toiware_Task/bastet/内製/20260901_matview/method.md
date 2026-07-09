
### 【STEP 1】PostgresのSELECT結果をMacのデスクトップにCSV保存する

Macのターミナル（`takada@...` の画面）を開き、以下のコマンドを実行します。
比較するために、ファイル名を変えて2つのCSV（過去のデータ `old.csv` と、現在のデータ `new.csv`）を用意する想定です。

```bash
# 1つ目のCSV（比較元・古いデータなど）を取得
docker exec -i signup-postgres psql -U signupadmin -d s25signup -c "select * from staking_additional_account_rewards_view" --csv > ~/Desktop/staking_additional_account_rewards_view_before.csv

# 2つ目のCSV（比較先・新しいデータなど）を取得
docker exec -i signup-postgres psql -U signupadmin -d s25signup -c select * from staking_additional_account_rewards_view" --csv > ~/Desktop/staking_additional_account_rewards_view_after.csv

```

これで、Macのデスクトップに2つのCSVファイルがダウンロードされました。

---

### 【STEP 2】`comm` コマンドで2つのCSVを高速比較する

`comm` コマンドは超高速ですが、「事前にデータが並び替え（ソート）されていること」が絶対条件になります。

引き続き、Macのターミナルで以下の4行を順番に実行してください。

```bash
# 1. まずはデスクトップに移動
cd ~/Desktop

# 2. 2つのCSVファイルをそれぞれソート（並び替え）する
sort staking_rewards_old.csv > old_sorted.csv
sort staking_rewards_new.csv > new_sorted.csv

# 3. commコマンドで「新しく増えた差分」だけを抽出して保存
comm -3 old_sorted.csv new_sorted.csv > diff_result.csv

```

これで、デスクトップに **`diff_result.csv`** という「新しく追加・変更された行だけ」が入ったきれいな差分ファイルが完成します！

---

### 💡 `comm -3` ってどういう意味？

`comm` コマンドは通常、出力結果を「3つの列」に分けて表示します。

* 1列目：ファイル1（old）にしかない行
* 2列目：ファイル2（new）にしかない行
* 3列目：両方にある（共通の）行

オプションの `-13` は、「1列目と3列目を非表示（消去）にしてね」という意味になります。
その結果、**2列目（newに新しく増えたデータ）だけ**がシュッと抜き出されて出力されます。

大量のデータでも一瞬で終わるので、今後のデータ比較にぜひ役立ててください！