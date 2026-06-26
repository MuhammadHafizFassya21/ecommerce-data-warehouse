import os
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

RAW_DATA_PATH = Path("data/raw")

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


def create_raw_schema():
    with engine.begin() as connection:
        connection.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))


def load_csv_to_postgres():
    for table_name, file_name in tables.items():
        file_path = RAW_DATA_PATH / file_name

        print("=" * 80)
        print(f"Loading file  : {file_name}")
        print(f"Target table  : raw.{table_name}")
        print("=" * 80)

        df = pd.read_csv(file_path)

        df.to_sql(
            name=table_name,
            con=engine,
            schema="raw",
            if_exists="replace",
            index=False,
            chunksize=10000,
            method="multi"
        )

        print(f"Successfully loaded {len(df)} rows into raw.{table_name}")


if __name__ == "__main__":
    create_raw_schema()
    load_csv_to_postgres()
    print("All raw data loaded successfully.")