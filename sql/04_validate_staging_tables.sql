-- =====================================================
-- VALIDATE STAGING TABLES
-- =====================================================

-- 1. Check row count comparison
SELECT 'customers' AS table_name,
       (SELECT COUNT(*) FROM raw.customers) AS raw_count,
       (SELECT COUNT(*) FROM staging.customers) AS staging_count
UNION ALL
SELECT 'sellers' AS table_name,
       (SELECT COUNT(*) FROM raw.sellers) AS raw_count,
       (SELECT COUNT(*) FROM staging.sellers) AS staging_count
UNION ALL
SELECT 'orders' AS table_name,
       (SELECT COUNT(*) FROM raw.orders) AS raw_count,
       (SELECT COUNT(*) FROM staging.orders) AS staging_count
UNION ALL
SELECT 'order_items' AS table_name,
       (SELECT COUNT(*) FROM raw.order_items) AS raw_count,
       (SELECT COUNT(*) FROM staging.order_items) AS staging_count
UNION ALL
SELECT 'order_payments' AS table_name,
       (SELECT COUNT(*) FROM raw.order_payments) AS raw_count,
       (SELECT COUNT(*) FROM staging.order_payments) AS staging_count
UNION ALL
SELECT 'order_reviews' AS table_name,
       (SELECT COUNT(*) FROM raw.order_reviews) AS raw_count,
       (SELECT COUNT(*) FROM staging.order_reviews) AS staging_count
UNION ALL
SELECT 'products' AS table_name,
       (SELECT COUNT(*) FROM raw.products) AS raw_count,
       (SELECT COUNT(*) FROM staging.products) AS staging_count;


-- 2. Check duplicate primary business keys
SELECT 
    'staging.customers' AS table_name,
    customer_id AS key_value,
    COUNT(*) AS duplicate_count
FROM staging.customers
GROUP BY customer_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'staging.sellers' AS table_name,
    seller_id AS key_value,
    COUNT(*) AS duplicate_count
FROM staging.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'staging.orders' AS table_name,
    order_id AS key_value,
    COUNT(*) AS duplicate_count
FROM staging.orders
GROUP BY order_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'staging.products' AS table_name,
    product_id AS key_value,
    COUNT(*) AS duplicate_count
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 3. Check order date logic
SELECT
    COUNT(*) AS total_orders,
    COUNT(order_purchase_timestamp) AS orders_with_purchase_date,
    COUNT(order_delivered_customer_date) AS orders_with_delivered_date,
    COUNT(order_estimated_delivery_date) AS orders_with_estimated_date,
    SUM(CASE WHEN is_late_delivery = TRUE THEN 1 ELSE 0 END) AS total_late_orders
FROM staging.orders;


-- 4. Check negative price or freight
SELECT *
FROM staging.order_items
WHERE price < 0
   OR freight_value < 0;


-- 5. Check invalid payment value
SELECT *
FROM staging.order_payments
WHERE payment_value < 0;


-- 6. Check invalid review score
SELECT *
FROM staging.order_reviews
WHERE review_score < 1
   OR review_score > 5;


-- 7. Preview cleaned order data
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    delivery_days,
    is_late_delivery
FROM staging.orders
LIMIT 20;


-- 8. Preview cleaned product data
SELECT
    product_id,
    product_category_name,
    product_category_name_english,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM staging.products
LIMIT 20;