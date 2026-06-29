# ecommerce-data-warehouse

Struktur proyek:

- data/raw
- data/processed
- notebooks
- scripts
- sql
- docs

# E-Commerce Data Warehouse & Delivery Performance Monitoring

## 1. Project Overview

This project is an end-to-end data engineering project that builds an e-commerce data warehouse using Python, SQL, and PostgreSQL. The project focuses on integrating order, customer, seller, product, payment, delivery, and review data into structured analytical tables.

## 2. Problem Statement

E-commerce companies often store transaction, customer, seller, product, payment, delivery, and review data in separate systems. This makes it difficult for business teams to monitor order performance, delivery delays, seller performance, and customer satisfaction in a centralized way.

This project aims to build a data pipeline and data warehouse to transform raw e-commerce data into analytical data that can support business decision-making.

## 3. Business Questions

This project aims to answer the following questions:

1. How many orders are created each month?
2. What is the monthly revenue trend?
3. Which product categories generate the highest sales?
4. Which cities have the highest number of orders?
5. Which sellers have the highest late delivery rate?
6. What is the average delivery time?
7. Does late delivery affect customer review score?
8. What payment methods are most commonly used?
9. Which products often receive low ratings?
10. What percentage of orders are delivered late?

## 4. Tech Stack

- Python
- SQL
- PostgreSQL
- Pandas
- SQLAlchemy
- DBeaver / pgAdmin

## 5. Project Structure

```text
ecommerce-data-warehouse/
├── data/
│   ├── raw/
│   └── processed/
├── notebooks/
├── scripts/
├── sql/
├── docs/
├── README.md
└── requirements.txt

## Current Progress

### Stage 1: Project Initialization

- Created project folder structure
- Set up Python virtual environment
- Set up PostgreSQL database
- Created initial documentation

### Stage 2: Raw Data Understanding and Ingestion

- Checked raw dataset availability
- Generated raw dataset profile
- Loaded raw CSV files into PostgreSQL `raw` schema
- Validated row counts between CSV files and PostgreSQL tables

## Current Progress

### Stage 1: Project Initialization

- Created project folder structure
- Set up Python virtual environment
- Set up PostgreSQL database
- Created initial documentation

### Stage 2: Raw Data Understanding and Ingestion

- Checked raw dataset availability
- Generated raw dataset profile
- Loaded raw CSV files into PostgreSQL `raw` schema
- Validated row counts between CSV files and PostgreSQL tables

## Stage 3: Staging Layer and Data Cleaning

In this stage, raw data is transformed into cleaned staging tables. The staging layer standardizes data types, cleans text fields, converts date columns, handles duplicate records, and prepares the data for warehouse modeling.

### Staging Tables

- staging.customers
- staging.sellers
- staging.orders
- staging.order_items
- staging.order_payments
- staging.order_reviews
- staging.products
- staging.geolocation

### Key Transformations

- Converted date fields into timestamp format
- Converted price, freight, and payment fields into numeric format
- Standardized city and state names
- Joined product category translation
- Added delivery performance fields:
  - delivery_days
  - is_late_delivery

  ## Stage 4: Warehouse Layer

In this stage, cleaned staging data is transformed into analytical warehouse tables using a star schema approach.

### Dimension Tables

- warehouse.dim_customers
- warehouse.dim_sellers
- warehouse.dim_products
- warehouse.dim_date

### Fact Tables

- warehouse.fact_orders
- warehouse.fact_order_items

### Key Features

- Created surrogate keys for dimension tables
- Created date dimension for time-based analysis
- Created order-level fact table
- Created item-level fact table
- Added indexes for commonly used analytical joins
- Validated warehouse row counts and duplicate keys

### Supported Analysis

- Monthly order and revenue trend
- Top product categories by sales
- Seller late delivery performance
- Relationship between late delivery and review score

## Stage 5: Data Mart Layer

In this stage, warehouse tables are transformed into business-ready data marts. The mart layer is designed to support dashboard development and business analysis.

### Data Mart Tables

- mart.monthly_sales_summary
- mart.product_category_performance
- mart.seller_delivery_performance
- mart.customer_state_summary
- mart.payment_method_summary
- mart.review_delivery_summary

### Key Business Metrics

- Monthly revenue
- Monthly order trend
- Average order value
- Product category sales
- Seller late delivery rate
- Customer state revenue
- Payment method usage
- Relationship between delivery delay and review score

### Business Questions Answered

1. How many orders are created each month?
2. What is the monthly revenue trend?
3. Which product categories generate the highest sales?
4. Which sellers have the highest late delivery rate?
5. Which customer states generate the highest revenue?
6. What payment methods are most commonly used?
7. Does late delivery affect customer review score?

## Stage 6: Business Insight and Query Analysis

In this stage, analytical SQL queries are created to generate business insights from the data mart layer.

### Analysis Areas

- Business KPI overview
- Monthly sales and revenue trend
- Month-over-month revenue growth
- Product category performance
- Seller delivery performance
- Customer location analysis
- Payment method analysis
- Delivery and review relationship

### Output Files

- `sql/09_business_analysis_queries.sql`
- `docs/business_insights.md`
- `docs/dashboard_requirements.md`

### Key Business Questions

1. What is the overall business performance?
2. How do orders and revenue change over time?
3. Which product categories generate the highest sales?
4. Which sellers have the highest late delivery rate?
5. Which customer locations generate the highest revenue?
6. What payment methods are most commonly used?
7. Does late delivery affect customer review score?


---

# TAHAP 8.6 — Update README GitHub

README adalah bagian paling penting. Recruiter biasanya melihat README dulu.

Tambahkan struktur seperti ini di `README.md`.

```markdown
# E-Commerce Data Warehouse & Analytics Dashboard

## Project Overview

This project is an end-to-end data engineering project that builds an e-commerce data warehouse and a custom web analytics dashboard. The project processes raw e-commerce data into structured analytical layers and presents business insights through a Flask-based dashboard.

## Business Problem

E-commerce companies often store order, customer, seller, product, payment, delivery, and review data in separate systems. This makes it difficult for business teams to monitor sales performance, delivery issues, seller reliability, customer location performance, payment behavior, and customer satisfaction in a centralized way.

## Project Objective

The objective of this project is to build a data pipeline and analytical platform that can:

1. Ingest raw e-commerce data.
2. Store data in PostgreSQL.
3. Clean and standardize data in a staging layer.
4. Build fact and dimension tables in a warehouse layer.
5. Create business-ready data marts.
6. Provide business insights through SQL analysis.
7. Display insights in a custom web analytics dashboard.

## Tech Stack

- Python
- PostgreSQL
- SQL
- SQLAlchemy
- Flask
- HTML
- CSS
- JavaScript
- Chart.js
- DBeaver
- GitHub

## Data Pipeline Architecture

```text
CSV Dataset
    ↓
Python Ingestion
    ↓
PostgreSQL Raw Layer
    ↓
SQL Staging Layer
    ↓
SQL Warehouse Layer
    ↓
SQL Data Mart Layer
    ↓
Flask API
    ↓
Web Analytics Dashboard