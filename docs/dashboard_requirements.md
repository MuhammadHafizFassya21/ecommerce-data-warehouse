# Dashboard Requirements

## Dashboard Title

E-Commerce Business Performance Dashboard

## Objective

The dashboard is designed to help business users monitor sales performance, delivery performance, product category performance, seller performance, customer location, payment behavior, and customer satisfaction.

## Main KPI Cards

1. Total Orders
2. Total Revenue
3. Average Order Value
4. Average Delivery Days
5. Late Delivery Rate
6. Average Review Score

## Charts

### 1. Monthly Revenue Trend

Source table: `mart.monthly_sales_summary`

Metrics:

- total_revenue
- total_orders
- average_order_value

Chart type:

- Line chart or bar chart

### 2. Top Product Categories

Source table: `mart.product_category_performance`

Metrics:

- product_category
- total_product_sales
- total_items_sold

Chart type:

- Horizontal bar chart

### 3. Seller Late Delivery Performance

Source table: `mart.seller_delivery_performance`

Metrics:

- seller_id
- total_items_sold
- late_delivery_rate_percent

Chart type:

- Bar chart

### 4. Customer State Revenue

Source table: `mart.customer_state_summary`

Metrics:

- customer_state
- total_revenue
- total_orders

Chart type:

- Bar chart or map chart

### 5. Payment Method Summary

Source table: `mart.payment_method_summary`

Metrics:

- payment_type
- total_payment_value
- total_payment_records

Chart type:

- Pie chart or bar chart

### 6. Delivery and Review Relationship

Source table: `mart.review_delivery_summary`

Metrics:

- delivery_status_group
- average_review_score
- low_review_rate_percent

Chart type:

- Bar chart

## Filters

Recommended filters:

1. Year
2. Month
3. Product Category
4. Customer State
5. Seller State
6. Payment Type