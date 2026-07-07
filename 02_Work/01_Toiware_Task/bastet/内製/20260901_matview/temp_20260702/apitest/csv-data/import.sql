-- ============================================================================
-- staking_rewards_view パフォーマンステスト用データ import スクリプト
-- ============================================================================
-- 事前準備:
--   1) import.sql と各CSVを以下に配置
--      <project-root>/apitest/csv-data/import.sql
--      <project-root>/apitest/csv-data/*.csv
--   2) PostgreSQLクライアント(psql)が利用可能であることを確認
--      例: psql --version
--
-- 実行方法（プロジェクトルートから）:
--   cd <project-root>
--   psql -U <user> -d <dbname> -f apitest/csv-data/import.sql
--
-- データ概要（2026-07-02時点）:
--   通貨数: 16銘柄（XTZ/BERA除外済み。18銘柄から変更）
--   fx_c_day_margin_status_ccy : 888,880行
--     - 対象月(20260615) : 5,556 accounts × 16通貨 = 88,896行 → view HIT想定
--     - 他月(20251115)   : 49,999 accounts × 16通貨 = 799,984行 → view 非HIT
--   staking_rewards_total       : 16行 (16通貨 × period=202606)
--   その他テーブル               : entry=10 / exclusion=10 / distribution=10 / additional_account=3
--
-- 注意:
--   このスクリプトは staking_rewards_total のみ TRUNCATE しています。
--   他テーブルを再実行時に重複させたくない場合は、実行前に別途TRUNCATEしてください。
-- ============================================================================

\COPY fx_c_day_margin_status_ccy (account_id, currency, front_ymd_date, cash_balance, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/fx_c_day_margin_status_ccy.csv' WITH (FORMAT CSV, HEADER TRUE);

truncate table staking_rewards_total;
\COPY staking_rewards_total (currency, period, total_rewards, customer_rewards_rate, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/staking_rewards_total.csv' WITH (FORMAT CSV, HEADER TRUE);

\COPY staking_rewards_entry (account_id, currency, is_reward_rejection, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/staking_rewards_entry.csv' WITH (FORMAT CSV, HEADER TRUE);
\COPY staking_rewards_exclusion (account_id, currency, is_exclusion, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/staking_rewards_exclusion.csv' WITH (FORMAT CSV, HEADER TRUE);
\COPY staking_rewards_distribution (account_id, currency, period, is_distribution, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/staking_rewards_distribution.csv' WITH (FORMAT CSV, HEADER TRUE);
\COPY staking_rewards_additional_account (account_name, currency, period, total_cash_balance, register_datetime, register_user, update_datetime, update_user, delete_flag, version) FROM 'apitest/csv-data/staking_rewards_additional_account.csv' WITH (FORMAT CSV, HEADER TRUE);
