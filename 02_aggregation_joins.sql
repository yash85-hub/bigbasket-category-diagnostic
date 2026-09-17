-- ============================================================
-- 02_aggregation_joins.sql — INNER JOIN + HAVING, LEFT JOIN + COUNT
-- ============================================================

-- (a) INNER JOIN orders to products, GROUP BY category, Delivered only,
--     with HAVING total_revenue > 10000
SELECT
    p.category,
    COUNT(*) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
HAVING total_revenue > 10000;

-- (b) LEFT JOIN products to orders, GROUP BY product, counting orders per
--     product with COUNT(o.order_id) — not COUNT(*), so that the one
--     all-NULL unmatched row (Premium Face Cream 50g, zero orders) counts
--     as 0 rather than 1. Ordered ascending to surface least-ordered products.
SELECT
    p.product_id,
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders ASC;
