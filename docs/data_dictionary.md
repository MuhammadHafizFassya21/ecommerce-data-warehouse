# Data Dictionary

## 1. Customers Dataset

Source file: `olist_customers_dataset.csv`

| Column | Description |
|---|---|
| customer_id | Unique ID for customer in each order |
| customer_unique_id | Unique customer identifier |
| customer_zip_code_prefix | Customer zip code prefix |
| customer_city | Customer city |
| customer_state | Customer state |

## 2. Orders Dataset

Source file: `olist_orders_dataset.csv`

| Column | Description |
|---|---|
| order_id | Unique order ID |
| customer_id | Customer ID linked to the order |
| order_status | Status of the order |
| order_purchase_timestamp | Time when order was created |
| order_approved_at | Time when order was approved |
| order_delivered_carrier_date | Time when order was delivered to carrier |
| order_delivered_customer_date | Time when order was delivered to customer |
| order_estimated_delivery_date | Estimated delivery date |

## 3. Order Items Dataset

Source file: `olist_order_items_dataset.csv`

| Column | Description |
|---|---|
| order_id | Order ID |
| order_item_id | Item sequence number in each order |
| product_id | Product ID |
| seller_id | Seller ID |
| shipping_limit_date | Shipping deadline |
| price | Product price |
| freight_value | Shipping cost |

## 4. Order Payments Dataset

Source file: `olist_order_payments_dataset.csv`

| Column | Description |
|---|---|
| order_id | Order ID |
| payment_sequential | Payment sequence |
| payment_type | Payment method |
| payment_installments | Number of installments |
| payment_value | Payment amount |

## 5. Order Reviews Dataset

Source file: `olist_order_reviews_dataset.csv`

| Column | Description |
|---|---|
| review_id | Review ID |
| order_id | Order ID |
| review_score | Customer review score |
| review_comment_title | Review title |
| review_comment_message | Review message |
| review_creation_date | Review creation date |
| review_answer_timestamp | Review answer timestamp |

## 6. Products Dataset

Source file: `olist_products_dataset.csv`

| Column | Description |
|---|---|
| product_id | Product ID |
| product_category_name | Product category name |
| product_name_lenght | Product name length |
| product_description_lenght | Product description length |
| product_photos_qty | Number of product photos |
| product_weight_g | Product weight in grams |
| product_length_cm | Product length in cm |
| product_height_cm | Product height in cm |
| product_width_cm | Product width in cm |

## 7. Sellers Dataset

Source file: `olist_sellers_dataset.csv`

| Column | Description |
|---|---|
| seller_id | Seller ID |
| seller_zip_code_prefix | Seller zip code prefix |
| seller_city | Seller city |
| seller_state | Seller state |