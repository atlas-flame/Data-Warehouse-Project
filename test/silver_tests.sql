/*
===============================================================================
Script: Bronze Layer Quality Checks - CRM Customer Information
===============================================================================
Script Purpose:
    Performs data quality checks on the bronze.crm_cust_info table, including:
    - Row count and sample data
    - Column completeness
    - Duplicate customer IDs and keys
    - Missing values in expected ID sequences
    - Invalid values in customer names
    - Invalid marital status and gender values
    - Date range checks
    - Unexpected records
===============================================================================
*/


-- ============================================================================
-- Basic Information
-- ============================================================================
SELECT TOP 100 *
FROM bronze.crm_cust_info
ORDER BY cst_key DESC;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(cst_id) AS total_cst_id,
    COUNT(cst_key) AS total_cst_key,
    COUNT(cst_firstname) AS total_firstname,
    COUNT(cst_lastname) AS total_lastname,
    COUNT(cst_marital_status) AS total_marital_status,
    COUNT(cst_gndr) AS total_gender,
    COUNT(cst_create_date) AS total_create_date
FROM bronze.crm_cust_info;


-- ============================================================================
-- Completeness Check
-- Shows the percentage of non-null values in each column
-- ============================================================================
SELECT 
    FORMAT(COUNT(cst_id) * 1.0 / COUNT(*), 'P')             AS cst_id,
    FORMAT(COUNT(cst_key) * 1.0 / COUNT(*), 'P')            AS cst_key,
    FORMAT(COUNT(cst_firstname) * 1.0 / COUNT(*), 'P')      AS cst_firstname,
    FORMAT(COUNT(cst_lastname) * 1.0 / COUNT(*), 'P')       AS cst_lastname,
    FORMAT(COUNT(cst_marital_status) * 1.0 / COUNT(*), 'P') AS cst_marital_status,
    FORMAT(COUNT(cst_gndr) * 1.0 / COUNT(*), 'P')           AS cst_gndr,
    FORMAT(COUNT(cst_create_date) * 1.0 / COUNT(*), 'P')    AS cst_create_date
FROM bronze.crm_cust_info;


-- ============================================================================
-- Uniqueness / Duplication Checks
-- Checks for duplicate customer IDs and customer keys
-- ============================================================================
SELECT
    cst_id,
    cst_key,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id, cst_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- ID Sequence Checks
-- Identifies missing customer IDs and customer keys in the expected sequence
-- ============================================================================

SELECT
    MIN(cst_id) OVER() + ROW_NUMBER() OVER(ORDER BY cst_id) - 1 AS cst_id_expected
INTO #cte_cst_id_seq
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL;


SELECT
    CONCAT('AW000', cst_id_expected) AS cst_key_expected
INTO #cte_cst_key_sequence
FROM #cte_cst_id_seq;


-- Check for missing customer IDs
SELECT
    cseq.cst_id_expected AS cst_id_missing
FROM #cte_cst_id_seq AS cseq
LEFT JOIN bronze.crm_cust_info AS c
    ON c.cst_id = cseq.cst_id_expected
WHERE c.cst_id IS NULL
ORDER BY cseq.cst_id_expected DESC;


-- Check for missing customer keys
SELECT
    cseq.cst_key_expected AS cst_key_missing
FROM #cte_cst_key_sequence AS cseq
LEFT JOIN bronze.crm_cust_info AS c
    ON c.cst_key = cseq.cst_key_expected
WHERE c.cst_key IS NULL
ORDER BY cseq.cst_key_expected DESC;


-- ============================================================================
-- Customer Name Validation
-- Checks for numbers and unwanted leading/trailing spaces
-- ============================================================================
SELECT
    cst_id,
    cst_firstname,
    cst_lastname,
    CASE
        WHEN cst_firstname LIKE '%[0-9]%' THEN 'Invalid firstname'
        WHEN cst_lastname LIKE '%[0-9]%' THEN 'Invalid lastname'
        WHEN cst_firstname != TRIM(cst_firstname) THEN 'Firstname has spaces'
        WHEN cst_lastname != TRIM(cst_lastname) THEN 'Lastname has spaces'
    END AS validation_issue
FROM bronze.crm_cust_info
WHERE cst_firstname LIKE '%[0-9]%'
   OR cst_lastname LIKE '%[0-9]%'
   OR cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);


-- ============================================================================
-- Categorical Value Validation
-- Checks marital status and gender for unexpected values
-- ============================================================================
SELECT
    cst_id,
    cst_marital_status,
    cst_gndr,
    CASE
        WHEN cst_marital_status NOT IN ('S', 'M')
            THEN 'Invalid marital status'
        WHEN cst_gndr NOT IN ('M', 'F')
            THEN 'Invalid gender'
    END AS validation_issue
FROM bronze.crm_cust_info
WHERE cst_marital_status NOT IN ('S', 'M')
   OR cst_gndr NOT IN ('M', 'F');


-- ============================================================================
-- Date Validation
-- Checks the earliest and latest customer creation dates
-- ============================================================================
SELECT
    MIN(cst_create_date) AS earliest_create_date,
    MAX(cst_create_date) AS latest_create_date
FROM bronze.crm_cust_info;


-- ============================================================================
-- Unexpected / Incomplete Records
-- Identifies records without a customer ID
-- ============================================================================
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;


-- ============================================================================
-- Key Integrity Check
-- Displays the customer ID and corresponding customer key
-- ============================================================================
SELECT
    cst_id,
    cst_key
FROM bronze.crm_cust_info;


-- ============================================================================
-- Cleanup
-- ============================================================================
DROP TABLE IF EXISTS #cte_cst_id_seq;
DROP TABLE IF EXISTS #cte_cst_key_sequence;
