-- =====================================================
-- CREATE DATA MART TABLES
-- =====================================================

CREATE SCHEMA IF NOT EXISTS mart;


-- =====================================================
-- DROP EXISTING MART TABLES
-- =====================================================

DROP TABLE IF EXISTS mart.monthly_sales_summary;
DROP TABLE IF EXISTS mart.product_category_performance;
DROP TABLE IF EXISTS mart.seller_delivery_performance;
DROP TABLE IF EXISTS mart.customer_state_summary;
DROP TABLE IF EXISTS mart.payment_method_summary;
DROP TABLE IF EXISTS mart.review_delivery_summary;


-- =====================================================
-- 1. MONTHLY SALES SUMMARY
-- Purpose: Monthly order, revenue, delivery, and review trend
-- =====================================================

CREATE TABLE mart.monthly_sales_summary AS
SELECT
    dd.year,
    dd.month,
    TRIM(dd.month_name) AS month_name,

    COUNT(DISTINCT fo.order_id) AS total_orders,
    SUM(fo.total_order_items) AS total_order_items,

    ROUND(SUM(fo.total_product_value)::NUMERIC, 2) AS total_product_value,
    ROUND(SUM(fo.total_freight_value)::NUMERIC, 2) AS total_freight_value,
    ROUND(SUM(fo.total_payment_value)::NUMERIC, 2) AS total_revenue,

    ROUND(
        (SUM(fo.total_payment_value) / NULLIF(COUNT(DISTINCT fo.order_id), 0))::NUMERIC,
        2
    ) AS average_order_value,

    SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END) AS total_late_orders,

    ROUND(
        (
            SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
            / NULLIF(COUNT(DISTINCT fo.order_id), 0)
        ) * 100,
        2
    ) AS late_delivery_rate_percent,

    ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,
    ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score

FROM warehouse.fact_orders fo
LEFT JOIN warehouse.dim_date dd
    ON fo.purchase_date_key = dd.date_key
WHERE fo.purchase_date_key IS NOT NULL
GROUP BY
    dd.year,
    dd.month,
    TRIM(dd.month_name)
ORDER BY
    dd.year,
    dd.month;


-- =====================================================
-- 2. PRODUCT CATEGORY PERFORMANCE
-- Purpose: Analyze product category sales performance
-- =====================================================

CREATE TABLE mart.product_category_performance AS
SELECT
    COALESCE(dp.product_category_name_english, 'unknown') AS product_category,

    COUNT(foi.order_item_sk) AS total_items_sold,
    COUNT(DISTINCT foi.order_id) AS total_orders,
    COUNT(DISTINCT foi.product_sk) AS total_unique_products,
    COUNT(DISTINCT foi.seller_sk) AS total_sellers,

    ROUND(SUM(foi.price)::NUMERIC, 2) AS total_product_sales,
    ROUND(SUM(foi.freight_value)::NUMERIC, 2) AS total_freight_value,
    ROUND(SUM(foi.item_total_value)::NUMERIC, 2) AS total_sales_with_freight,

    ROUND(AVG(foi.price)::NUMERIC, 2) AS average_item_price,
    ROUND(AVG(foi.freight_value)::NUMERIC, 2) AS average_freight_value,
    ROUND(AVG(foi.delivery_days)::NUMERIC, 2) AS average_delivery_days,

    SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END) AS total_late_items,

    ROUND(
        (
            SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
            / NULLIF(COUNT(foi.order_item_sk), 0)
        ) * 100,
        2
    ) AS late_delivery_rate_percent

FROM warehouse.fact_order_items foi
LEFT JOIN warehouse.dim_products dp
    ON foi.product_sk = dp.product_sk
GROUP BY
    COALESCE(dp.product_category_name_english, 'unknown')
ORDER BY
    total_product_sales DESC;


-- =====================================================
-- 3. SELLER DELIVERY PERFORMANCE
-- Purpose: Analyze seller sales and delivery performance
-- =====================================================

CREATE TABLE mart.seller_delivery_performance AS
SELECT
    ds.seller_id,
    ds.seller_city,
    ds.seller_state,

    COUNT(foi.order_item_sk) AS total_items_sold,
    COUNT(DISTINCT foi.order_id) AS total_orders,
    COUNT(DISTINCT foi.product_sk) AS total_unique_products,

    ROUND(SUM(foi.price)::NUMERIC, 2) AS total_product_sales,
    ROUND(SUM(foi.freight_value)::NUMERIC, 2) AS total_freight_value,
    ROUND(SUM(foi.item_total_value)::NUMERIC, 2) AS total_sales_with_freight,

    ROUND(AVG(foi.price)::NUMERIC, 2) AS average_item_price,
    ROUND(AVG(foi.freight_value)::NUMERIC, 2) AS average_freight_value,
    ROUND(AVG(foi.delivery_days)::NUMERIC, 2) AS average_delivery_days,

    SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END) AS total_late_items,

    ROUND(
        (
            SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
            / NULLIF(COUNT(foi.order_item_sk), 0)
        ) * 100,
        2
    ) AS late_delivery_rate_percent

FROM warehouse.fact_order_items foi
LEFT JOIN warehouse.dim_sellers ds
    ON foi.seller_sk = ds.seller_sk
