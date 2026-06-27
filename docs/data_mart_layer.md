# Data Mart Layer Documentation

## Overview

The data mart layer contains business-ready summary tables created from the warehouse layer. These tables are designed to support dashboard development and business analysis.

## Data Mart Tables

| Table | Description |
|---|---|
| mart.monthly_sales_summary | Monthly sales, order, delivery, and review summary |
| mart.product_category_performance | Product category sales and delivery performance |
| mart.seller_delivery_performance | Seller sales and late delivery performance |
| mart.customer_state_summary | Customer location-based order and revenue summary |
| mart.payment_method_summary | Payment method usage and payment value summary |
| mart.review_delivery_summary | Relationship between delivery status and customer review |

## Business Questions Supported

The mart layer is designed to answer the following business questions:

1. How many orders are created each month?
2. What is the monthly revenue trend?
3. Which product categories generate the highest sales?
4. Which sellers have the highest late delivery rate?
5. Which customer states generate the highest revenue?
6. What payment methods are most commonly used?
7. Does late delivery affect customer review score?

## Mart Table Details

### mart.monthly_sales_summary

This table summarizes monthly order and revenue performance.

Key metrics:

- total_orders
- total_order_items
- total_product_value
- total_freight_value
- total_revenue
- average_order_value
- total_late_orders
- late_delivery_rate_percent
- average_delivery_days
- average_review_score

### mart.product_category_performance

This table summarizes product category performance.

Key metrics:

- total_items_sold
- total_orders
- total_unique_products
- total_sellers
- total_product_sales
- total_sales_with_freight
- average_item_price
- late_delivery_rate_percent

### mart.seller_delivery_performance

This table summarizes seller-level sales and delivery performance.

Key metrics:

- total_items_sold
- total_orders
- total_product_sales
- total_sales_with_freight
- average_delivery_days
- late_delivery_rate_percent

### mart.customer_state_summary

This table summarizes sales performance based on customer state.

Key metrics:

- total_unique_customers
- total_orders
- total_revenue
- average_order_value
- average_delivery_days
- average_review_score
- late_delivery_rate_percent

### mart.payment_method_summary

This table summarizes payment method usage and payment value.

Key metrics:

- total_payment_records
- total_orders
- total_payment_value
- average_payment_value
- average_installments
- max_installments

### mart.review_delivery_summary

This table summarizes the relationship between delivery status and customer review.

Key metrics:

- total_orders
- average_delivery_days
- average_review_score
- low_review_rate_percent

## Notes

The data mart layer is optimized for reporting and dashboard needs. It is not intended to replace the warehouse layer, but to simplify access to business-ready metrics.