/******************************************************************************
Purpose:
    This stored procedure loads and transforms data from the Bronze layer
    into the Silver layer of the DataWarehouse.

    The procedure:
        - Truncates existing Silver layer tables.
        - Cleans and standardizes CRM customer information.
        - Cleans and standardizes CRM product information.
        - Cleans and validates CRM sales details.
        - Cleans and standardizes ERP customer information.
        - Cleans and standardizes ERP location information.
        - Loads ERP product category information.
        - Records execution time for each table and the overall process.
        - Handles errors independently for each table load.

Parameters:
    None.

Usage:
    EXEC silver.load_silver;

Notes:
    - The procedure assumes that the Bronze layer has already been loaded.
    - Existing data in Silver tables is truncated before each load.
    - Source data is transformed and standardized during the load process.
    - Update the procedure if the structure of the Bronze or Silver tables changes.
******************************************************************************/


CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @StartTimeTotal DATETIME;
    DECLARE @EndTimeTotal DATETIME;
    DECLARE @StartTime DATETIME;
    DECLARE @EndTime DATETIME;

    SET @StartTimeTotal = GETDATE();

    /****************************************************************************
                                  CRM DATA
    ****************************************************************************/

    PRINT '===============================================================================';
    PRINT '                 LOADING SILVER LAYER';
    PRINT '===============================================================================';


    PRINT '';
    PRINT '-----------------------------------------------------------------------------';
    PRINT '                              CRM DATA';
    PRINT '-----------------------------------------------------------------------------';
    PRINT '';

    ----------------------------------------------------------------------------
    -- CRM CUSTOMER INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.crm_cust_info...';

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>>Loading silver.crm_cust_info...';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),

            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,

            cst_create_date

        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS D
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE D = 1;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'CRM customer information loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- CRM PRODUCT INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.crm_prd_info...';

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>>Loading silver.crm_prd_info...';

        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            COALESCE(prd_cost, 0),

            CASE
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,

            prd_start_dt,

            DATEADD
            (
                DAY,
                -1,
                LEAD(prd_start_dt) OVER
                (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            )

        FROM bronze.crm_prd_info;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'CRM product information loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- CRM SALES DETAILS
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.crm_sales_details...';

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>>Loading silver.crm_sales_details...';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_price,
            sls_quantity
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,

            CASE
                WHEN sls_sales < 0
                  OR sls_sales IS NULL
                  OR sls_sales != ABS(sls_price) * sls_quantity
                THEN ABS(sls_price) * sls_quantity
                ELSE sls_sales
            END,

            CASE
                WHEN sls_price < 0
                  OR sls_price IS NULL
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END,

            sls_quantity

        FROM bronze.crm_sales_details;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'CRM sales details loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) +' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' +CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) +' seconds';

    END CATCH;


    /****************************************************************************
                                  ERP DATA
    ****************************************************************************/

    PRINT '';
    PRINT '-----------------------------------------------------------------------------';
    PRINT '                              ERP DATA';
    PRINT '-----------------------------------------------------------------------------';
    PRINT '';

    ----------------------------------------------------------------------------
    -- ERP CUSTOMER INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.erp_cust_az12...';

        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>>Loading silver.erp_cust_az12...';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT

            CASE
                WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,

            CASE
                WHEN bdate > GETDATE()
                THEN NULL
                ELSE bdate
            END,

            CASE
                WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
                WHEN gen = '' OR gen IS NULL THEN 'n/a'
                ELSE gen
            END

        FROM bronze.erp_cust_az12;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'ERP customer information loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- ERP LOCATION INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.erp_loc_a101...';

        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>>Loading silver.erp_loc_a101...';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', ''),

            CASE
                WHEN TRIM(UPPER(cntry)) IN ('US', 'UNITED STATES', 'USA')
                THEN 'USA'
                WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'
                WHEN cntry = '' OR cntry IS NULL
                THEN 'n/a'
                ELSE TRIM(cntry)
            END

        FROM bronze.erp_loc_a101;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'ERP location information loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' +
              CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- ERP PRODUCT CATEGORY INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating silver.erp_px_cat_g1v2...';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>>Loading silver.erp_px_cat_g1v2...';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance

        FROM bronze.erp_px_cat_g1v2;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'ERP product category information loaded successfully.';
        PRINT 'TIME TAKEN: ' +
              CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- COMPLETE
    ----------------------------------------------------------------------------

    SET @EndTimeTotal = GETDATE();

    PRINT '';
    PRINT '===============================================================================';
    PRINT '                     SILVER LAYER LOAD COMPLETED';
    PRINT '===============================================================================';
    PRINT 'TOTAL TIME TAKEN: ' +CAST(DATEDIFF(SECOND, @StartTimeTotal, @EndTimeTotal) AS VARCHAR) + ' seconds';

END;

EXEC silver.load_silver;
```
