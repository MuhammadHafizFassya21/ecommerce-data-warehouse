-- =====================================================
-- VALIDATE DATA MART TABLES
-- =====================================================

-- 1. Check mart table row counts
SELECT 'mart.monthly_sales_summary' AS table_name, COUNT(*) AS total_rows
FROM mart.monthly_sales_summary

UNION ALL

SELECT 'mart.product_category_performance' AS table_name, COUNT(*) AS total_rows
FROM mart.product_category_performance

UNION ALL

SELECT 'mart.seller_delivery_performance' AS table_name, COUNT(*) AS total_rows
FROM mart.seller_delivery_performance

UNION ALL

SELECT 'mart.customer_state_summary' AS table_name, COUNT(*) AS total_rows
FROM mart.customer_state_summary

UNION ALL

SELECT 'mart.payment_method_summary' AS table_name, COUNT(*) AS total_rows
FROM mart.payment_method_summary

UNION ALL

SELECT 'mart.review_delivery_summary' AS table_name, COUNT(*) AS total_rows
FROM mart.review_delivery_summary;


-- 2. Validate monthly sales summary
SELECT
    year,
    month,
    month_name,
    total_orders,
    total_revenue,
    average_order_value,
    late_delivery_rate_percent,
    average_review_score
FROM mart.monthly_sales_summary
ORDER BY year, month;


-- 3. Check top 10 product categories
SELECT
    product_category,
    total_items_sold,
    total_orders,
    total_product_sales,
    total_sales_with_freight,
    late_delivery_rate_percent
FROM mart.product_category_performance
ORDER BY total_product_sales DESC
LIMIT 10;


-- 4. Check top 10 sellers by sales
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_items_sold,
    total_product_sales,
    late_delivery_rate_percent
FROM mart.seller_delivery_performance
ORDER BY total_product_sales DESC
LIMIT 10;


-- 5. Check sellers with high late delivery rate
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_items_sold,
    total_product_sales,
    late_delivery_rate_percent
FROM mart.seller_delivery_performance
WHERE total_items_sold >= 10
ORDER BY late_delivery_rate_percent DESC
LIMIT 10;


-- 6. Check customer state performance
SELECT
    customer_state,
    total_unique_customers,
    total_orders,
    total_revenue,
    average_order_value,
    late_delivery_rate_percent,
    average_review_score
FROM mart.customer_state_summary
ORDER BY total_revenue DESC;


-- 7. Check payment method performance
SELECT
    payment_type,
    SUM(total_payment_records) AS total_payment_records,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_payment_value)::NUMERIC, 2) AS total_payment_value,
    ROUND(AVG(average_payment_value)::NUMERIC, 2) AS average_payment_value
FROM mart.payment_method_summary
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 8. Check review and delivery relationship
SELECT
    delivery_status_group,
    total_orders,
    average_delivery_days,
    average_review_score,
    low_review_rate_percent
FROM mart.review_delivery_summary
ORDER BY delivery_status_group;


-- 9. Check for negative values in monthly summary
SELECT *
FROM mart.monthly_sales_summary
WHERE total_orders < 0
   OR total_revenue < 0
   OR average_order_value < 0;


-- 10. Check for missing important values
SELECT
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS missing_year,
    SUM(CASE WHEN month IS NULL THEN 1 ELSE 0 END) AS missing_month,
    SUM(CASE WHEN total_orders IS NULL THEN 1 ELSE 0 END) AS missing_total_orders,
    SUM(CASE WHEN total_revenue IS NULL THEN 1 ELSE 0 END) AS missing_total_revenue
FROM mart.monthly_sales_summary;