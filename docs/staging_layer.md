# Staging Layer Documentation

## Overview

The staging layer is used to store cleaned and standardized data from the raw layer. The purpose of this layer is to prepare the data before it is modeled into warehouse fact and dimension tables.

## Source and Target Tables

| Raw Table | Staging Table |
|---|---|
| raw.customers | staging.customers |
| raw.sellers | staging.sellers |
| raw.orders | staging.orders |
| raw.order_items | staging.order_items |
| raw.order_payments | staging.order_payments |
| raw.order_reviews | staging.order_reviews |
| raw.products | staging.products |
| raw.geolocation | staging.geolocation |

## Cleaning Rules

The following cleaning rules are applied in the staging layer:

1. Remove unnecessary duplicate records using `DISTINCT` where appropriate.
2. Convert date columns into `TIMESTAMP`.
3. Convert numeric columns into `INTEGER` or `NUMERIC`.
4. Standardize city names using `INITCAP(TRIM(column_name))`.
5. Standardize state codes using `UPPER(TRIM(column_name))`.
6. Rename misspelled product columns:
   - `product_name_lenght` to `product_name_length`
   - `product_description_lenght` to `product_description_length`
7. Add English product category by joining products with category translation.
8. Create delivery performance fields:
   - `delivery_days`
   - `is_late_delivery`

## Important Notes

The staging layer does not yet represent the final data warehouse model. It is an intermediate cleaned layer that will be used to create fact and dimension tables in the warehouse layer.