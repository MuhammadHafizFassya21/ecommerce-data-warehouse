from decimal import Decimal
from datetime import date, datetime
from sqlalchemy import text


def serialize_value(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return value


def serialize_row(row):
    return {key: serialize_value(value) for key, value in dict(row).items()}


def get_filter_options(engine):
    query_years = text("""
        SELECT DISTINCT year
        FROM mart.monthly_sales_summary
        WHERE year IS NOT NULL
        ORDER BY year;
    """)

    query_months = text("""
        SELECT DISTINCT month, TRIM(month_name) AS month_name
        FROM mart.monthly_sales_summary
        WHERE month IS NOT NULL
        ORDER BY month;
    """)

    with engine.connect() as connection:
        years = connection.execute(query_years).mappings().all()
        months = connection.execute(query_months).mappings().all()

        return {
            "years": [row["year"] for row in years],
            "months": [serialize_row(row) for row in months]
        }


def get_kpi_summary(engine, year=None, month=None):
    query = text("""
        SELECT
            COUNT(DISTINCT fo.order_id) AS total_orders,
            ROUND(SUM(fo.total_payment_value)::NUMERIC, 2) AS total_revenue,

            ROUND(
                (
                    SUM(fo.total_payment_value)
                    / NULLIF(COUNT(DISTINCT fo.order_id), 0)
                )::NUMERIC,
                2
            ) AS average_order_value,

            ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,

            ROUND(
                (
                    SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
                    / NULLIF(COUNT(DISTINCT fo.order_id), 0)
                ) * 100,
                2
            ) AS late_delivery_rate_percent,

            ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score

        FROM warehouse.fact_orders fo
        LEFT JOIN warehouse.dim_date dd
            ON fo.purchase_date_key = dd.date_key
        WHERE fo.purchase_date_key IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month);
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().first()
        return serialize_row(result)


def get_monthly_sales(engine, year=None, month=None):
    query = text("""
        SELECT
            year,
            month,
            month_name,
            total_orders,
            total_revenue,
            average_order_value,
            late_delivery_rate_percent,
            average_review_score
        FROM mart.monthly_sales_summary
        WHERE (:year IS NULL OR year = :year)
          AND (:month IS NULL OR month = :month)
        ORDER BY year, month;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]


def get_top_product_categories(engine, year=None, month=None):
    query = text("""
        SELECT
            COALESCE(dp.product_category_name_english, 'unknown') AS product_category,
            COUNT(foi.order_item_sk) AS total_items_sold,
            COUNT(DISTINCT foi.order_id) AS total_orders,
            ROUND(SUM(foi.price)::NUMERIC, 2) AS total_product_sales,
            ROUND(SUM(foi.item_total_value)::NUMERIC, 2) AS total_sales_with_freight,
            ROUND(AVG(foi.price)::NUMERIC, 2) AS average_item_price,
            ROUND(AVG(foi.freight_value)::NUMERIC, 2) AS average_freight_value,

            ROUND(
                (
                    SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
                    / NULLIF(COUNT(foi.order_item_sk), 0)
                ) * 100,
                2
            ) AS late_delivery_rate_percent

        FROM warehouse.fact_order_items foi
        LEFT JOIN warehouse.dim_products dp
            ON foi.product_sk = dp.product_sk
        LEFT JOIN warehouse.dim_date dd
            ON foi.purchase_date_key = dd.date_key
        WHERE foi.purchase_date_key IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month)
        GROUP BY COALESCE(dp.product_category_name_english, 'unknown')
        ORDER BY total_product_sales DESC
        LIMIT 10;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]


def get_customer_state_summary(engine, year=None, month=None):
    query = text("""
        SELECT
            dc.customer_state,
            COUNT(DISTINCT dc.customer_unique_id) AS total_unique_customers,
            COUNT(DISTINCT fo.order_id) AS total_orders,
            ROUND(SUM(fo.total_payment_value)::NUMERIC, 2) AS total_revenue,

            ROUND(
                (
                    SUM(fo.total_payment_value)
                    / NULLIF(COUNT(DISTINCT fo.order_id), 0)
                )::NUMERIC,
                2
            ) AS average_order_value,

            ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,
            ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score,

            ROUND(
                (
                    SUM(CASE WHEN fo.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
                    / NULLIF(COUNT(DISTINCT fo.order_id), 0)
                ) * 100,
                2
            ) AS late_delivery_rate_percent

        FROM warehouse.fact_orders fo
        LEFT JOIN warehouse.dim_customers dc
            ON fo.customer_sk = dc.customer_sk
        LEFT JOIN warehouse.dim_date dd
            ON fo.purchase_date_key = dd.date_key
        WHERE fo.purchase_date_key IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month)
        GROUP BY dc.customer_state
        ORDER BY total_revenue DESC
        LIMIT 10;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]


def get_payment_method_summary(engine, year=None, month=None):
    query = text("""
        SELECT
            op.payment_type,
            COUNT(*) AS total_payment_records,
            COUNT(DISTINCT op.order_id) AS total_orders,
            ROUND(SUM(op.payment_value)::NUMERIC, 2) AS total_payment_value,
            ROUND(AVG(op.payment_value)::NUMERIC, 2) AS average_payment_value

        FROM staging.order_payments op
        LEFT JOIN warehouse.fact_orders fo
            ON op.order_id = fo.order_id
        LEFT JOIN warehouse.dim_date dd
            ON fo.purchase_date_key = dd.date_key
        WHERE fo.purchase_date_key IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month)
        GROUP BY op.payment_type
        ORDER BY total_payment_value DESC;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]


def get_seller_delivery_risk(engine, year=None, month=None):
    query = text("""
        SELECT
            ds.seller_id,
            ds.seller_city,
            ds.seller_state,
            COUNT(foi.order_item_sk) AS total_items_sold,
            COUNT(DISTINCT foi.order_id) AS total_orders,
            ROUND(SUM(foi.price)::NUMERIC, 2) AS total_product_sales,
            ROUND(AVG(foi.delivery_days)::NUMERIC, 2) AS average_delivery_days,

            ROUND(
                (
                    SUM(CASE WHEN foi.is_late_delivery = TRUE THEN 1 ELSE 0 END)::NUMERIC
                    / NULLIF(COUNT(foi.order_item_sk), 0)
                ) * 100,
                2
            ) AS late_delivery_rate_percent

        FROM warehouse.fact_order_items foi
        LEFT JOIN warehouse.dim_sellers ds
            ON foi.seller_sk = ds.seller_sk
        LEFT JOIN warehouse.dim_date dd
            ON foi.purchase_date_key = dd.date_key
        WHERE foi.purchase_date_key IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month)
        GROUP BY ds.seller_id, ds.seller_city, ds.seller_state
        HAVING COUNT(foi.order_item_sk) >= 10
        ORDER BY late_delivery_rate_percent DESC
        LIMIT 10;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]


