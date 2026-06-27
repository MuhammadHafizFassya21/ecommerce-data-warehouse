-- =====================================================
-- VALIDATE WAREHOUSE TABLES
-- =====================================================

-- 1. Check warehouse table row counts
SELECT 'warehouse.dim_customers' AS table_name, COUNT(*) AS total_rows FROM warehouse.dim_customers
UNION ALL
SELECT 'warehouse.dim_sellers' AS table_name, COUNT(*) AS total_rows FROM warehouse.dim_sellers
UNION ALL
SELECT 'warehouse.dim_products' AS table_name, COUNT(*) AS total_rows FROM warehouse.dim_products
UNION ALL
SELECT 'warehouse.dim_date' AS table_name, COUNT(*) AS total_rows FROM warehouse.dim_date
UNION ALL
SELECT 'warehouse.fact_orders' AS table_name, COUNT(*) AS total_rows FROM warehouse.fact_orders
UNION ALL
SELECT 'warehouse.fact_order_items' AS table_name, COUNT(*) AS total_rows FROM warehouse.fact_order_items;


-- 2. Compare staging and warehouse row counts
SELECT
    'orders' AS entity_name,
    (SELECT COUNT(*) FROM staging.orders) AS staging_count,
    (SELECT COUNT(*) FROM warehouse.fact_orders) AS warehouse_count

UNION ALL

SELECT
    'order_items' AS entity_name,
    (SELECT COUNT(*) FROM staging.order_items) AS staging_count,
    (SELECT COUNT(*) FROM warehouse.fact_order_items) AS warehouse_count

UNION ALL

SELECT
    'customers' AS entity_name,
    (SELECT COUNT(*) FROM staging.customers) AS staging_count,
    (SELECT COUNT(*) FROM warehouse.dim_customers) AS warehouse_count

UNION ALL

SELECT
    'sellers' AS entity_name,
    (SELECT COUNT(*) FROM staging.sellers) AS staging_count,
    (SELECT COUNT(*) FROM warehouse.dim_sellers) AS warehouse_count

UNION ALL

SELECT
    'products' AS entity_name,
    (SELECT COUNT(*) FROM staging.products) AS staging_count,
    (SELECT COUNT(*) FROM warehouse.dim_products) AS warehouse_count;


-- 3. Check duplicate order_id in fact_orders
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM warehouse.fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 4. Check duplicate order item grain
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM warehouse.fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- 5. Check missing dimension keys in fact_orders
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN customer_sk IS NULL THEN 1 ELSE 0 END) AS missing_customer_sk,
    SUM(CASE WHEN purchase_date_key IS NULL THEN 1 ELSE 0 END) AS missing_purchase_date_key
FROM warehouse.fact_orders;


-- 6. Check missing dimension keys in fact_order_items
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN customer_sk IS NULL THEN 1 ELSE 0 END) AS missing_customer_sk,
    SUM(CASE WHEN product_sk IS NULL THEN 1 ELSE 0 END) AS missing_product_sk,
    SUM(CASE WHEN seller_sk IS NULL THEN 1 ELSE 0 END) AS missing_seller_sk,
    SUM(CASE WHEN purchase_date_key IS NULL THEN 1 ELSE 0 END) AS missing_purchase_date_key
FROM warehouse.fact_order_items;


-- 7. Basic monthly order and revenue trend
SELECT
    dd.year,
    dd.month,
    TRIM(dd.month_name) AS month_name,
    COUNT(fo.order_id) AS total_orders,
    SUM(fo.total_payment_value) AS total_revenue
FROM warehouse.fact_orders fo
LEFT JOIN warehouse.dim_date dd
    ON fo.purchase_date_key = dd.date_key
GROUP BY dd.year, dd.month, TRIM(dd.month_name)
ORDER BY dd.year, dd.month;


-- 8. Top product categories by sales value
SELECT
    dp.product_category_name_english,
    COUNT(foi.order_item_sk) AS total_items_sold,
    SUM(foi.price) AS total_product_sales,
    SUM(foi.freight_value) AS total_freight_value,
    SUM(foi.item_total_value) AS total_sales_with_freight
FROM warehouse.fact_order_items foi
LEFT JOIN warehouse.dim_products dp
    ON foi.product_sk = dp.product_sk
GROUP BY dp.product_category_name_english
ORDER BY total_product_sales DESC
LIMIT 10;


-- 9. Seller late delivery performance
SELECT
    ds.seller_id,
    ds.seller_city,
    ds.seller_state,
    COUNT(foi.order_item_sk) AS total_items,
    SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END) AS late_items,
    ROUND(
        SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(foi.order_item_sk) * 100,
        2
    ) AS late_delivery_rate_percent
FROM warehouse.fact_order_items foi
LEFT JOIN warehouse.dim_sellers ds
    ON foi.seller_sk = ds.seller_sk
GROUP BY ds.seller_id, ds.seller_city, ds.seller_state
HAVING COUNT(foi.order_item_sk) >= 10
ORDER BY late_delivery_rate_percent DESC
LIMIT 10;


-- 10. Review score and late delivery relationship
SELECT
    is_late_delivery,
    COUNT(*) AS total_orders,
    ROUND(AVG(avg_review_score)::NUMERIC, 2) AS average_review_score
FROM warehouse.fact_orders
WHERE avg_review_score IS NOT NULL
GROUP BY is_late_delivery
ORDER BY is_late_delivery;