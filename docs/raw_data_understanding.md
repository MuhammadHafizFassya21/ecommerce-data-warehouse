# Raw Data Understanding

## Overview

This document summarizes the initial understanding of the raw e-commerce dataset used in this project.

## Dataset List

The project uses the following raw datasets:

1. customers
2. geolocation
3. order_items
4. order_payments
5. order_reviews
6. orders
7. products
8. sellers
9. category_translation

## Initial Observation

The dataset consists of multiple CSV files that represent different business entities in an e-commerce system, including customers, orders, products, sellers, payments, reviews, and geolocation.

## Notes

At this stage, no data cleaning or transformation is performed. The goal is only to understand the raw data structure and prepare it for raw ingestion into PostgreSQL.

## Raw Data Ingestion

All raw CSV files have been loaded into PostgreSQL under the `raw` schema.

## Raw Tables

| Source File | Target Table |
|---|---|
| olist_customers_dataset.csv | raw.customers |
| olist_geolocation_dataset.csv | raw.geolocation |
| olist_order_items_dataset.csv | raw.order_items |
| olist_order_payments_dataset.csv | raw.order_payments |
| olist_order_reviews_dataset.csv | raw.order_reviews |
| olist_orders_dataset.csv | raw.orders |
| olist_products_dataset.csv | raw.products |
| olist_sellers_dataset.csv | raw.sellers |
| product_category_name_translation.csv | raw.category_translation |

## Validation

Raw ingestion validation was performed by comparing the number of rows in each CSV file with the number of rows in each PostgreSQL raw table.

The validation result is stored in:

`docs/raw_ingestion_validation.csv`

## Important Notes

At this stage, the data is loaded as-is from the original CSV files. No cleaning, transformation, or business logic has been applied yet.