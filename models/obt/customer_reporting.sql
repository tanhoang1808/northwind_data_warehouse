with source as (
    select
    fpo.UNIQUE_KEY,
    dc.last_name as customer_last_name,
    dc.first_name as customer_first_name,
    dc.job_title as customer_job_title,
	fpo.PURCHASE_ORDER_ID ,
	dp.PRODUCT_ID, 
	dp.PRODUCT_NAME,
    dp.description,
    dp.standard_cost,
    dp.list_price,
    dp.reorder_level,
    dp.target_level,
    dp.quantity_per_unit,
    dp.category,
    dp.minimum_reorder_quantity,
	fpo.quantity,
	fpo.UNIT_COST,
	fpo.DATE_RECEIVED,
	fpo.POSTED_TO_INVENTORY ,
	fpo.INVENTORY_ID ,
	fpo.SUPPLIER_ID ,
	fpo.CREATED_BY ,
	fpo.SUBMITTED_DATE ,
	fpo.CREATION_DATE ,
	fpo.STATUS_ID,
	fpo.EXPECTED_DATE,
	fpo.SHIPPING_FEE,
	fpo.TAXES,
	fpo.PAYMENT_DATE ,
	fpo.PAYMENT_AMOUNT ,
	fpo.PAYMENT_METHOD ,
	fpo.APPROVED_BY ,
	fpo.APPROVED_DATE ,
	fpo.SUBMITTED_BY,
	ROW_NUMBER() over( partition by 
	fpo.unique_key,
	dc.last_name,
	dc.first_name,
	fpo.purchase_order_id,
	dp.product_id,
	fpo.date_received,
	fpo.supplier_id,
	fpo.created_by,
	fpo.creation_date,
	fpo.approved_date
	order by creation_date) as row_number
	
    from {{ref('fact_purchase_order',v='1')}} fpo
    JOIN {{ref('dim_customers',v='1')}} dc
    ON fpo.customer_id = dc.customer_id
    JOIN {{ref('dim_products',v='1')}} dp
    ON fpo.product_id = dp.product_id
    
)

select 
* exclude row_number
from source
where row_number = 1 
ORDER BY creation_date