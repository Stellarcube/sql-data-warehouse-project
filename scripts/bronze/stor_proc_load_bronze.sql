/*  
**********************************************************************************************
Stored Procedure: Load Bronze Layer (Source -> Bronze Layer)
**********************************************************************************************
Script Purpose: 
  This stored procedure loads data into the 'bronze' schema from the source files(CSV).
  It performs the following actions:
        - Truncates the bronze tables before loading data.
        - Uses 'BULK INSERT' command to load data all at once from CSV files to bronze tables.

Parameters: None (Stored procedure doesn't accept any parametes or return any value)

Usage Example: 
  EXEC bronze.load_bronze;
**********************************************************************************************
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze -- Stored procedure for loading data
AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

		PRINT '===============================================';
		PRINT 'Loading the bronze layer';
		PRINT '===============================================';
	
		PRINT '---------------------------------------------';
		PRINT 'Loading the CRM tables';
		PRINT '---------------------------------------------';
	    
		SET @batch_start_time = GETDATE();
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';

		-- select count(*) from bronze.crm_cust_info;

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';


		-- SELECT count(*) FROM bronze.crm_prd_info;
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';

		-- SELECT count(*) FROM bronze.crm_sales_details;

		PRINT '---------------------------------------------';
		PRINT 'Loading the ERP tables';
		PRINT '---------------------------------------------';

	    SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------';
		
		
		-- SELECT * FROM bronze.erp_loc_a101;

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Sudhir Kumar\Documents\Sudhir import\Project related\Data with Baraa\SQL Data Warehousing\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '================================================';
	    PRINT 'Loading Bronze Layer is Completed';
		PRINT '>> Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================';

		-- SELECT * FROM bronze.erp_px_cat_g1v2;
	
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
