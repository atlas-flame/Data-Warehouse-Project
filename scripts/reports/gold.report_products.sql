/*
===============================================================================
Product Performance Analysis
===============================================================================

Script Purpose:
    This script analyzes product-level sales performance by combining sales
    transactions with product information and calculating key performance
    metrics.

Key Metrics:
    - Total orders and customers
    - Total sales and quantity sold
    - Product lifespan and recency
    - Average selling price
    - Average order revenue
    - Average monthly revenue
    - Product performance segment

Data Sources:
    - gold.fact_sales
    - gold.dim_products

Notes:
    - Products are segmented based on total sales.
    - Products with a zero-month lifespan use total sales as monthly revenue.
    - Records without an order date are excluded.

===============================================================================
*/

CREATE VIEW gold.report_products AS 
WITH information AS (
    SELECT
        s.order_number,
        s.product_key,
        s.customer_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
),

aggregate_info AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        DATEDIFF(MONTH, MAX(order_date), GETDATE()) AS recency,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS average_selling_price
    FROM information
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    recency,

    -- Classify products based on total revenue
    CASE
        WHEN total_sales > 50000 THEN 'High Performer'
        WHEN total_sales >= 10000 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    average_selling_price,

    -- Average revenue generated per order
    total_sales / NULLIF(total_orders, 0) AS average_order_revenue,

    -- Products with a zero-month lifespan are treated as having a one-month lifespan
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS average_monthly_revenue

FROM aggregate_info;
