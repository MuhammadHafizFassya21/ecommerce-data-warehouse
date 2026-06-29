from flask import Flask, jsonify, render_template, request
from sqlalchemy import text

from db import engine
from queries import (
    get_filter_options,
    get_kpi_summary,
    get_monthly_sales,
    get_top_product_categories,
    get_customer_state_summary,
    get_payment_method_summary,
    get_seller_delivery_risk,
    get_review_delivery_summary,
)

app = Flask(__name__)


def get_filter_params():
    year = request.args.get("year", default=None, type=int)
    month = request.args.get("month", default=None, type=int)
    return year, month


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/filter-options")
def api_filter_options():
    data = get_filter_options(engine)
    return jsonify(data)


@app.route("/api/kpi")
def api_kpi():
    year, month = get_filter_params()
    data = get_kpi_summary(engine, year, month)
    return jsonify(data)


@app.route("/api/monthly-sales")
def api_monthly_sales():
    year, month = get_filter_params()
    data = get_monthly_sales(engine, year, month)
    return jsonify(data)


@app.route("/api/product-categories")
def api_product_categories():
    year, month = get_filter_params()
    data = get_top_product_categories(engine, year, month)
    return jsonify(data)


@app.route("/api/customer-states")
def api_customer_states():
    year, month = get_filter_params()
    data = get_customer_state_summary(engine, year, month)
    return jsonify(data)


@app.route("/api/payment-methods")
def api_payment_methods():
    year, month = get_filter_params()
    data = get_payment_method_summary(engine, year, month)
    return jsonify(data)


@app.route("/api/seller-delivery-risk")
def api_seller_delivery_risk():
    year, month = get_filter_params()
    data = get_seller_delivery_risk(engine, year, month)
    return jsonify(data)


@app.route("/api/review-delivery")
def api_review_delivery():
    year, month = get_filter_params()
    data = get_review_delivery_summary(engine, year, month)
    return jsonify(data)

@app.route("/api/health")
def api_health():
    try:
        with engine.connect() as connection:
            database_name = connection.execute(text("SELECT current_database();")).scalar()

        return jsonify({
            "status": "healthy",
            "database": database_name,
            "message": "Dashboard API is connected to PostgreSQL successfully."
        })

    except Exception as error:
        return jsonify({
            "status": "unhealthy",
            "message": str(error)
        }), 500

if __name__ == "__main__":
    app.run(debug=True)