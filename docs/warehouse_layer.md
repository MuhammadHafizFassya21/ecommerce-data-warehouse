# Warehouse Layer Documentation

## Overview

The warehouse layer stores analytical tables that are designed using a star schema approach. This layer is created from cleaned staging tables and is used as the foundation for business analysis and dashboard development.

## Warehouse Tables

| Table | Type | Description |
|---|---|---|
| warehouse.dim_customers | Dimension | Stores customer information |
| warehouse.dim_sellers | Dimension | Stores seller information |
| warehouse.dim_products | Dimension | Stores product information and product category translation |
| warehouse.dim_date | Dimension | Stores date attributes for time-based analysis |
| warehouse.fact_orders | Fact | Stores order-level transaction metrics |
| warehouse.fact_order_items | Fact | Stores item-level transaction metrics |

## Grain Definition

### warehouse.fact_orders

The grain of `fact_orders` is one row per `order_id`.

This table is used to analyze:

- total orders
- total payment value
- delivery performance
- review score
- customer order behavior

### warehouse.fact_order_items

The grain of `fact_order_items` is one row per order item.

This table is used to analyze:

- product category performance
- seller performance
- item-level sales
- freight value
- late delivery by product or seller

## Dimension Tables

### dim_customers

Contains customer location and identity information.

### dim_sellers

Contains seller location information.

### dim_products

Contains product attributes and English product category names.

### dim_date

Contains date attributes such as year, quarter, month, day, and weekend flag.

## Key Metrics

The warehouse layer supports the following metrics:

1. Total orders
2. Total product sales
3. Total payment value
4. Total freight value
5. Total order items
6. Average review score
7. Delivery days
8. Late delivery flag
9. Late delivery rate
10. Monthly revenue trend

## Notes

The warehouse layer is not the final dashboard layer. It is the analytical data model that will be used to create business data marts in the next stage.