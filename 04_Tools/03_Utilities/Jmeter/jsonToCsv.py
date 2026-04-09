import json
import pandas as pd
from pandas import json_normalize

# 変換したいJSONデータ（三重引用符で囲み、raw文字列として扱う）
json_data = """
{
    "phone":"0364359129",
    "name":"トイウェア",
    "namePhonetic":"トイウェア",
    "nameAlphabet":"toiware",
    "legalPersonality":1,
    "legalPersonalityPhonetic":"カブシキガイシャ",
    "legalPersonalityPosition":2,
    "establishedDate":"1889-07-13",
    "business":102,
    "address":{
        "zipCode":"1050011",
        "prefecture":"東京都",
        "city":"港区芝公園",
        "street":"3-6-23",
        "building":""
    },
    "director":{
        "familyName":"法人",
        "givenName":"二郎1",
        "familyNamePhonetic":"ホウジン",
        "givenNamePhonetic":"ジロウ",
        "birthday":"1963-11-04",
        "nationality":1,
        "address":{
            "zipCode":"1050011",
            "prefecture":"東京都",
            "city":"港区芝公園",
            "street":"3-6-23",
            "building":""
            }
    },
    "manager":{
        "familyName":"法人",
        "givenName":"太郎1",
        "familyNamePhonetic":"ホウジン",
        "givenNamePhonetic":"タロウ",
        "birthday":"1956-10-19",
        "nationality":1,
        "address":{
            "zipCode":"1050011",
            "prefecture":"東京都",
            "city":"港区芝公園",
            "street":"3-6-23",
            "building":""
        },
        "phone":"08022678913",
        "position":"test部",
        "experienced":false
    },
    "substantialControllers":[
        {
            "type":1,
            "familyName":"法人",
            "givenName":"二郎1",
            "familyNamePhonetic":"ホウジン",
            "givenNamePhonetic":"ジロウ",
            "birthday":"1963-11-04",
            "address":{
                "zipCode":"1050011",
                "prefecture":"東京都",
                "city":"港区芝公園",
                "street":"3-6-23",
                "building":""
            }
        },
        {
            "type":1,
            "familyName":"法人",
            "givenName":"三郎1",
            "familyNamePhonetic":"ホウジン",
            "givenNamePhonetic":"サブロウ",
            "birthday":"1964-07-02",
            "address":{
                "zipCode":"1050011",
                "prefecture":"東京都",
                "city":"港区芝公園",
                "street":"3-6-23",f
                "building":""
            }
        }
    ],
    "companyType":0,
    "publisherOrManager":false,
    "publisherOrManagerCurrencies":"",
    "cryptocurrencyExchanger":false,
    "supervisorOrAssociation":false,
    "others":false,
    "othersCurrencies":"",
    "capital":105,
    "sales":102,
    "financialAssets":3,
    "experience":{
        "years":0,
        "spot":true,
        "fx":false,
        "crypto":true,
        "other":false
    },
    "intention":3,
    "media":9,
    "wantCampaign":false,
    "bankAccount":{
        "accountType":0,
        "bankCode":"0005",
        "bankName":"三菱UFJ",
        "branchCode":"060",
        "branchName":"江戸川橋",
        "bankAccountNumber":"0000011"
    },"appliedWeb3Wallet":true
}
"""

# 1. JSON文字列をPythonの辞書に変換
data = json.loads(json_data)

# 2. substantialControllers配列を事前に処理する
# substantialControllers配列を削除し、データフレーム化の対象から除外します
substantial_controllers = data.pop('substantialControllers')

# 3. JSONをフラット化（ネストを解消）し、DataFrameを作成
# ネストされたオブジェクト（address, director, manager, bankAccount, experience）をフラット化します
df = json_normalize(data, sep='_')

# 4. substantialControllers配列のデータを展開して結合する
# 配列の各要素をフラット化し、元のデータフレームに結合するために列名にプレフィックスを付けます
for i, sc in enumerate(substantial_controllers):
    # 配列内の要素をフラット化
    sc_df = json_normalize(sc, sep='_')
    # 列名にインデックスとプレフィックスを追加 (例: sc_0_familyName, sc_0_address_zipCode)
    sc_df = sc_df.rename(columns=lambda x: f'sc_{i}_{x}')
    # 元のデータフレームと結合
    # dfは1行しかないので、sc_dfをconcatする必要がある
    
    # 結合用に元のdfを複製し、新しい列を追加
    df = pd.concat([df, sc_df], axis=1)
    # 値が1行なので、インデックスをリセットして結合することで、全ての列が並んだ1行のデータフレームが完成します。


# 5. CSVファイルとして書き出し
output_filename = 'output_complex_test.csv'

# index=Falseで、左端のインデックス（0, 1, 2...）が出力されないようにします
# encoding='utf-8-sig' で、CSVをExcelで開いたときに文字化けしないようにBOM付きUTF-8を使用します
df.to_csv(output_filename, index=False, encoding='utf-8-sig')

print(f"✅ CSVファイルが正常に作成されました: {output_filename}")