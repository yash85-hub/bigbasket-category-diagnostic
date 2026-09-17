-- ============================================================
-- 03_reporting.sql — CASE WHEN tiering, monthly-by-category report,
-- and derived variance/percentage_variance vs category_targets
-- ============================================================

-- (a) Tier every product by its total Delivered revenue
SELECT
    p.product_id,
    p.product_name,
    SUM(o.amount_inr) AS total_revenue,
    CASE
        WHEN SUM(o.amount_inr) >= 3000 THEN 'High'
        WHEN SUM(o.amount_inr) >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_tier
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- (b) Monthly-by-category business report (Delivered orders only)
--     This exact query's result set is exported to monthly_category_revenue.csv
SELECT
    p.category AS category,
    strftime('%Y-%m', o.order_date) AS month,
    COUNT(*) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category, strftime('%Y-%m', o.order_date)
ORDER BY p.category, month;

-- (c) Derived fields: variance & percentage_variance vs category_targets
--     SQLite integer-division note: total_revenue and target_revenue_inr
--     are both INTEGER columns, so (total_revenue - target_revenue_inr) /
--     target_revenue_inr alone truncates to an integer before *100 runs.
--     The formula below multiplies by 100.0 first to preserve the true
--     floating-point percentage.
SELECT
    cat.category,
    cat.total_revenue,
    t.target_revenue_inr,
    (t.target_revenue_inr - cat.total_revenue) AS variance,
    ((cat.total_revenue - t.target_revenue_inr) * 100.0) / t.target_revenue_inr AS percentage_variance,
    CASE
        WHEN cat.total_revenue >= t.target_revenue_inr THEN 'Above Target'
        WHEN ((t.target_revenue_inr - cat.total_revenue) * 100.0) / t.target_revenue_inr <= 15 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS status_tag
FROM (
    SELECT p.category, SUM(o.amount_inr) AS total_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category
) cat
JOIN category_targets t ON cat.category = t.category
ORDER BY percentage_variance ASC;
