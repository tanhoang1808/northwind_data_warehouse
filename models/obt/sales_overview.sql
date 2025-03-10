with source as (
    select
    dc.last_name as customer_last_name,
    dc.first_name as customer_first_name,
    dc.job_title as customer_job_title,
    de.last_name as employee_last_name,
    de.first_name as employee_first_name,
    de.job_title as employee_job_title,
    fs.ORDER_ID,
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
	fs.QUANTITY ,
	fs.UNIT_PRICE ,
	fs.DISCOUNT ,
	fs.STATUS_ID ,
	fs.DATE_ALLOCATED ,
	fs.ORDER_DATE ,
	fs.SHIPPED_DATE ,
	fs.PAID_DATE
    from {{ref('fact_sales',v='1')}} fs
    LEFT JOIN {{ref('dim_employees',v='1')}} de
    ON fs.employee_id = de.employee_id
    LEFT JOIN {{ref('dim_date',v='1')}} dd
    ON dd.time_stamp = fs.order_date
    LEFT JOIN {{ref('dim_customers',v='1')}} dc
    ON dc.customer_id = fs.customer_id
    LEFT JOIN {{ref('dim_products',v='1')}} dp
    ON dp.product_id = fs.product_id
)


select * from source