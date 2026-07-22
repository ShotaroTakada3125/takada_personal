-- 実行時間を計測できるようにする
\timing on

-- ==========================================
-- 1. ETH (5,000,000 件)
-- ==========================================
\echo '=== [1/6] Inserting ETH (5,000,000 rows) ==='
INSERT INTO fx_c_day_margin_status_ccy (
    account_id, currency, front_ymd_date, cash_balance,
    register_datetime, register_user, update_datetime, update_user, delete_flag, version
)
SELECT 
    to_char(s, 'FM00000000'), -- 8桁ゼロ埋め (例: 00000001)
    'ETH',
    '20260601',
    0.00,
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 5000000 * interval '28 days'), -- 6/2〜6/30の間で昇順に均等分散
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 5000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(1, 5000000) AS s;


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
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 2000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 2000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(1, 2000000) AS s;


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
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 2000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 2000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(1, 2000000) AS s;


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
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 1000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 1000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(1, 1000000) AS s;


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
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 1000000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s - 1)::double precision / 1000000 * interval '28 days'),
    'none',
    false,
    0
FROM generate_series(1, 1000000) AS s;


-- ==========================================
-- 6. 残りの11銘柄 (各 400,000 件 × 11銘柄 = 4,400,000 件)
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
    '2026-06-02 00:00:00'::timestamp + ((s.idx - 1)::double precision / 400000 * interval '28 days'),
    'none',
    '2026-06-02 00:00:00'::timestamp + ((s.idx - 1)::double precision / 400000 * interval '28 days'),
    'none',
    false,
    0
FROM (
    VALUES 
        ('ADA'), ('AVAX'), ('OAS'), ('ATOM'), ('APT'), 
        ('HBAR'), ('NEAR'), ('TRX'), ('SUI'), ('TON'), ('ALGO')
) AS m(currency)
CROSS JOIN LATERAL generate_series(1, 400000) AS s(idx);