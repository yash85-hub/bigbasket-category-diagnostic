-- ============================================================
-- 01_foundations.sql — Foundational SQL: SELECT/WHERE, DISTINCT,
-- ORDER BY+LIMIT, Alias, IN, BETWEEN/NOT BETWEEN, IS NULL
-- ============================================================

-- 1. SELECT / WHERE — all orders placed by customers in Bengaluru
SELECT o.order_id, c.name, c.city, o.order_date, o.amount_inr
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = 'Bengaluru';

-- 2. DISTINCT — list every distinct category
SELECT DISTINCT category
FROM products;

-- 3. ORDER BY + LIMIT — the 5 highest-value orders by amount_inr
SELECT order_id, customer_id, product_id, amount_inr
FROM orders
ORDER BY amount_inr DESC
LIMIT 5;

-- 4. Alias (AS) — rename an aggregate in the output
SELECT COUNT(*) AS total_orders
FROM orders;

-- 5. IN — orders whose payment_mode is in a 2-mode list
SELECT order_id, payment_mode, amount_inr
FROM orders
WHERE payment_mode IN ('UPI', 'Credit Card');

-- 6. BETWEEN — orders with amount_inr between 200 and 500 (inclusive)
SELECT order_id, amount_inr
FROM orders
WHERE amount_inr BETWEEN 200 AND 500;

-- 7. NOT BETWEEN — orders with amount_inr outside the 200–500 range
SELECT order_id, amount_inr
FROM orders
WHERE amount_inr NOT BETWEEN 200 AND 500;

-- 8. IS NULL — orders with no rating recorded
-- (these are exactly the Cancelled/Pending orders, which never receive a rating)
SELECT order_id, status, rating
FROM orders
WHERE rating IS NULL;
