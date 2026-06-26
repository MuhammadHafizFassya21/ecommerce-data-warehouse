from pathlib import Path

RAW_DATA_PATH = Path("data/raw")

required_files = [
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
]

print("Checking raw data files...")
print("-" * 50)

missing_files = []

for file_name in required_files:
    file_path = RAW_DATA_PATH / file_name

    if file_path.exists():
        print(f"[OK] {file_name}")
    else:
        print(f"[MISSING] {file_name}")
        missing_files.append(file_name)

print("-" * 50)

if missing_files:
    print("Some files are missing. Please check your data/raw folder.")
else:
    print("All required raw data files are available.")