GROUP BY
    ds.seller_id,
    ds.seller_city,
    ds.seller_state
ORDER BY
    total_product_sales DESC;


-- =====================================================
-- 4. CUSTOMER STATE SUMMARY
-- Purpose: Analyze order and revenue by customer location
-- =====================================================

CREATE TABLE mart.customer_state_summary AS
SELECT
    dc.customer_state,

    COUNT(DISTINCT dc.customer_unique_id) AS total_unique_customers,
    COUNT(DISTINCT fo.order_id) AS total_orders,

    ROUND(SUM(fo.total_product_value)::NUMERIC, 2) AS total_product_value,
    ROUND(SUM(fo.total_freight_value)::NUMERIC, 2) AS total_freight_value,
    ROUND(SUM(fo.total_payment_value)::NUMERIC, 2) AS total_revenue,

    ROUND(
        (SUM(fo.total_payment_value) / NULLIF(COUNT(DISTINCT fo.order_id), 0))::NUMERIC,
        2
    ) AS average_order_value,

    ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,
    ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score,

    SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END) AS total_late_orders,

    ROUND(
        (
            SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
            / NULLIF(COUNT(DISTINCT fo.order_id), 0)
        ) * 100,
        2
    ) AS late_delivery_rate_percent

FROM warehouse.fact_orders fo
LEFT JOIN warehouse.dim_customers dc
    ON fo.customer_sk = dc.customer_sk
GROUP BY
    dc.customer_state
ORDER BY
    total_revenue DESC;


-- =====================================================
-- 5. PAYMENT METHOD SUMMARY
-- Purpose: Analyze payment method usage and payment value
-- Note: Uses staging.order_payments because payment type is not yet modeled
-- as a separate warehouse fact table in this project version.
-- =====================================================

CREATE TABLE mart.payment_method_summary AS
SELECT
    dd.year,
    dd.month,
    TRIM(dd.month_name) AS month_name,

    op.payment_type,

    COUNT(*) AS total_payment_records,
    COUNT(DISTINCT op.order_id) AS total_orders,

    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS total_payment_value,
    ROUND(AVG(op.payment_value)::NUMERIC, 2) AS average_payment_value,

    ROUND(AVG(op.payment_installments)::NUMERIC, 2) AS average_installments,
    MAX(op.payment_installments) AS max_installments

FROM staging.order_payments op
LEFT JOIN warehouse.fact_orders fo
    ON op.order_id = fo.order_id
LEFT JOIN warehouse.dim_date dd
    ON fo.purchase_date_key = dd.date_key
GROUP BY
    dd.year,
    dd.month,
    TRIM(dd.month_name),
    op.payment_type
ORDER BY
    dd.year,
    dd.month,
    total_payment_value DESC;


-- =====================================================
-- 6. REVIEW DELIVERY SUMMARY
-- Purpose: Analyze relationship between delivery delay and review score
-- =====================================================

CREATE TABLE mart.review_delivery_summary AS
SELECT
    CASE
        WHEN fo.is_late_delivery = TRUE THEN 'Late Delivery'
        ELSE 'On Time / Not Late'
    END AS delivery_status_group,

    COUNT(DISTINCT fo.order_id) AS total_orders,

    ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,
    ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score,

    SUM(CASE WHEN fo.avg_review_score = 1 THEN 1 ELSE 0 END) AS total_score_1,
    SUM(CASE WHEN fo.avg_review_score = 2 THEN 1 ELSE 0 END) AS total_score_2,
    SUM(CASE WHEN fo.avg_review_score = 3 THEN 1 ELSE 0 END) AS total_score_3,
    SUM(CASE WHEN fo.avg_review_score = 4 THEN 1 ELSE 0 END) AS total_score_4,
    SUM(CASE WHEN fo.avg_review_score = 5 THEN 1 ELSE 0 END) AS total_score_5,

    ROUND(
        (
            SUM(CASE WHEN fo.avg_review_score <= 2 THEN 1 ELSE 0 END)::NUMERIC
            / NULLIF(COUNT(DISTINCT fo.order_id), 0)
        ) * 100,
        2
    ) AS low_review_rate_percent

FROM warehouse.fact_orders fo
WHERE fo.avg_review_score IS NOT NULL
GROUP BY
    CASE
        WHEN fo.is_late_delivery = TRUE THEN 'Late Delivery'
        ELSE 'On Time / Not Late'
    END
ORDER BY
    delivery_status_group;


-- =====================================================
-- CREATE INDEXES FOR MART TABLES
-- =====================================================

CREATE INDEX idx_monthly_sales_summary_year_month
ON mart.monthly_sales_summary(year, month);

CREATE INDEX idx_product_category_performance_category
ON mart.product_category_performance(product_category);

CREATE INDEX idx_seller_delivery_performance_seller_id
ON mart.seller_delivery_performance(seller_id);

CREATE INDEX idx_customer_state_summary_state
ON mart.customer_state_summary(customer_state);

CREATE INDEX idx_payment_method_summary_year_month
ON mart.payment_method_summary(year, month);

CREATE INDEX idx_review_delivery_summary_group
ON mart.review_delivery_summary(delivery_status_group);


-- =====================================================
-- CHECK MART TABLES
-- =====================================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'mart'
ORDER BY table_name;