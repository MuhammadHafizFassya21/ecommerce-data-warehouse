-- =====================================================
-- BUSINESS ANALYSIS QUERIES
-- =====================================================
-- Purpose:
-- This file contains analytical queries to generate
-- business insights from the e-commerce data mart layer.
-- =====================================================


-- =====================================================
-- 1. BUSINESS KPI OVERVIEW
-- Question:
-- What is the overall business performance?
-- =====================================================

SELECT
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(average_order_value)::NUMERIC, 2) AS average_order_value,
    ROUND(AVG(late_delivery_rate_percent)::NUMERIC, 2) AS average_late_delivery_rate_percent,
    ROUND(AVG(average_delivery_days)::NUMERIC, 2) AS average_delivery_days,
    ROUND(AVG(average_review_score)::NUMERIC, 2) AS average_review_score
FROM mart.monthly_sales_summary;


-- =====================================================
-- 2. MONTHLY SALES TREND
-- Question:
-- How do orders and revenue change over time?
-- =====================================================

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


-- =====================================================
-- 3. MONTH-OVER-MONTH REVENUE GROWTH
-- Question:
-- How much does revenue grow or decline compared to the previous month?
-- =====================================================

WITH monthly_revenue AS (
    SELECT
        year,
        month,
        month_name,
        total_orders,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY year, month) AS previous_month_revenue
    FROM mart.monthly_sales_summary
)
SELECT
    year,
    month,
    month_name,
    total_orders,
    total_revenue,
    previous_month_revenue,
    ROUND(
        (
            (total_revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0)
        ) * 100,
        2
    ) AS revenue_growth_percent
FROM monthly_revenue
ORDER BY year, month;


-- =====================================================
-- 4. TOP 10 PRODUCT CATEGORIES BY SALES
-- Question:
-- Which product categories generate the highest sales?
-- =====================================================

SELECT
    product_category,
    total_items_sold,
    total_orders,
    total_product_sales,
    total_sales_with_freight,
    average_item_price,
    average_freight_value,
    late_delivery_rate_percent
FROM mart.product_category_performance
ORDER BY total_product_sales DESC
LIMIT 10;


-- =====================================================
-- 5. PRODUCT CATEGORIES WITH HIGH LATE DELIVERY RATE
-- Question:
-- Which product categories have delivery issues?
-- =====================================================

SELECT
    product_category,
    total_items_sold,
    total_orders,
    total_product_sales,
    average_delivery_days,
    late_delivery_rate_percent
FROM mart.product_category_performance
WHERE total_items_sold >= 100
ORDER BY late_delivery_rate_percent DESC
LIMIT 10;


-- =====================================================
-- 6. TOP CUSTOMER STATES BY REVENUE
-- Question:
-- Which customer locations generate the highest revenue?
-- =====================================================

SELECT
    customer_state,
    total_unique_customers,
    total_orders,
    total_revenue,
    average_order_value,
    average_delivery_days,
    average_review_score,
    late_delivery_rate_percent
FROM mart.customer_state_summary
ORDER BY total_revenue DESC
LIMIT 10;


-- =====================================================
-- 7. CUSTOMER STATES WITH HIGH LATE DELIVERY RATE
-- Question:
-- Which customer locations experience the most delivery delays?
-- =====================================================

SELECT
    customer_state,
    total_orders,
    total_revenue,
    average_delivery_days,
    average_review_score,
    late_delivery_rate_percent
FROM mart.customer_state_summary
WHERE total_orders >= 100
ORDER BY late_delivery_rate_percent DESC
LIMIT 10;


-- =====================================================
-- 8. TOP SELLERS BY SALES
-- Question:
-- Which sellers generate the highest sales?
-- =====================================================

SELECT
    seller_id,
    seller_city,
    seller_state,
    total_items_sold,
    total_orders,
    total_product_sales,
    total_sales_with_freight,
    average_delivery_days,
    late_delivery_rate_percent
FROM mart.seller_delivery_performance
ORDER BY total_product_sales DESC
LIMIT 10;


-- =====================================================
-- 9. SELLERS WITH HIGH LATE DELIVERY RATE
-- Question:
-- Which sellers need operational attention?
-- =====================================================

SELECT
    seller_id,
    seller_city,
    seller_state,
    total_items_sold,
    total_orders,
    total_product_sales,
    average_delivery_days,
    late_delivery_rate_percent
FROM mart.seller_delivery_performance
WHERE total_items_sold >= 10
ORDER BY late_delivery_rate_percent DESC
LIMIT 10;


-- =====================================================
-- 10. PAYMENT METHOD PERFORMANCE
-- Question:
-- What payment methods are most commonly used?
-- =====================================================

SELECT
    payment_type,
    SUM(total_payment_records) AS total_payment_records,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_payment_value)::NUMERIC, 2) AS total_payment_value,
    ROUND(AVG(average_payment_value)::NUMERIC, 2) AS average_payment_value,
    ROUND(AVG(average_installments)::NUMERIC, 2) AS average_installments,
    MAX(max_installments) AS max_installments
FROM mart.payment_method_summary
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- =====================================================
-- 11. REVIEW AND DELIVERY RELATIONSHIP
-- Question:
-- Does late delivery affect customer review score?
-- =====================================================

SELECT
    delivery_status_group,
    total_orders,
    average_delivery_days,
    average_review_score,
    low_review_rate_percent
FROM mart.review_delivery_summary
ORDER BY delivery_status_group;


-- =====================================================
-- 12. LOW REVIEW RISK ANALYSIS
-- Question:
-- Which delivery group has higher low-review risk?
-- =====================================================

SELECT
    delivery_status_group,
    total_orders,
    average_review_score,
    low_review_rate_percent,
    CASE
        WHEN low_review_rate_percent >= 30 THEN 'High Risk'
        WHEN low_review_rate_percent >= 15 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS review_risk_level
FROM mart.review_delivery_summary
ORDER BY low_review_rate_percent DESC;


-- =====================================================
-- 13. MONTHLY LATE DELIVERY TREND
-- Question:
-- Is late delivery increasing or decreasing over time?
-- =====================================================

SELECT
    year,
    month,
    month_name,
    total_orders,
    total_late_orders,
    late_delivery_rate_percent,
    average_delivery_days,
    average_review_score
FROM mart.monthly_sales_summary
ORDER BY year, month;


-- =====================================================
-- 14. BEST BUSINESS MONTHS
-- Question:
-- Which months have the best business performance?
-- =====================================================

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
ORDER BY total_revenue DESC
LIMIT 5;


-- =====================================================
-- 15. BUSINESS RECOMMENDATION SUPPORT QUERY
-- Question:
-- Which areas should the business prioritize?
-- =====================================================

SELECT
    customer_state,
    total_orders,
    total_revenue,
    average_order_value,
    average_delivery_days,
    average_review_score,
    late_delivery_rate_percent,
    CASE
        WHEN total_revenue >= 1000000 AND late_delivery_rate_percent < 10 THEN 'High Value - Stable'
        WHEN total_revenue >= 1000000 AND late_delivery_rate_percent >= 10 THEN 'High Value - Needs Delivery Improvement'
        WHEN total_revenue < 1000000 AND average_review_score >= 4 THEN 'Growth Potential'
        ELSE 'Monitor'
    END AS business_priority
FROM mart.customer_state_summary
ORDER BY total_revenue DESC;