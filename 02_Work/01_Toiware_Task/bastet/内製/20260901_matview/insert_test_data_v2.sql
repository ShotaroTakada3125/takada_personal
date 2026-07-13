\timing on

-- 既存のテストデータを一瞬で全削除
\echo '=== TRUNCATE TABLE ==='
TRUNCATE TABLE fx_c_day_margin_status_ccy;

-- ==========================================
-- 1. ETH (5,000,000 件) ※20000001から開始
-- ==========================================
\echo '=== [1/6] Inserting ETH (5,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'), -- 20000001 〜 25000000 になり、前回と絶対に重複しない
    'ETH',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 5000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 5000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(20000001, 25000000) AS s;

-- ==========================================
-- 2. FLR (2,000,000 件)
-- ==========================================
\echo '=== [2/6] Inserting FLR (2,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'),
    'FLR',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 2000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 2000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(20000001, 22000000) AS s;

-- ==========================================
-- 3. SOL (2,000,000 件)
-- ==========================================
\echo '=== [3/6] Inserting SOL (2,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'),
    'SOL',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 2000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 2000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(20000001, 22000000) AS s;

-- ==========================================
-- 4. DOT (1,000,000 件)
-- ==========================================
\echo '=== [4/6] Inserting DOT (1,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'),
    'DOT',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 1000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 1000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(20000001, 21000000) AS s;

-- ==========================================
-- 5. XDC (1,000,000 件)
-- ==========================================
\echo '=== [5/6] Inserting XDC (1,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'),
    'XDC',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 1000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 20000001)::double precision / 1000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(20000001, 21000000) AS s;

-- ==========================================
-- 6. 残りの11銘柄 (各 400,000 件)
-- ==========================================
\echo '=== [6/6] Inserting Remaining 11 Currencies (400,000 rows each) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s.idx, 'FM00000000'),
    m.currency,
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s.idx - 20000001)::double precision / 400000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s.idx - 20000001)::double precision / 400000 * interval '28 days'),
    'none',
    false,
    0
FROM (
    VALUES 
        ('ADA'), ('AVAX'), ('OAS'), ('ATOM'), ('APT'), 
        ('HBAR'), ('NEAR'), ('TRX'), ('SUI'), ('TON'), ('ALGO')
) AS m(currency)
CROSS JOIN LATERAL generate_series(20000001, 20400000) AS s(idx);