SELECT
    account_id,
    update_datetime,
    entry_id
FROM
    anap_stock_holder_bonus
WHERE
    update_datetime >= '2026-05-01 00:00:00'
    AND update_datetime < '2026-06-01 00:00:00'
    AND account_id IS NOT NULL
    AND campaign_id IN (
        SELECT id
        FROM campaign
        WHERE name = 'ANAPホールディングス株主優待（2026年6月期）'
    );