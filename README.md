# 🛒 Brazilian E-Commerce Sales Analytics (SQL)

## 📌 Executive Summary
This project analyzes **100,000+ real-world e-commerce orders** from the Olist marketplace dataset in Brazil. The objective is to evaluate overall revenue performance, customer purchasing behavior, payment preferences, and logistics delivery efficiency using **Advanced SQL**.

Key findings and business recommendations are extracted to help marketplace operators optimize delivery performance and boost high-value category sales.

---

## 🛠️ Tech Stack & Tools
* **Language:** SQL (ANSI SQL standard)
* **SQL Engine:** DuckDB (In-memory analytical SQL)
* **Environment:** Kaggle Notebooks
* **Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 📊 Business Questions & SQL Analysis

### 🟢 1. Overall Revenue & Order Volume
**Business Question:** What is the total revenue generated and the total volume of distinct orders on the platform?

```sql
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue
FROM '/kaggle/input/brazilian-ecommerce/olist_order_items_dataset.csv';
```
* **Key Finding:** Generated over **$13.5M+ in revenue** across **98,000+ distinct orders**.

---

### 🟢 2. Top 5 Revenue-Generating Product Categories
**Business Question:** Which product categories contribute the most to the platform's overall revenue?

```sql
SELECT 
    p.product_category_name AS category_name,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM '/kaggle/input/brazilian-ecommerce/olist_order_items_dataset.csv' i
JOIN '/kaggle/input/brazilian-ecommerce/olist_products_dataset.csv' p 
  ON i.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY category_name
ORDER BY total_revenue DESC
LIMIT 5;
```
* **Key Finding:** *Beleza e Saude* (Health & Beauty) and *Relogios e Presentes* (Watches & Gifts) lead the marketplace as the highest revenue-generating product segments.

---

### 🔵 3. Payment Method Popularity & Average Order Value (AOV)
**Business Question:** What are the most preferred payment methods, and what is the Average Order Value (AOV) per payment type?

```sql
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM '/kaggle/input/brazilian-ecommerce/olist_order_payments_dataset.csv'
GROUP BY payment_type
ORDER BY total_orders DESC;
```
* **Key Finding:** **Credit Cards** dominate transaction volume (>75%), while voucher payments yield a lower average transaction value.

---

### 🔴 4. Month-over-Month (MoM) Growth Analysis
**Business Question:** How does monthly revenue trend over time, and what is the Month-over-Month (MoM) growth percentage?

```sql
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', CAST(o.order_purchase_timestamp AS TIMESTAMP)) AS month,
        ROUND(SUM(i.price), 2) AS total_revenue
    FROM '/kaggle/input/brazilian-ecommerce/olist_orders_dataset.csv' o
    JOIN '/kaggle/input/brazilian-ecommerce/olist_order_items_dataset.csv' i 
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
```
* **Key Finding:** Sales showed strong upward momentum throughout Q3 and Q4, peaking significantly during annual promotional campaigns (Black Friday).

---

### 🔴 5. Delivery Performance & Late Deliveries Rate
**Business Question:** What is the average order delivery time, and what percentage of orders arrive later than the estimated delivery date?

```sql
SELECT 
    ROUND(AVG(DATE_DIFF('day', CAST(order_purchase_timestamp AS TIMESTAMP), CAST(order_delivered_customer_date AS TIMESTAMP))), 1) AS avg_delivery_days,
    ROUND(COUNT(CASE WHEN CAST(order_delivered_customer_date AS TIMESTAMP) > CAST(order_estimated_delivery_date AS TIMESTAMP) THEN 1 END) * 100.0 / COUNT(order_id), 2) AS late_delivery_percentage
FROM '/kaggle/input/brazilian-ecommerce/olist_orders_dataset.csv'
WHERE order_status = 'delivered';
```
* **Key Finding:** The average delivery fulfillment cycle takes **12.5 days**, with approximately **6.8%** of orders experiencing shipping delays past estimated dates.

---

## 💡 Strategic Business Recommendations

1. **Optimize Supply Chain Logistics:** Partner with localized fulfillment hubs in regions experiencing >7% late delivery rates to reduce fulfillment times and improve customer retention.
2. **Incentivize Credit Card Installments:** Since credit card purchases drive the highest Average Order Value (AOV), run targeted zero-interest installment promos on top categories (*Health & Beauty*, *Watches*).
3. **Cross-Selling Strategies:** Bundle products from top-performing categories with lower-performing items to increase overall shopping cart values.

---

## 🚀 How to Run This Project
1. Clone this repository:
   ```bash
   git clone https://github.com/hanamaisrh/Brazilian-Ecommerce-Sales-Analytics-SQL.git
   ```
2. Open the Kaggle Notebook or any DuckDB SQL environment.
3. Load the Olist E-Commerce dataset files and execute the queries directly.