def get_review_delivery_summary(engine, year=None, month=None):
    query = text("""
        SELECT
            CASE
                WHEN fo.is_late_delivery = TRUE THEN 'Pengiriman Terlambat'
                ELSE 'Tepat Waktu / Tidak Terlambat'
            END AS delivery_status_group,

            COUNT(DISTINCT fo.order_id) AS total_orders,
            ROUND(AVG(fo.delivery_days)::NUMERIC, 2) AS average_delivery_days,
            ROUND(AVG(fo.avg_review_score)::NUMERIC, 2) AS average_review_score,

            ROUND(
                (
                    SUM(CASE WHEN fo.avg_review_score <= 2 THEN 1 ELSE 0 END)::NUMERIC
                    / NULLIF(COUNT(DISTINCT fo.order_id), 0)
                ) * 100,
                2
            ) AS low_review_rate_percent

        FROM warehouse.fact_orders fo
        LEFT JOIN warehouse.dim_date dd
            ON fo.purchase_date_key = dd.date_key
        WHERE fo.purchase_date_key IS NOT NULL
          AND fo.avg_review_score IS NOT NULL
          AND (:year IS NULL OR dd.year = :year)
          AND (:month IS NULL OR dd.month = :month)
        GROUP BY
            CASE
                WHEN fo.is_late_delivery = TRUE THEN 'Pengiriman Terlambat'
                ELSE 'Tepat Waktu / Tidak Terlambat'
            END
        ORDER BY delivery_status_group;
    """)

    with engine.connect() as connection:
        result = connection.execute(query, {"year": year, "month": month}).mappings().all()
        return [serialize_row(row) for row in result]