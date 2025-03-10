{{
  config(
    materialized = 'incremental',
    on_schema_change = 'fail',
    tags = 'fs',
    unique_key = 'sales_unique_key'
  )
}}

with source as (
    select
    {{dbt_utils.generate_surrogate_key(['o.order_id','p.product_id','o.customer_id','o.employee_id','od.quantity'])}} as sales_unique_key,
    o.order_id,
    p.product_id,
    p.product_name,
    o.customer_id,
    o.employee_id,
    od.quantity,
    od.unit_price,
    od.discount,
    od.status_id,
    TO_TIMESTAMP_NTZ(od.date_allocated) as date_allocated ,
    o.order_date,
    o.shipped_date,
    o.paid_date
    FROM {{ref('northwind_stg__orders')}} o
    JOIN {{ref('northwind_stg__order_details')}} od
    ON o.order_id = od.order_id
    JOIN {{ref('northwind_stg__products')}} p
    ON p.product_id = od.product_id
    
),
unique_source as (
  select *,
  row_number() over(partition by customer_id,employee_id,product_id,product_name order by customer_id) as row_number
  from source
)

select 
* exclude row_number
from unique_source
where 
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    paid_date >= '{{ var("start_date") }}'
    AND paid_date < '{{ var("end_date") }}'
    AND row_number = 1
  {% else %}
    paid_date > DATEADD(day,-1,(SELECT MAX(paid_date) FROM {{ this }}))
    AND row_number = 1
  {% endif %}
{% else %}
  1=1
{% endif %}



