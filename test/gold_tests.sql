/*
===============================================================================
Script: Gold Layer Quality Checks
Purpose:
    Performs data quality and integrity checks on the Gold layer, including:
    - Orphaned records between fact and dimension tables
    - Duplicate products in the source data
    - Duplicate product keys in the Gold dimension
    - Gender mapping validation
    - Duplicate customer keys in the Gold dimension
    - Duplicate customers caused by source joins
===============================================================================
*/


-- ============================================================================
-- Check for orphaned records in the fact table
-- ============================================================================
SELECT 
    *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE c.customer_id IS NULL
   OR p.product_key IS NULL;


-- ============================================================================
-- Check for duplicate active products in the Silver layer
-- ============================================================================
SELECT 
    prd_key,
    COUNT(*) AS total_products
FROM (
    SELECT 
        pn.prd_id,
        pn.prd_cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
    FROM silver.crm_prd_info AS pn
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
        ON pn.prd_cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL
) AS t
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Check Gold product dimension
-- ============================================================================
SELECT *
FROM gold.dim_products;


-- Check for duplicate product keys
SELECT 
    product_key,
    COUNT(*) AS total_observations
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Validate customer gender mapping between CRM and ERP
-- ============================================================================
SELECT DISTINCT 
    ci.cst_gndr,
    cbd.gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(cbd.gen, 'n/a')
    END AS new_gndr
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS cbd
    ON ci.cst_key = cbd.cid
ORDER BY 1, 2;


-- ============================================================================
-- Check Gold customer dimension
-- ============================================================================
SELECT *
FROM gold.dim_customers;


-- Check for duplicate customer keys
SELECT 
    customer_key,
    COUNT(*) AS total_observations
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- Check for duplicate customers caused by Silver-layer joins
-- ============================================================================
SELECT 
    cst_id,
    COUNT(*) AS total_customer
FROM (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        cbd.bdate,
        cbd.gen,
        cloc.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS cbd
        ON ci.cst_key = cbd.cid
    LEFT JOIN silver.erp_loc_a101 AS cloc
        ON ci.cst_key = cloc.cid
) AS t
GROUP BY cst_id
HAVING COUNT(cst_id) > 1;
