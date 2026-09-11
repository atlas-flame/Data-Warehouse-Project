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
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN


    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @overall_start_time DATETIME2,
            @overall_end_time   DATETIME2;
SET @overall_start_time = GETDATE();

    PRINT '============================================================';
    PRINT '                 LOADING BRONZE LAYER';
    PRINT '============================================================';


    -- ============================================================
    -- CRM CUSTOMER INFO
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'CRM CUSTOMER INFO';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'CRM CUSTOMER INFO LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    -- ============================================================
    -- CRM PRODUCT INFO
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'CRM PRODUCT INFO';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'CRM PRODUCT INFO LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    -- ============================================================
    -- CRM SALES DETAILS
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'CRM SALES DETAILS';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'CRM SALES DETAILS LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    -- ============================================================
    -- ERP PRODUCT CATEGORY
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'ERP PRODUCT CATEGORY';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'ERP PRODUCT CATEGORY LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    -- ============================================================
    -- ERP CUSTOMER
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'ERP CUSTOMER';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'ERP CUSTOMER LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    -- ============================================================
    -- ERP LOCATION
    -- ============================================================
    PRINT '------------------------------------------------------------';
    PRINT 'ERP LOCATION';
    PRINT '------------------------------------------------------------';

    BEGIN TRY

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Aaron\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT 'ERP LOCATION LOADED SUCCESSFULLY';
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END TRY
    BEGIN CATCH

        SET @end_time = GETDATE();

        PRINT 'ERROR OCCURRED';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'ERROR PROCEDURE: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'TIME TAKEN: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';

    END CATCH;


    PRINT '============================================================';
    PRINT '              BRONZE LAYER LOAD COMPLETED';
    PRINT '============================================================';
SET @overall_end_time = GETDATE();
PRINT '============================================================';
PRINT 'TOTAL TIME TAKEN: ' 
    + CAST(DATEDIFF(SECOND, @overall_start_time, @overall_end_time) AS NVARCHAR)
    + ' SECONDS';
PRINT '============================================================';
END;
