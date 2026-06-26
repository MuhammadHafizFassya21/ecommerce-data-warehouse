import pandas as pd
from pathlib import Path

RAW_DATA_PATH = Path("data/raw")
DOCS_PATH = Path("docs")
DOCS_PATH.mkdir(exist_ok=True)

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

dataset_profiles = []
column_profiles = []

for dataset_name, file_name in files.items():
    file_path = RAW_DATA_PATH / file_name
    df = pd.read_csv(file_path)

    dataset_profiles.append({
        "dataset_name": dataset_name,
        "file_name": file_name,
        "total_rows": df.shape[0],
        "total_columns": df.shape[1],
        "duplicate_rows": df.duplicated().sum(),
        "total_missing_values": df.isnull().sum().sum()
    })

    for column in df.columns:
        column_profiles.append({
            "dataset_name": dataset_name,
            "column_name": column,
            "data_type": str(df[column].dtype),
            "missing_values": df[column].isnull().sum(),
            "unique_values": df[column].nunique()
        })

dataset_profile_df = pd.DataFrame(dataset_profiles)
column_profile_df = pd.DataFrame(column_profiles)

dataset_profile_df.to_csv(DOCS_PATH / "raw_dataset_profile.csv", index=False)
column_profile_df.to_csv(DOCS_PATH / "raw_column_profile.csv", index=False)

print("Raw data profile created successfully.")
print("Generated files:")
print("- docs/raw_dataset_profile.csv")
print("- docs/raw_column_profile.csv")