-- =====================================================
-- CREATE WAREHOUSE TABLES
-- =====================================================

CREATE SCHEMA IF NOT EXISTS warehouse;


-- =====================================================
-- DROP EXISTING TABLES
-- Drop fact tables first, then dimension tables
-- =====================================================

DROP TABLE IF EXISTS warehouse.fact_order_items;
DROP TABLE IF EXISTS warehouse.fact_orders;

DROP TABLE IF EXISTS warehouse.dim_customers;
DROP TABLE IF EXISTS warehouse.dim_sellers;
DROP TABLE IF EXISTS warehouse.dim_products;
DROP TABLE IF EXISTS warehouse.dim_date;


-- =====================================================
-- 1. DIM CUSTOMERS
-- Grain: one row per customer_id
-- =====================================================

CREATE TABLE warehouse.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_sk,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM staging.customers;


ALTER TABLE warehouse.dim_customers
ADD CONSTRAINT pk_dim_customers PRIMARY KEY (customer_sk);

ALTER TABLE warehouse.dim_customers
ADD CONSTRAINT uq_dim_customers_customer_id UNIQUE (customer_id);


-- =====================================================
-- 2. DIM SELLERS
-- Grain: one row per seller_id
-- =====================================================

CREATE TABLE warehouse.dim_sellers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_sk,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM staging.sellers;


ALTER TABLE warehouse.dim_sellers
ADD CONSTRAINT pk_dim_sellers PRIMARY KEY (seller_sk);

ALTER TABLE warehouse.dim_sellers
ADD CONSTRAINT uq_dim_sellers_seller_id UNIQUE (seller_id);


-- =====================================================
-- 3. DIM PRODUCTS
-- Grain: one row per product_id
-- =====================================================

CREATE TABLE warehouse.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_sk,
    product_id,
    product_category_name,
    COALESCE(product_category_name_english, product_category_name, 'unknown') AS product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM staging.products;


ALTER TABLE warehouse.dim_products
ADD CONSTRAINT pk_dim_products PRIMARY KEY (product_sk);

ALTER TABLE warehouse.dim_products
ADD CONSTRAINT uq_dim_products_product_id UNIQUE (product_id);


-- =====================================================
-- 4. DIM DATE
-- Grain: one row per date
-- =====================================================

CREATE TABLE warehouse.dim_date AS
WITH all_dates AS (
    SELECT order_purchase_timestamp::DATE AS date_value
    FROM staging.orders
    WHERE order_purchase_timestamp IS NOT NULL

    UNION ALL

    SELECT order_approved_at::DATE AS date_value
    FROM staging.orders
    WHERE order_approved_at IS NOT NULL

    UNION ALL

    SELECT order_delivered_customer_date::DATE AS date_value
    FROM staging.orders
    WHERE order_delivered_customer_date IS NOT NULL

    UNION ALL

    SELECT order_estimated_delivery_date::DATE AS date_value
    FROM staging.orders
    WHERE order_estimated_delivery_date IS NOT NULL
),
date_bounds AS (
    SELECT
        MIN(date_value) AS min_date,
        MAX(date_value) AS max_date
    FROM all_dates
)
SELECT
    TO_CHAR(date_series::DATE, 'YYYYMMDD')::INTEGER AS date_key,
    date_series::DATE AS full_date,
    EXTRACT(YEAR FROM date_series)::INTEGER AS year,
    EXTRACT(QUARTER FROM date_series)::INTEGER AS quarter,
    EXTRACT(MONTH FROM date_series)::INTEGER AS month,
    TO_CHAR(date_series, 'Month') AS month_name,
    EXTRACT(DAY FROM date_series)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM date_series)::INTEGER AS day_of_week,
    TO_CHAR(date_series, 'Day') AS day_name,
    CASE
        WHEN EXTRACT(ISODOW FROM date_series) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM date_bounds,
     GENERATE_SERIES(min_date, max_date, INTERVAL '1 day') AS date_series;


ALTER TABLE warehouse.dim_date
ADD CONSTRAINT pk_dim_date PRIMARY KEY (date_key);


-- =====================================================
-- 5. FACT ORDERS
-- Grain: one row per order_id
-- =====================================================

