# Web Analytics Dashboard Documentation

## Overview

The web analytics dashboard is a custom dashboard built using Flask, PostgreSQL, HTML, CSS, JavaScript, and Chart.js. The dashboard uses business-ready tables from the `mart` schema.

## Dashboard Language

The dashboard interface is written in Bahasa Indonesia.

## Main Features

1. KPI summary cards
2. Monthly revenue trend
3. Monthly order trend
4. Top product categories by sales
5. Payment method contribution
6. Customer state revenue
7. Review score by delivery status
8. Seller late delivery risk table
9. Year filter
10. Month filter

## API Endpoints

| Endpoint | Description |
|---|---|
| `/api/filter-options` | Returns available year and month filters |
| `/api/kpi` | Returns KPI summary |
| `/api/monthly-sales` | Returns monthly sales data |
| `/api/product-categories` | Returns top product category data |
| `/api/customer-states` | Returns customer state revenue data |
| `/api/payment-methods` | Returns payment method summary |
| `/api/seller-delivery-risk` | Returns sellers with high late delivery rate |
| `/api/review-delivery` | Returns review score by delivery status |

## Filter Parameters

The API supports optional query parameters:

```text
year
month