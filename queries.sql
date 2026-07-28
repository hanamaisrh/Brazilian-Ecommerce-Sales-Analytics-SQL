-- ============================================================
-- Project: Brazilian E-Commerce Sales Analytics
-- Author: Hana Maisarah
-- SQL Engine: DuckDB / ANSI SQL
-- Dataset: Olist E-Commerce Public Dataset
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall Revenue & Total Order Volume
-- ------------------------------------------------------------
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue
FROM '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_order_items_dataset.csv';


-- ------------------------------------------------------------
-- 2. Top 5 Revenue-Generating Product Categories
-- ------------------------------------------------------------
SELECT 
    p.product_category_name AS category_name,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_order_items_dataset.csv' i
JOIN '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_products_dataset.csv' p 
  ON i.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY category_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ------------------------------------------------------------
-- 3. Payment Method Popularity & Average Order Value (AOV)
-- ------------------------------------------------------------
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_order_payments_dataset.csv'
GROUP BY payment_type
ORDER BY total_orders DESC;


-- ------------------------------------------------------------
-- 4. Month-over-Month (MoM) Sales Growth Rate
-- ------------------------------------------------------------
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', CAST(o.order_purchase_timestamp AS TIMESTAMP)) AS month,
        ROUND(SUM(i.price), 2) AS total_revenue
    FROM '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_orders_dataset.csv' o
    JOIN '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_order_items_dataset.csv' i 
      ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    STRFTIME(month, '%Y-%m') AS sales_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) / LAG(total_revenue) OVER (ORDER BY month)) * 100, 2) AS mom_growth_pct
FROM monthly_sales
ORDER BY month;


-- ------------------------------------------------------------
-- 5. Delivery Performance & Late Deliveries Percentage
-- ------------------------------------------------------------
SELECT 
    ROUND(AVG(DATE_DIFF('day', CAST(order_purchase_timestamp AS TIMESTAMP), CAST(order_delivered_customer_date AS TIMESTAMP))), 1) AS avg_delivery_days,
    ROUND(COUNT(CASE WHEN CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP) THEN 1 END) * 100.0 / COUNT(order_id), 2) AS late_delivery_percentage
FROM '/kaggle/input/datasets/organizations/olistbr/brazilian-ecommerce/olist_orders_dataset.csv'
WHERE order_status = 'delivered';
