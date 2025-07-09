## excel全般の学び

- csvファイルが文字化けしていた時の対応
    [参照：](https://note.com/noa813/n/ndfe0296fa3bb)

- 文字列の比較をしたい時
    - 文字列が一致しているか確認したい時
        = A1 = B1
        結果：TRUE / FALSE

    - 最初の何文字かを無視して一致しているか確認したい時
        =EXACT(RIGHT(A1,LEN(A1)-1),B1)
        結果：TRUE / FALSE
        - 説明
            LEN(A1): A1セルの文字列の長さを取得
            LEN(A1)-n: 先頭からn文字を除いた文字数を計算
            RIGHT(A1,LEN(A1)-1): A1セルの文字列の右から、LEN(A1)-1文字を抽出
        - 備考
            SUBSTITUTE(A1,"'",""): A1セルの文字列から'を空文字列に置換（削除）
            EXACT(文字列1, 文字列2): 2つの文字列が大文字・小文字を含め完全に一致するかを判定

            使用例
                =EXACT(SUBSTITUTE(A1,"'",""),B1)
                結果：TRUE / FALSE
