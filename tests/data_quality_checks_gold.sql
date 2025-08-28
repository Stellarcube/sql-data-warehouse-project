/*
==============================================================================
Quality Checks
==============================================================================

Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after loading the Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/

==============================================================================
-- DQC_Customers
==============================================================================
-- DQC_1: Checking for duplicates of customer_key using groupby
-- Expectation: No result

select t.cst_id, count(*)
from  
(select 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		  ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on		  ci.cst_key = la.cid
) t
group by cst_id
having count(*) > 1;

-- DQC_2: Integrating two gender columns
select distinct
	ci.cst_gndr,
	ca.gen,
	case
		when ci.cst_gndr != 'N/A' then ci.cst_gndr -- CRM is the master for gender info.
		else coalesce(ca.gen, 'N/A')
	end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		  ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on		  ci.cst_key = la.cid
order by 1,2;

==============================================================================
-- DQC_Products
==============================================================================  
-- DCQ_1: Checking the uniqueness of prd_key
select prd_key, count(*) from (
select 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance 
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- Filtering out all historical data
) t
group by prd_key 
having count(*) > 1;

==============================================================================
-- DQC_Sales:
==============================================================================
-- DQC_1: Checking Foreign Key Integrity (Dimensions):
select * 
	from gold.fact_sales f
	left join gold.dim_customers c
	on c.customer_key = f.customer_key
	where c.customer_key is null
;
select * 
	from gold.fact_sales f
	left join gold.dim_customers c
	on c.customer_key = f.customer_key
	left join gold.dim_products p
	on p.product_key = f.product_key
where p.product_key is null
;
