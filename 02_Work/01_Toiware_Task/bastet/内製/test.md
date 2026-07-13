事前準備：パスワードハッシュの生成

passwordはSHA-256を1000回ストレッチしてBase64エンコードする独自方式です。EC2踏み台で以下を実行してハッシュ値を生成してください。

python3 -c "
import hashlib, base64
p = b'Test1234!'          # ← 使いたいパスワードに変更
for _ in range(1000):
    p = hashlib.sha256(p).digest()
print(base64.b64encode(p).decode())
"

出力されたハッシュ値を後述のスクリプトの PASSWORD_HASH に設定します。

---
SQLスクリプト本体

-- ============================================================
-- STG環境テスト用 本登録完了アカウント作成スクリプト（個人）
-- 使い方:
--   psql -U signupadmin -d s25signup \
--     -v ACCOUNT_ID="'19990001'" \
--     -v EMAIL="'test01@example.com'" \
--     -v PHONE="'09000000001'" \
--     -v PASSWORD_HASH="'上記コマンドで生成したハッシュ値'" \
--     -f create_test_account.sql
-- ============================================================

-- 1. account（本登録完了状態）
INSERT INTO account (
  ACCOUNT_ID, CUSTOMER_TYPE,
  EXAMINATION_STATUS, EXAMINATION_RESULT, APPLICATION_TYPE,
  PASSWORD, MAIN_EMAIL,
  YAHOO_ASSOCIATED, FACEBOOK_ASSOCIATED, RAKUTEN_ASSOCIATED,
  AMAZON_ASSOCIATED, TWITTER_ASSOCIATED,
  ACCOUNT_STATUS,
  TEMPORARY_APPLIED_DATETIME, TEMPORARY_REGISTERED_DATETIME,
  PERMANENT_APPLIED_DATETIME, PERMANENT_REGISTERED_DATETIME,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID, 1,
  9, 9, 9,
  :PASSWORD_HASH, :EMAIL,
  0, 0, 0, 0, 0,
  6,
  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

-- 2. individual_account
INSERT INTO individual_account (
  ACCOUNT_ID,
  FAMILY_NAME, GIVEN_NAME, FAMILY_NAME_PHONETIC, GIVEN_NAME_PHONETIC,
  BIRTHDAY, GENDER, ZIP_CODE, PREFECTURE, CITY, STREET,
  PHONE, NOTIFICATION_EMAIL, ACTIVATION_CODE,
  PRIMARY_EXAMINED_USER, PRIMARY_EXAMINED_DATETIME,
  SECONDARY_EXAMINED_USER, SECONDARY_EXAMINED_DATETIME,
  FINAL_EXAMINED_USER, FINAL_EXAMINED_DATETIME,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID,
  '山田', '太郎', 'ヤマダ', 'タロウ',
  TO_DATE('1990-01-01', 'YYYY-MM-DD'), 1, '1050023', '東京都', '港区', '芝浦1-2-3',
  :PHONE, :EMAIL, '1234567',
  'admin', CURRENT_TIMESTAMP,
  'admin', CURRENT_TIMESTAMP,
  'admin', CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

-- 3. vct_individual_account（accountとindividual_accountから生成）
INSERT INTO vct_individual_account (
  CUST_ID, STATUS, BIRTHDAY,
  FAMILY_NAME, FIRST_NAME, FAMILY_NAME_KANA, FIRST_NAME_KANA,
  GENDER, ZIP, PREFECTURE, CITY, TOWN, ROOM,
  EMAIL, TELEPHONE, MOBILE_PHONE, OPEN_DATE,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
)
SELECT
  ac.ACCOUNT_ID, ac.ACCOUNT_STATUS, TO_CHAR(ia.BIRTHDAY, 'fmyyyy/mm/dd'),
  ia.FAMILY_NAME, ia.GIVEN_NAME, ia.FAMILY_NAME_PHONETIC, ia.GIVEN_NAME_PHONETIC,
  CASE ia.GENDER WHEN 1 THEN 'MALE' ELSE 'FEMALE' END,
  ia.ZIP_CODE, ia.PREFECTURE, ia.CITY, ia.STREET, '',
  ac.MAIN_EMAIL, ia.PHONE, ia.PHONE,
  TO_CHAR(ac.REGISTER_DATETIME, 'yyyy/mm/dd hh:mi:ss'),
  CURRENT_TIMESTAMP, 'init',
  CURRENT_TIMESTAMP, 'init',
  false, 0
FROM account ac
  INNER JOIN individual_account ia ON ia.ACCOUNT_ID = ac.ACCOUNT_ID
WHERE ac.ACCOUNT_ID = :ACCOUNT_ID;

-- 4. antisocial_check
INSERT INTO antisocial_check (
  ACCOUNT_ID, USER_ATTRIBUTE, KYC_FLAG, CHECK_GROUP_KEY,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID, 0, true, 'TEST_GROUP_KEY',
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

-- 5. enquete
INSERT INTO enquete (
  ACCOUNT_ID, OCCUPATION, INCOME, OCCUPATION_DETAIL,
  FINANCIAL_ASSETS, EXPERIENCE, EXPERIENCE_SPOT, EXPERIENCE_FX,
  EXPERIENCE_CRYPTO, EXPERIENCE_OTHER, INTENTION, MEDIA, WANT_CAMPAIGN,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID, 2, 0, 0,
  0, 0, 1, 0,
  0, 0, 1, 1, 1,
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

-- 6. payment_account
INSERT INTO payment_account (
  ACCOUNT_ID, ACCOUNT_TYPE,
  BANK_CODE, BANK_NAME, BRANCH_CODE, BRANCH_NAME,
  BANK_ACCOUNT_NUMBER, ACCOUNT_HOLDER_PHONETIC,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID, 0,
  '0005', '三菱UFJ銀行', '590', '調布支店',
  '1234567', 'ヤマダ タロウ',
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

-- 7. delivery_status
INSERT INTO delivery_status (
  ACCOUNT_ID, DELIVERY_NO, DELIVERY_STATUS, DELIVERY_DATETIME,
  INDIVIDUAL, DIRECTOR, MANAGER, SXI_TRANSFER_FLAG,
  REGISTER_DATETIME, REGISTER_USER,
  UPDATE_DATETIME, UPDATE_USER,
  DELETE_FLAG, VERSION
) VALUES (
  :ACCOUNT_ID, '0000000000000001', 3, CURRENT_TIMESTAMP,
  1, 0, 0, false,
  CURRENT_TIMESTAMP, 'admin',
  CURRENT_TIMESTAMP, 'admin',
  false, 0
);

---
実行例

# EC2踏み台にSSH後
psql -h s25-signup-cluster.xxxx.rds.amazonaws.com \
     -U signupadmin -d s25signup \
     -v ACCOUNT_ID="'19990001'" \
     -v EMAIL="'test01@example.com'" \
     -v PHONE="'09000000001'" \
     -v PASSWORD_HASH="'生成したハッシュ値'" \
     -f create_test_account.sql

---
注意点

- ekyc_examination / trustdock_record は status=6の直接作成なら不要（テストデータにも含まれていない）
- 同じaccount_idで再実行するとPK重複エラーになるので、使い捨てにするか実行前に削除するかを決めておく
- STGのRDSホスト名は application-stg.properties に記載されています

このスクリプトをファイルに保存して踏み台に置いておけば、次回からは変数を変えるだけで新しいテストアカウントが30秒で作れます。試してみますか？