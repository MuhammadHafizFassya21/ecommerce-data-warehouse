import os
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

RAW_DATA_PATH = Path("data/raw")
DOCS_PATH = Path("docs")
DOCS_PATH.mkdir(exist_ok=True)

tables = {
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

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

DATABASE_URL = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(DATABASE_URL)

validation_results = []

with engine.connect() as connection:
    for table_name, file_name in tables.items():
        file_path = RAW_DATA_PATH / file_name
        df = pd.read_csv(file_path)

        csv_row_count = len(df)

        query = text(f'SELECT COUNT(*) FROM raw."{table_name}";')
        database_row_count = connection.execute(query).scalar()

        status = "PASS" if csv_row_count == database_row_count else "FAILED"

        validation_results.append({
            "table_name": f"raw.{table_name}",
            "file_name": file_name,
            "csv_row_count": csv_row_count,
            "database_row_count": database_row_count,
            "status": status
        })

validation_df = pd.DataFrame(validation_results)

print(validation_df)

validation_df.to_csv(
    DOCS_PATH / "raw_ingestion_validation.csv",
    index=False
)

print("Validation result saved to docs/raw_ingestion_validation.csv")