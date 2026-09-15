/*
===============================================================================
Purpose:
    This stored procedure loads data from the CRM and ERP source CSV files
    into the Bronze layer tables of the DataWarehouse database.

    It truncates existing Bronze data before each load, handles errors
    independently for each table, and records the execution time for
    each table as well as the overall Bronze layer load.

===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
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
    PRINT '                 LOADING BRONZE LAYER';
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

        PRINT '>>Truncating bronze.crm_cust_info...';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>>Loading bronze.crm_cust_info...';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

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

        PRINT '>>Truncating bronze.crm_prd_info...';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>>Loading bronze.crm_prd_info...';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

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

        PRINT '>>Truncating bronze.crm_sales_details...';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>>Loading bronze.crm_sales_details...';

        CREATE TABLE #crm_sales_details_stage
        (
            sls_ord_num NVARCHAR(50),
            sls_prd_key NVARCHAR(50),
            sls_cust_id NVARCHAR(50),
            sls_order_dt NVARCHAR(50),
            sls_ship_dt NVARCHAR(50),
            sls_due_dt NVARCHAR(50),
            sls_sales NVARCHAR(50),
            sls_quantity NVARCHAR(50),
            sls_price NVARCHAR(50)
        );

        BULK INSERT #crm_sales_details_stage
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        INSERT INTO bronze.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            TRY_CONVERT(INT, sls_cust_id),
            TRY_CONVERT(DATE, sls_order_dt, 112),
            TRY_CONVERT(DATE, sls_ship_dt, 112),
            TRY_CONVERT(DATE, sls_due_dt, 112),
            TRY_CONVERT(INT, sls_sales),
            TRY_CONVERT(INT, sls_quantity),
            TRY_CONVERT(INT, sls_price)
        FROM #crm_sales_details_stage;

        DROP TABLE #crm_sales_details_stage;

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'CRM sales details loaded successfully.';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
        PRINT '';

    END TRY
    BEGIN CATCH

        SET @EndTime = GETDATE();

        IF OBJECT_ID('tempdb..#crm_sales_details_stage') IS NOT NULL
            DROP TABLE #crm_sales_details_stage;

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

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

        PRINT '>>Truncating bronze.erp_cust_az12...';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>>Loading bronze.erp_cust_az12...';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

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

        PRINT '>>Truncating bronze.erp_loc_a101...';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>>Loading bronze.erp_loc_a101...';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

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
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';

    END CATCH;


    ----------------------------------------------------------------------------
    -- ERP PRODUCT CATEGORY INFORMATION
    ----------------------------------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        PRINT '>>Truncating bronze.erp_px_cat_g1v2...';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>>Loading bronze.erp_px_cat_g1v2...';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\YOUR_PROJECT_PATH\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @EndTime = GETDATE();

        PRINT '';
        PRINT 'ERP product category information loaded successfully.';
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
    -- COMPLETE
    ----------------------------------------------------------------------------

    SET @EndTimeTotal = GETDATE();

    PRINT '';
    PRINT '===============================================================================';
    PRINT '                     BRONZE LAYER LOAD COMPLETED';
    PRINT '===============================================================================';
    PRINT 'TOTAL TIME TAKEN: ' +
          CAST(DATEDIFF(SECOND, @StartTimeTotal, @EndTimeTotal) AS VARCHAR) +
          ' seconds';

END;

