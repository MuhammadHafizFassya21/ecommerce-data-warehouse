-- Check all tables in raw schema
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;


-- Check row count for each raw table
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


-- Preview orders data
SELECT *
FROM raw.orders
LIMIT 10;


-- Preview order items data
SELECT *
FROM raw.order_items
LIMIT 10;


-- Preview payments data
SELECT *
FROM raw.order_payments
LIMIT 10;


-- Preview reviews data
SELECT *
FROM raw.order_reviews
LIMIT 10;