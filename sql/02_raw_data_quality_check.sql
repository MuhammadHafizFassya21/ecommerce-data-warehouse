-- =====================================================
-- RAW DATA QUALITY CHECK
-- =====================================================

-- 1. Check row count for each raw table
SELECT 'raw.customers' AS table_name, COUNT(*) AS total_rows FROM raw.customers
UNION ALL
SELECT 'raw.geolocation' AS table_name, COUNT(*) AS total_rows FROM raw.geolocation
UNION ALL
SELECT 'raw.order_items' AS table_name, COUNT(*) AS total_rows FROM raw.order_items
UNION ALL
SELECT 'raw.order_payments' AS table_name, COUNT(*) AS total_rows FROM raw.order_payments
UNION ALL
SELECT 'raw.order_reviews' AS table_name, COUNT(*) AS total_rows FROM raw.order_reviews
UNION ALL
SELECT 'raw.orders' AS table_name, COUNT(*) AS total_rows FROM raw.orders
UNION ALL
SELECT 'raw.products' AS table_name, COUNT(*) AS total_rows FROM raw.products
UNION ALL
SELECT 'raw.sellers' AS table_name, COUNT(*) AS total_rows FROM raw.sellers
UNION ALL
SELECT 'raw.category_translation' AS table_name, COUNT(*) AS total_rows FROM raw.category_translation;


-- 2. Check order status distribution
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 3. Check missing values in orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_not_null,
    COUNT(customer_id) AS customer_id_not_null,
    COUNT(order_status) AS order_status_not_null,
    COUNT(order_purchase_timestamp) AS purchase_timestamp_not_null,
    COUNT(order_delivered_customer_date) AS delivered_customer_date_not_null,
    COUNT(order_estimated_delivery_date) AS estimated_delivery_date_not_null
FROM raw.orders;


-- 4. Check duplicate order_id
SELECT 
    order_id,
    COUNT(*) AS duplicate_count
FROM raw.orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 5. Check missing values in customers
SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS customer_id_not_null,
    COUNT(customer_unique_id) AS customer_unique_id_not_null,
    COUNT(customer_city) AS customer_city_not_null,
    COUNT(customer_state) AS customer_state_not_null
FROM raw.customers;


-- 6. Check missing values in products
SELECT
    COUNT(*) AS total_rows,
    COUNT(product_id) AS product_id_not_null,
    COUNT(product_category_name) AS product_category_name_not_null,
    COUNT(product_weight_g) AS product_weight_g_not_null,
    COUNT(product_length_cm) AS product_length_cm_not_null,
    COUNT(product_height_cm) AS product_height_cm_not_null,
    COUNT(product_width_cm) AS product_width_cm_not_null
FROM raw.products;


-- 7. Check payment type distribution
SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment_value
FROM raw.order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- 8. Check review score distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM raw.order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 9. Check product categories
SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM raw.products
GROUP BY product_category_name
ORDER BY total_products DESC
LIMIT 20;


-- 10. Check seller state distribution
SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM raw.sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;