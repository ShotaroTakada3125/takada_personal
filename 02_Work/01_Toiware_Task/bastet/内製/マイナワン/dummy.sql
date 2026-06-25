BEGIN;

-- 既存のデータを一度削除
DELETE FROM mynaone_result WHERE mynaone_id IN ('72b47025-920f-416d-a355-506977acd240', 'be6a2586-1dd2-4526-ab41-fb8fe32871ec');
DELETE FROM mynaone_request WHERE mynaone_id IN ('72b47025-920f-416d-a355-506977acd240', 'be6a2586-1dd2-4526-ab41-fb8fe32871ec');

-- 【未提出用】ダミーデータ挿入
INSERT INTO mynaone_request (mynaone_id, account_id, mynaone_status, send_datetime, create_url_datetime, register_type, name, name_phonetic, zip_code, birthday, register_datetime, register_user, update_datetime, update_user, delete_flag, version) 
VALUES ('be6a2586-1dd2-4526-ab41-fb8fe32871ec', 10562150, 2, '2026-06-19 14:43:54', '2026-06-19 00:00:00', 1, '塚原くろ', 'ツカハラ クロ', '105-0011', '19560304', '2026-06-19 14:43:54', '10562150', '2026-06-19 14:43:55', '10562150', false, 1);

INSERT INTO mynaone_result (file_name, file_type, mynaone_id, body, register_datetime, register_user, update_datetime, update_user, delete_flag, version) 
VALUES ('202606171600IFR001.JVCT020EB.error', 'IFR001.JVCT020EB.error', 'be6a2586-1dd2-4526-ab41-fb8fe32871ec', '"D","2","be6a2586-1dd2-4526-ab41-fb8fe32871ec","氏名／会社名の文字種が不正です。半角文字を使用してください。"', '2026-06-17 17:00:15', 'init', '2026-06-17 17:00:15', 'init', false, 0);

-- 【提出済み用】ダミーデータ挿入
INSERT INTO mynaone_request (mynaone_id, account_id, mynaone_status, send_datetime, create_url_datetime, register_type, name, name_phonetic, zip_code, birthday, register_datetime, register_user, update_datetime, update_user, delete_flag, version) 
VALUES ('72b47025-920f-416d-a355-506977acd240', 10562150, 2, '2026-06-17 10:00:00', '2026-06-19 00:00:00', 1, '塚原くろ', 'ツカハラ クロ', '105-0011', '19560304', '2026-06-17 10:00:00', 'anonymousUser', '2026-06-17 10:00:00', 'anonymousUser', false, 1);

INSERT INTO mynaone_result (file_name, file_type, mynaone_id, body, register_datetime, register_user, update_datetime, update_user, delete_flag, version) 
VALUES ('202606171600IFR001.JVCT020EB.error', 'IFR001.JVCT020EB.error', '72b47025-920f-416d-a355-506977acd240', '"D","2","72b47025-920f-416d-a355-506977acd240","氏名／会社名の文字種が不正です。半角文字を使用してください。"', '2026-06-17 17:00:15', 'init', '2026-06-17 17:00:15', 'init', false, 0);

COMMIT;