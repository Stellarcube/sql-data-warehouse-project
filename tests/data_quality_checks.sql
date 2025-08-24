/*  
==============================================================================
DATA QUALITY CHECKS 
==============================================================================
Script Purpose:
This script executes comprehensive data quality checks to ensure 
consistency, accuracy, and standardization. The validations are first 
applied to raw data in the bronze schema, and subsequently re-applied 
after transformation to verify the integrity of the curated data in the
silver schema.

It includes checks for:
    * Null or duplicate primary keys.
    * Unwanted space in the string fields.
    * Data standardization and consistency.
    * Invalid date ranges and orders.
    * Data consistency betweeen related fields.

Usage Notes:
  - Run these checks after loading the silver layer.
  - Investigate and resolve any discrepancies found during the checks.
*/ 

-- DATA QUALITY CHECKS: MASTER SCRIPT

-- CRM TABLES:
-- CRM_CUST_INFO:
-- Ensuring Data Quality_1:Checking for Nulls or Duplicates in Primary Keys
-- Expectations: No Result

select * from bronze.crm_cust_info;

select cst_id, count(*) 
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

-- Ensuring Data Quality_2: Checking for unwanted spaces
-- Expectation: No results

select cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname);

select cst_lastname
from bronze.crm_cust_info
where cst_lastname != trim(cst_lastname);

-- Ensuring Data Quality_3:Data standardization & Consistency
-- Checking the consistency of values in low cardinality columns
-- Expectation: No results

select distinct(cst_marital_status)
from bronze.crm_cust_info;

select distinct(cst_gndr)
from bronze.crm_cust_info;
 
-- CRM_PRD_INFO:
-- Ensuring Data Quality_1:Checking for Nulls or Duplicates in Primary Keys
-- Expectations: No Result

select prd_id, count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;

-- Result: Primary key duplicates do not exist.

select prd_id, count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;

-- Ensuring Data Quality_2: Checking for unwanted spaces
-- Expectation: No results

select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm) 

select prd_line
from bronze.crm_prd_info
where prd_line != trim(prd_line)

-- Result: No unwanted spaces exist

select prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm) 

select prd_line
from silver.crm_prd_info
where prd_line != trim(prd_line);

-- Ensuring Data Quality_3:Data standardization & Consistency
-- Checking the consistency of values in low cardinality columns
-- Expectation: No results

select distinct(prd_line)
from bronze.crm_prd_info;

-- Checks after completing the data insert
select distinct(prd_line)
from silver.crm_prd_info;

-- Ensuring Data Quality_4: Checking for quality issues in datetime(invalid date orders)
-- Expectations: No Result

select *
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt; 

select *
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;

-- Ensuring Data Quality_5:Checking for Nulls or Negative numbers in cost
-- Expectations: No Result

select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null;

select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null;


-- CRM_SALES_DETAILS:
-- Data quality check 1 & 2: 
-- Checking integrity of prd_key
-- Checking integrity of cust_id
-- No result

select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_prd_key not in 
(select prd_key from silver.crm_prd_info);

select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_cust_id not in 
(select cst_id from silver.crm_cust_info);

-- Data Quality Check 3: Checking for unwanted spaces

select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
from silver.crm_sales_details
where sls_ord_num != trim(sls_ord_num);


-- DQC 4: Checking for invalid dates

select *
from bronze.crm_sales_details
where sls_order_dt <= 0 
or len(sls_order_dt) != 8
or sls_order_dt > 20500101
or sls_order_dt < 19000101;

select *
from bronze.crm_sales_details
where sls_ship_dt <= 0 
or len(sls_ship_dt) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101;

select *
from bronze.crm_sales_details
where sls_due_dt <= 0 
or len(sls_due_dt) != 8
or sls_due_dt > 20500101
or sls_due_dt < 19000101;

select * 
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt
or sls_order_dt > sls_due_dt; -- Order date must be less than ship date and due date


-- DQC 5: S/Q/P
-- Checking for arithmetic accuracy (Sales = Quantity * Price);
-- Checking for negative/NULL/zero;

