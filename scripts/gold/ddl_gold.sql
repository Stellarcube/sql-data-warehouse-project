/* 
========================================================================
DDL Script: Create Gold Views:
========================================================================
Script Purpose:
  This script creates for the 'Gold Layer' in the SQL DWH. The gold layer 
  represents the final dimension and fact tables in the Star Schema.

  Each view performs transformations and combines data from the silver layer 
  to produce a clean, enriched and business-ready dataset.

Usage:
  These table can be queried directly for analytics and reporting.
========================================================================
*/

========================================================================
-- Create Fact Table: gold.fact_sales
========================================================================

drop view gold.fact_sales;
go
create view gold.fact_sales as 
  
select
sd.sls_ord_num as order_number,
pr.product_key,
cs.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as amount,
sd.sls_quantity quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_products pr
on		  sd.sls_prd_key = pr.product_number
left join gold.dim_customers cs
on        sd.sls_cust_id = cs.customer_id
;

========================================================================
-- Create Dimension Table: gold.dim_products
========================================================================

drop view gold.dim_products;
go
create view gold.dim_products as

select 
	row_number() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance, 
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- Filtering out all historical data
;

========================================================================
-- Create Dimension Table: gold.dim_customers
========================================================================

drop view gold.dim_customers;
go
create view  gold.dim_customers as

select 
	row_number() over (order by ci.cst_id) as customer_key,
	ci.cst_id		      as customer_id,
	ci.cst_key		      as customer_number,
	ci.cst_firstname	  as first_name,
	ci.cst_lastname		  as last_name,
	ca.bdate              as birthdate,
	ci.cst_marital_status as marital_status,
		case
		when ci.cst_gndr != 'N/A' then ci.cst_gndr -- CRM is the master for gender info.
		else coalesce(ca.gen, 'N/A')
	end					  as gender,
	la.cntry              as country,
	ci.cst_create_date	  as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		  ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on		  ci.cst_key = la.cid
;
