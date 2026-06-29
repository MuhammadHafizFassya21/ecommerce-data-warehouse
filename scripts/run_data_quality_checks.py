import os
from datetime import datetime
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = PROJECT_ROOT / "quality_reports"

REPORT_DIR.mkdir(exist_ok=True)

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


QUALITY_CHECKS = [
    {
        "check_name": "fact_orders_row_count",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM warehouse.fact_orders;
        """,
        "expected_rule": "result_value > 0"
    },
    {
        "check_name": "fact_order_items_row_count",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM warehouse.fact_order_items;
        """,
        "expected_rule": "result_value > 0"
    },
    {
        "check_name": "duplicate_order_id_in_fact_orders",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM (
                SELECT order_id
                FROM warehouse.fact_orders
                GROUP BY order_id
                HAVING COUNT(*) > 1
            ) duplicate_orders;
        """,
        "expected_rule": "result_value = 0"
    },
    {
        "check_name": "negative_product_price",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM warehouse.fact_order_items
            WHERE price < 0;
        """,
        "expected_rule": "result_value = 0"
    },
    {
        "check_name": "invalid_review_score",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM staging.order_reviews
            WHERE review_score < 1
               OR review_score > 5;
        """,
        "expected_rule": "result_value = 0"
    },
    {
        "check_name": "monthly_sales_summary_row_count",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM mart.monthly_sales_summary;
        """,
        "expected_rule": "result_value > 0"
    },
    {
        "check_name": "missing_total_revenue_in_monthly_summary",
        "query": """
            SELECT COUNT(*) AS result_value
            FROM mart.monthly_sales_summary
            WHERE total_revenue IS NULL;
        """,
        "expected_rule": "result_value = 0"
    }
]


def evaluate_rule(value, rule):
    if rule == "result_value > 0":
        return value > 0

    if rule == "result_value = 0":
        return value == 0

    return False


def run_quality_checks():
    results = []

    with engine.connect() as connection:
        for check in QUALITY_CHECKS:
            query = text(check["query"])
            result_value = connection.execute(query).scalar()
            passed = evaluate_rule(result_value, check["expected_rule"])

            results.append({
                "check_name": check["check_name"],
                "result_value": result_value,
                "expected_rule": check["expected_rule"],
                "status": "PASS" if passed else "FAILED",
                "checked_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            })

    return pd.DataFrame(results)


if __name__ == "__main__":
    quality_df = run_quality_checks()

    report_file = REPORT_DIR / f"data_quality_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

    quality_df.to_csv(report_file, index=False)

    print(quality_df)
    print(f"Quality report saved to: {report_file}")

    if "FAILED" in quality_df["status"].values:
        print("Some quality checks failed.")
    else:
        print("All quality checks passed.")