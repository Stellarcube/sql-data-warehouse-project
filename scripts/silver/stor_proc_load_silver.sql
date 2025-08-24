/*  
**********************************************************************************************
Stored Procedure: Load Silver Layer (Source -> Silver Layer)
**********************************************************************************************
Script Purpose: 
  This stored procedure performs ETL(Extract, Transform and Load) processes and loads the resulting
  data into the 'silver' schema.
  It performs the following actions:
        - Truncates the silver tables before loading data.
        - Uses transformation logic to fix data issues within the bronze tables and loads the
		  transformed data into the silver tables.

Parameters: None (Stored procedure doesn't accept any parametes or return any value)

Usage Example: 
  EXEC silver.load_silver;
**********************************************************************************************
*/

DROP PROCEDURE IF EXISTS silver.load_silver;
GO

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN 
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

		PRINT '===============================================';
		PRINT 'Loading the silver layer';
		PRINT '===============================================';
	
		PRINT '-----------------------------------------------';
		PRINT 'Loading the CRM tables';
		PRINT '-----------------------------------------------';
	    
		SET @batch_start_time = GETDATE();
		SET @start_time = GETDATE(); 

        PRINT '>> TRUNCATING TABLE: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> INSERTING DATA INTO: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
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
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> INSERTING DATA INTO: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
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
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'R' THEN 'Road'
                WHEN 'M' THEN 'Mountain'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        
        SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> INSERTING DATA INTO: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
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
            sls_cust_id,
            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE
                WHEN sls_sales <= 0 OR sls_sales IS NULL
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN ABS(sls_price) * NULLIF(sls_quantity,0)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE
                WHEN sls_price <= 0 OR sls_price IS NULL
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        
        PRINT '===============================================';

        PRINT '-----------------------------------------------';
        PRINT 'Loading the ERP tables';
		PRINT '-----------------------------------------------';

		SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> INSERTING DATA INTO: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT 
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'N/A'
            END AS gen
        FROM bronze.erp_cust_az12;
        
        SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------------';


		SET @start_time = GETDATE();

        PRINT '>> TRUNCATING TABLE: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> INSERTING DATA INTO: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 
            REPLACE(cid,'-', '') AS cid,
            CASE 
                WHEN UPPER(TRIM(cntry)) IN ('USA', 'US', 'UNITED STATES')
                    THEN 'United States of America'
                WHEN UPPER(TRIM(cntry)) = 'DE'
                    THEN 'Germany'
                WHEN TRIM(cntry) = '' OR cntry IS NULL
                    THEN 'N/A'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;
        
        SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> INSERTING DATA INTO: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
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

            SET @end_time = GETDATE();
		    PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '-----------------------------------------------';
		    SET @batch_end_time = GETDATE();

		    PRINT '================================================';
	        PRINT 'Loading Silver Layer is Completed';
		    PRINT '>> Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		    PRINT '================================================';

	    END TRY
	    BEGIN CATCH
		    PRINT '============================================'
		    PRINT 'ERROR OCCURED WHILE LOADING THE BRONZE LAYER'
		    PRINT 'Error Message' +	 ERROR_MESSAGE();
		    PRINT 'Error Message:' + CAST(ERROR_NUMBER() AS NVARCHAR)
		    PRINT 'Error Message:' + CAST(ERROR_STATE() AS NVARCHAR)
		    PRINT '============================================'
	    END CATCH
    END