CREATE TABLE warehouse.fact_orders AS
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS total_order_items,
        COUNT(DISTINCT product_id) AS total_unique_products,
        COUNT(DISTINCT seller_id) AS total_unique_sellers,
        SUM(price) AS total_product_value,
        SUM(freight_value) AS total_freight_value
    FROM staging.order_items
    GROUP BY order_id
),
payment_agg AS (
    SELECT
        order_id,
        COUNT(*) AS total_payment_records,
        COUNT(DISTINCT payment_type) AS total_payment_methods,
        SUM(payment_value) AS total_payment_value,
        MAX(payment_installments) AS max_payment_installments
    FROM staging.order_payments
    GROUP BY order_id
),
review_agg AS (
    SELECT
        order_id,
        COUNT(*) AS total_reviews,
        ROUND(AVG(review_score)::NUMERIC, 2) AS avg_review_score,
        MIN(review_score) AS min_review_score,
        MAX(review_score) AS max_review_score
    FROM staging.order_reviews
    GROUP BY order_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY o.order_id) AS order_sk,
    o.order_id,
    dc.customer_sk,

    dpurchase.date_key AS purchase_date_key,
    dapproved.date_key AS approved_date_key,
    ddelivered.date_key AS delivered_customer_date_key,
    destimated.date_key AS estimated_delivery_date_key,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    o.delivery_days,
    o.is_late_delivery,

    COALESCE(ia.total_order_items, 0) AS total_order_items,
    COALESCE(ia.total_unique_products, 0) AS total_unique_products,
    COALESCE(ia.total_unique_sellers, 0) AS total_unique_sellers,
    COALESCE(ia.total_product_value, 0) AS total_product_value,
    COALESCE(ia.total_freight_value, 0) AS total_freight_value,

    COALESCE(pa.total_payment_records, 0) AS total_payment_records,
    COALESCE(pa.total_payment_methods, 0) AS total_payment_methods,
    COALESCE(pa.total_payment_value, 0) AS total_payment_value,
    COALESCE(pa.max_payment_installments, 0) AS max_payment_installments,

    COALESCE(ra.total_reviews, 0) AS total_reviews,
    ra.avg_review_score,
    ra.min_review_score,
    ra.max_review_score

FROM staging.orders o
LEFT JOIN warehouse.dim_customers dc
    ON o.customer_id = dc.customer_id

LEFT JOIN warehouse.dim_date dpurchase
    ON o.order_purchase_timestamp::DATE = dpurchase.full_date

LEFT JOIN warehouse.dim_date dapproved
    ON o.order_approved_at::DATE = dapproved.full_date

LEFT JOIN warehouse.dim_date ddelivered
    ON o.order_delivered_customer_date::DATE = ddelivered.full_date

LEFT JOIN warehouse.dim_date destimated
    ON o.order_estimated_delivery_date::DATE = destimated.full_date

LEFT JOIN item_agg ia
    ON o.order_id = ia.order_id

LEFT JOIN payment_agg pa
    ON o.order_id = pa.order_id

LEFT JOIN review_agg ra
    ON o.order_id = ra.order_id;


ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT pk_fact_orders PRIMARY KEY (order_sk);

ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT uq_fact_orders_order_id UNIQUE (order_id);


-- =====================================================
-- 6. FACT ORDER ITEMS
-- Grain: one row per order item
-- =====================================================

CREATE TABLE warehouse.fact_order_items AS
SELECT
    ROW_NUMBER() OVER (ORDER BY oi.order_id, oi.order_item_id) AS order_item_sk,

    oi.order_id,
    oi.order_item_id,

    dc.customer_sk,
    dp.product_sk,
    ds.seller_sk,
    dd.date_key AS purchase_date_key,

    o.order_status,
    o.delivery_days,
    o.is_late_delivery,

    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS item_total_value

FROM staging.order_items oi
LEFT JOIN staging.orders o
    ON oi.order_id = o.order_id

LEFT JOIN warehouse.dim_customers dc
    ON o.customer_id = dc.customer_id

LEFT JOIN warehouse.dim_products dp
    ON oi.product_id = dp.product_id

LEFT JOIN warehouse.dim_sellers ds
    ON oi.seller_id = ds.seller_id

LEFT JOIN warehouse.dim_date dd
    ON o.order_purchase_timestamp::DATE = dd.full_date;


ALTER TABLE warehouse.fact_order_items
ADD CONSTRAINT pk_fact_order_items PRIMARY KEY (order_item_sk);


-- =====================================================
-- CREATE INDEXES
-- =====================================================

CREATE INDEX idx_fact_orders_customer_sk
ON warehouse.fact_orders(customer_sk);

CREATE INDEX idx_fact_orders_purchase_date_key
ON warehouse.fact_orders(purchase_date_key);

CREATE INDEX idx_fact_order_items_customer_sk
ON warehouse.fact_order_items(customer_sk);

CREATE INDEX idx_fact_order_items_product_sk
ON warehouse.fact_order_items(product_sk);

CREATE INDEX idx_fact_order_items_seller_sk
ON warehouse.fact_order_items(seller_sk);

CREATE INDEX idx_fact_order_items_purchase_date_key
ON warehouse.fact_order_items(purchase_date_key);


-- =====================================================
-- CHECK WAREHOUSE TABLES
-- =====================================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'warehouse'
ORDER BY table_name;