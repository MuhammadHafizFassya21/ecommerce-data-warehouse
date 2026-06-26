import pandas as pd
from pathlib import Path

RAW_DATA_PATH = Path("data/raw")

files = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

for dataset_name, file_name in files.items():
    file_path = RAW_DATA_PATH / file_name

    print("\n" + "=" * 80)
    print(f"Dataset: {dataset_name}")
    print(f"File: {file_name}")
    print("=" * 80)

    df = pd.read_csv(file_path)

    print(f"Rows    : {df.shape[0]}")
    print(f"Columns : {df.shape[1]}")

    print("\nColumn Names:")
    for column in df.columns:
        print(f"- {column}")

    print("\nMissing Values:")
    print(df.isnull().sum())

    print("\nDuplicate Rows:")
    print(df.duplicated().sum())

    print("\nSample Data:")
    print(df.head())