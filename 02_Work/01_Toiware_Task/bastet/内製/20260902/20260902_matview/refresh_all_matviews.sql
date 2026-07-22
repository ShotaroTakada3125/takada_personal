-- タイミング計測機能を有効化
\timing on

\echo '=== [1/16] DOT REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_dot;

\echo '=== [2/16] ADA REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_ada;

\echo '=== [3/16] AVAX REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_avax;

\echo '=== [4/16] ETH REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_eth;

\echo '=== [5/16] SOL REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_sol;

\echo '=== [6/16] OAS REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_oas;

\echo '=== [7/16] ATOM REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_atom;

\echo '=== [8/16] XDC REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_xdc;

\echo '=== [9/16] FLR REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_flr;

\echo '=== [10/16] APT REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_apt;

\echo '=== [11/16] HBAR REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_hbar;

\echo '=== [12/16] NEAR REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_near;

\echo '=== [13/16] TRX REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_trx;

\echo '=== [14/16] SUI REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_sui;

\echo '=== [15/16] TON REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_ton;

\echo '=== [16/16] ALGO REFRESH START ==='
REFRESH MATERIALIZED VIEW fx_c_day_margin_status_ccy_algo;