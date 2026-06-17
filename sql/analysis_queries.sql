-- ============================================
-- Sales Performance Analysis — Northwind Database
-- Author: Vaishnavi Samala
-- ============================================

-- Query 1: Top 10 customers by total revenue
-- Business question: Who are our most valuable customers?
SELECT 
    c.company_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.company_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 2: Month-over-month revenue trend
-- Business question: Is revenue growing or shrinking month to month?
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month)) * 100, 
        2
    ) AS pct_change
FROM monthly_revenue
ORDER BY month;


-- Query 3: Top-selling products by revenue, with category and rank
-- Business question: Which products actually drive our revenue?
SELECT 
    p.product_name,
    c.category_name,
    SUM(od.quantity) AS total_units_sold,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(od.unit_price * od.quantity * (1 - od.discount)) DESC) AS revenue_rank
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Query 4: At-risk customers (recency analysis)
-- Business question: Which customers haven't ordered in the longest time?
WITH last_order_per_customer AS (
    SELECT 
        c.customer_id,
        c.company_name,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.company_name
),
most_recent_date AS (
    SELECT MAX(order_date) AS dataset_max_date FROM orders
)
SELECT 
    l.company_name,
    l.last_order_date,
    (SELECT dataset_max_date FROM most_recent_date) - l.last_order_date AS days_since_last_order
FROM last_order_per_customer l
ORDER BY days_since_last_order DESC
LIMIT 10;


-- Query 5: Order fulfillment performance (on-time vs late shipping)
-- Business question: How reliably are we meeting shipping commitments?
SELECT 
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE shipped_date IS NULL) AS not_yet_shipped,
    COUNT(*) FILTER (WHERE shipped_date > required_date) AS shipped_late,
    COUNT(*) FILTER (WHERE shipped_date <= required_date) AS shipped_on_time,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE shipped_date > required_date) / 
        COUNT(*) FILTER (WHERE shipped_date IS NOT NULL), 
        2
    ) AS pct_late_of_shipped
FROM orders;