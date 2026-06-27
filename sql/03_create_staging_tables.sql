-- =====================================================
-- CREATE STAGING TABLES
-- =====================================================

CREATE SCHEMA IF NOT EXISTS staging;


-- =====================================================
-- 1. STAGING CUSTOMERS
-- =====================================================

DROP TABLE IF EXISTS staging.customers;

CREATE TABLE staging.customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix::INTEGER AS customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers
WHERE customer_id IS NOT NULL;


-- =====================================================
-- 2. STAGING SELLERS
-- =====================================================

DROP TABLE IF EXISTS staging.sellers;

CREATE TABLE staging.sellers AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix::INTEGER AS seller_zip_code_prefix,
    INITCAP(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM raw.sellers
WHERE seller_id IS NOT NULL;


-- =====================================================
-- 3. STAGING ORDERS
-- =====================================================

DROP TABLE IF EXISTS staging.orders;

CREATE TABLE staging.orders AS
SELECT DISTINCT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::TIMESTAMP AS order_purchase_timestamp,
    order_approved_at::TIMESTAMP AS order_approved_at,
    order_delivered_carrier_date::TIMESTAMP AS order_delivered_carrier_date,
    order_delivered_customer_date::TIMESTAMP AS order_delivered_customer_date,
    order_estimated_delivery_date::TIMESTAMP AS order_estimated_delivery_date,

    CASE
        WHEN order_delivered_customer_date IS NOT NULL
        THEN EXTRACT(DAY FROM (order_delivered_customer_date::TIMESTAMP - order_purchase_timestamp::TIMESTAMP))
        ELSE NULL
    END AS delivery_days,

    CASE
        WHEN order_delivered_customer_date IS NOT NULL
             AND order_delivered_customer_date::TIMESTAMP > order_estimated_delivery_date::TIMESTAMP
        THEN TRUE
        ELSE FALSE
    END AS is_late_delivery

FROM raw.orders
WHERE order_id IS NOT NULL;


-- =====================================================
-- 4. STAGING ORDER ITEMS
-- =====================================================

DROP TABLE IF EXISTS staging.order_items;

CREATE TABLE staging.order_items AS
SELECT
    order_id,
    order_item_id::INTEGER AS order_item_id,
    product_id,
    seller_id,
    shipping_limit_date::TIMESTAMP AS shipping_limit_date,
    price::NUMERIC(12,2) AS price,
    freight_value::NUMERIC(12,2) AS freight_value
FROM raw.order_items
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL
  AND seller_id IS NOT NULL;


-- =====================================================
-- 5. STAGING ORDER PAYMENTS
-- =====================================================

DROP TABLE IF EXISTS staging.order_payments;

CREATE TABLE staging.order_payments AS
SELECT
    order_id,
    payment_sequential::INTEGER AS payment_sequential,
    payment_type,
    payment_installments::INTEGER AS payment_installments,
    payment_value::NUMERIC(12,2) AS payment_value
FROM raw.order_payments
WHERE order_id IS NOT NULL;


-- =====================================================
-- 6. STAGING ORDER REVIEWS
-- =====================================================

DROP TABLE IF EXISTS staging.order_reviews;

CREATE TABLE staging.order_reviews AS
SELECT
    review_id,
    order_id,
    review_score::INTEGER AS review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date::TIMESTAMP AS review_creation_date,
    review_answer_timestamp::TIMESTAMP AS review_answer_timestamp
FROM raw.order_reviews
WHERE review_id IS NOT NULL
  AND order_id IS NOT NULL;


-- =====================================================
-- 7. STAGING PRODUCTS
-- =====================================================

DROP TABLE IF EXISTS staging.products;

CREATE TABLE staging.products AS
SELECT
    p.product_id,
    p.product_category_name,
    ct.product_category_name_english,
    p.product_name_lenght::INTEGER AS product_name_length,
    p.product_description_lenght::INTEGER AS product_description_length,
    p.product_photos_qty::INTEGER AS product_photos_qty,
    p.product_weight_g::NUMERIC(12,2) AS product_weight_g,
    p.product_length_cm::NUMERIC(12,2) AS product_length_cm,
    p.product_height_cm::NUMERIC(12,2) AS product_height_cm,
    p.product_width_cm::NUMERIC(12,2) AS product_width_cm
FROM raw.products p
LEFT JOIN raw.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE p.product_id IS NOT NULL;


-- =====================================================
-- 8. STAGING GEOLOCATION
-- =====================================================

DROP TABLE IF EXISTS staging.geolocation;

CREATE TABLE staging.geolocation AS
SELECT
    geolocation_zip_code_prefix::INTEGER AS geolocation_zip_code_prefix,
    AVG(geolocation_lat::NUMERIC) AS avg_geolocation_lat,
    AVG(geolocation_lng::NUMERIC) AS avg_geolocation_lng,
    INITCAP(TRIM(geolocation_city)) AS geolocation_city,
    UPPER(TRIM(geolocation_state)) AS geolocation_state
FROM raw.geolocation
WHERE geolocation_zip_code_prefix IS NOT NULL
GROUP BY 
    geolocation_zip_code_prefix,
    INITCAP(TRIM(geolocation_city)),
    UPPER(TRIM(geolocation_state));


-- =====================================================
-- CHECK STAGING TABLES
-- =====================================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
ORDER BY table_name;