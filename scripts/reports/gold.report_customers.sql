/*
===============================================================================
Customer Performance Report
===============================================================================

Script Purpose:
    Creates a view containing customer-level sales and behavioral metrics for
    reporting and analysis.

Key Metrics:
    - Customer age and age range
    - Total orders and products purchased
    - Total sales and quantity sold
    - Customer recency and lifespan
    - Average sales per order
    - Average monthly sales
    - Customer segment

Data Sources:
    - gold.fact_sales
    - gold.dim_customers

Output:
    - gold.report_customers

Notes:
    - Customers are segmented based on lifespan and total sales.
    - Customers with a zero-month lifespan use total sales as monthly sales.
    - Records without an order date are excluded.

===============================================================================
*/

CREATE OR ALTER VIEW gold.report_customers AS

WITH information AS (
    SELECT
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        c.first_name + ' ' + c.last_name AS customer_name,
        c.birthdate,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key
    WHERE s.order_date IS NOT NULL
),

aggregate_info AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM information
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Classify customers based on their age
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 60 THEN '18-60'
        WHEN age > 60 THEN '60+'
    END AS age_range,

    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Calculate average sales generated per order
    total_sales / NULLIF(total_orders, 0) AS average_sales,

    -- Treat customers with a zero-month lifespan as having a one-month lifespan
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS average_monthly_sales,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- Classify customers based on lifespan and total sales
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales < 5000 THEN 'REG'
        ELSE 'NEW'
    END AS customer_segment

FROM aggregate_info;
