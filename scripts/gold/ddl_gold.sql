/*
===============================================================================
Script: Create Gold Layer Views
===============================================================================
Purpose:
    Creates the dimensional and fact views for the Gold layer of the
    DataWarehouse.

Views Created:
    1. gold.dim_customers - Customer dimension
    2. gold.dim_products  - Product dimension
    3. gold.fact_sales    - Sales fact table

Notes:
    - Views are built from cleaned Silver layer tables.
    - Existing views are dropped before recreation.
    - Customer and product keys are generated using ROW_NUMBER().
    - Only currently active products (prd_end_dt IS NULL) are included.
===============================================================================
*/


-- ============================================================
-- Create Customer Dimension
-- ============================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;

GO

CREATE VIEW gold.dim_customers AS
SELECT
      ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
      ci.cst_id AS customer_id,
      ci.cst_key AS customer_number,
      ci.cst_firstname AS first_name,
      ci.cst_lastname AS last_name,
      cl.cntry AS country,
      ci.cst_marital_status AS marital_status,
      ca.bdate AS birthdate,
      CASE
          WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
          ELSE COALESCE(ca.gen, 'n/a')
      END AS gender,
      ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
    ON ci.cst_key = cl.cid;

GO


-- ============================================================
-- Create Product Dimension
-- ============================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;

GO

CREATE VIEW gold.dim_products AS
SELECT
      ROW_NUMBER() OVER (
          ORDER BY p.prd_start_dt, p.prd_key
      ) AS product_key,
      p.prd_id AS product_id,
      p.cat_id,
      p.prd_key AS product_number,
      p.prd_nm AS product_name,
      pc.cat AS product_category,
      pc.subcat AS product_subcategory,
      pc.maintenance AS maintenance_required,
      p.prd_cost AS cost,
      p.prd_line AS product_line,
      p.prd_start_dt AS start_date

FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON p.cat_id = pc.id

WHERE p.prd_end_dt IS NULL;

GO


-- ============================================================
-- Create Sales Fact
-- ============================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;

GO

CREATE VIEW gold.fact_sales AS
SELECT
      sd.sls_ord_num AS order_number,
      p.product_key,
      c.customer_key,
      sd.sls_order_dt AS order_date,
      sd.sls_ship_dt AS shipping_date,
      sd.sls_due_dt AS due_date,
      sd.sls_sales AS sales,
      sd.sls_quantity AS quantity,
      sd.sls_price AS price

FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products p
    ON sd.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c
    ON sd.sls_cust_id = c.customer_id;

GO