select distinct
	sls_sales,
	sls_quantity,
	sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
	or sls_sales is null
	or sls_quantity is null
	or sls_price is null
	or sls_price <= 0
	or sls_quantity <= 0
	or sls_sales <= 0
order by 
	sls_sales,
	sls_quantity,
	sls_price
;

-- Solution:
-- If  S is negative, zero or null, derive it using Q and P.
-- If P is 0 or null, calculate using S and Q. (P = S/Q)
-- If P is negative, convert it to positive.

-- Result Check:
select 
	sls_sales as old_sls_sales,
	case
		when sls_sales <= 0 or sls_sales is null
			or sls_sales != sls_quantity * sls_price
		then sls_price * sls_quantity
		else sls_sales
	end as sls_sales,
	sls_quantity,
	sls_price as old_sls_price,
	case
		when sls_price < 0 
		then abs(sls_price)
		when sls_price <= 0 or sls_price is null
		then sls_sales/sls_quantity
		else sls_price
	end as sls_price
from bronze.crm_sales_details
order by
old_sls_sales,
old_sls_price
;

-- ERP TABLES:

-- ERP_CUST_AZ12:
-- DQC_1: Checking commonality of cid and cst_key.
-- Expectation: No result

	select 
	case
		when cid like 'NAS%' then substring(cid, 4, len(cid))
		else cid
	end as cid,
	bdate,
	gen
	from bronze.erp_cust_az12
	where 
		case
		when cid like 'NAS%' then substring(cid, 4, len(cid))
		else cid
		end not in  
	(select cst_key from silver.crm_cust_info)
	;

	select cst_key from silver.crm_cust_info;

-- DQC_2: Checking validity of DOBs.
-- Expectation: No result

	select distinct bdate
	from bronze.erp_cust_az12
	where bdate < '1920-01-01' or bdate > getdate();

	select distinct bdate
	from silver.erp_cust_az12
	where bdate < '1920-01-01' or bdate > getdate();

-- DQC_3: Checking low cardinality column (gender).
-- Expectation: No result

	select distinct gen from bronze.erp_cust_az12;

	select distinct gen from silver.erp_cust_az12;
 
	-- Result check:

	select distinct 
	case 
		when upper(trim(gen)) in ('M', 'MALE') then 'Male'
		when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
		else 'N/A'
	end as gen
	from bronze.erp_cust_az12;


	select distinct 
	case 
		when upper(trim(gen)) in ('M', 'MALE') then 'Male'
		when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
		else 'N/A'
	end as gen
	from silver.erp_cust_az12;


-- ERP_LOC_A101:
-- DQC_1: Checking primary and foreign keys 

	select 
	replace(cid,'-', '') as cid,
	cntry
	from bronze.erp_loc_a101;

	select cst_key from silver.crm_cust_info;

	-- Testing correctness 
	select 
	replace(cid,'-', '') as cid,
	cntry
	from bronze.erp_loc_a101
	where replace(cid,'-', '')
	not in
	(select cst_key from silver.crm_cust_info);


-- DQC_2: Checking country

	select distinct
	cntry as old_cntry,
	case 
		when upper(trim(cntry)) in ('USA', 'US', 'UNITED STATES')
		then 'United States of America'
		when upper(trim(cntry)) = 'DE'
		then 'Germany'
		when trim(cntry) = '' or cntry is null
		then 'N/A'
		else trim(cntry)
	end as cntry
	from bronze.erp_loc_a101
	order by cntry;

-- Final Testing:

select distinct cntry from silver.erp_loc_a101;

-- ERP_PX_CAT_G1V2
-- DQC_1:Checking for P/F key matching:

select 
id, 
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2;

select * from silver.crm_prd_info;


-- DQC_2:Check for unwanted spaces

select *
from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
or subcat != trim(subcat)
or maintenance != trim(maintenance);

-- DQC_3:Check for data standardization & Consistency

select distinct cat
from bronze.erp_px_cat_g1v2;

select distinct subcat
from bronze.erp_px_cat_g1v2;

select distinct maintenance
from bronze.erp_px_cat_g1v2;

-- Final testing:
select * from silver.erp_px_cat_g1v2


