# Project Scope

## Project Title

End-to-End E-Commerce Data Warehouse & Delivery Performance Monitoring

## Main Objective

To build a data warehouse that integrates e-commerce order, payment, delivery, product, seller, customer, and review data for business analysis.

## Business Problems

1. Transaction data is stored separately from customer, seller, payment, delivery, and review data.
2. Business teams need a centralized view to monitor sales, delivery performance, seller performance, and customer satisfaction.
3. Raw data is not ready for analysis and needs to be cleaned, transformed, and modeled.

## Initial Scope

The first version of this project will focus on:

1. Loading raw CSV data into Python.
2. Understanding the structure of each dataset.
3. Cleaning missing values and duplicate records.
4. Loading cleaned data into PostgreSQL.
5. Creating basic SQL queries to answer business questions.

## Out of Scope for Initial Version

The following components will be added in later versions:

1. Apache Airflow
2. dbt
3. Docker
4. Dashboard
5. Cloud deployment
6. CI/CD