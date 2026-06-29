import os
import logging
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine


load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = PROJECT_ROOT / "sql"
LOG_DIR = PROJECT_ROOT / "logs"

LOG_DIR.mkdir(exist_ok=True)

log_file = LOG_DIR / f"pipeline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter("%(levelname)s - %(message)s")
console.setFormatter(formatter)
logging.getLogger("").addHandler(console)


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


SQL_PIPELINE_FILES = [
    "03_create_staging_tables.sql",
    "05_create_warehouse_tables.sql",
    "07_create_mart_tables.sql",
]


def run_sql_file(file_name: str) -> None:
    sql_file_path = SQL_DIR / file_name

    if not sql_file_path.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_file_path}")

    logging.info(f"Running SQL file: {file_name}")

    sql_content = sql_file_path.read_text(encoding="utf-8")

    raw_connection = engine.raw_connection()

    try:
        cursor = raw_connection.cursor()
        cursor.execute(sql_content)
        raw_connection.commit()
        cursor.close()

        logging.info(f"Successfully executed: {file_name}")

    except Exception as error:
        raw_connection.rollback()
        logging.error(f"Failed to execute: {file_name}")
        logging.error(str(error))
        raise

    finally:
        raw_connection.close()


def run_pipeline() -> None:
    logging.info("Starting SQL transformation pipeline")

    for sql_file in SQL_PIPELINE_FILES:
        run_sql_file(sql_file)

    logging.info("SQL transformation pipeline completed successfully")


if __name__ == "__main__":
    try:
        run_pipeline()
        print("Pipeline completed successfully.")
        print(f"Log file saved to: {log_file}")

    except Exception as error:
        print("Pipeline failed.")
        print(error)
        print(f"Check log file: {log_file}")