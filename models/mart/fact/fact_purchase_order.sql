{{
  config(
    materialized = 'incremental',
    on_schema_change = 'fail',
    tags = 'fpo',
    unique_key = 'unique_key'
    )
}}

with source as (
    select
    {{dbt_utils.generate_surrogate_key(['c.customer_id','pod.purchase_order_id','od.order_id','p.product_id'])}} as unique_key,
    c.customer_id,
    e.employee_id,
    pod.purchase_order_id,
    p.product_id ,
    pod.quantity,
    pod.unit_cost::number as unit_cost,
    pod.date_received,
    pod.posted_to_inventory,
    pod.inventory_id,
    po.supplier_id,
    po.created_by,
    date(po.submitted_date) as submitted_date ,
    date(po.creation_date) as creation_date,
    po.status_id,
    date(po.expected_date) as expected_date,
    po.shipping_fee::float as shipping_fee,
    po.taxes::float as taxes,
    TO_TIMESTAMP_NTZ(po.payment_date) as payment_date,
    po.payment_amount::float as payment_amount,
    (po.payment_method::varchar) as payment_method,
    po.approved_by,
    po.approved_date,
    po.submitted_by,
    TO_TIMESTAMP_NTZ(current_timestamp()) as ingestion_timestamp
from {{ref('northwind_stg__purchase_orders')}} po
left join {{ref('northwind_stg__purchase_order_details')}} pod
on pod.purchase_order_id = po.purchase_order_id
left join {{ref('northwind_stg__products')}} p 
on pod.product_id = p.product_id
left join {{ref('northwind_stg__order_details')}} od
on p.product_id = od.product_id
left join {{ref('northwind_stg__orders')}} o 
on od.order_id = o.order_id
left join {{ref('northwind_stg__customer')}} c
on o.customer_id = c.customer_id
left join {{ref('northwind_stg__employees')}} e 
on po.created_by = e.employee_id
left join {{ref('northwind_stg__suppliers')}} s 
on s.supplier_id = po.supplier_id
),
unique_source as (
    select *,
    row_number() over ( 
        partition by
        unique_key,
        customer_id,
        employee_id,
        product_id,
        supplier_id,
        purchase_order_id,
        inventory_id,
        creation_date
        order by
        creation_date

    ) as row_number
    from source
        where
        customer_id is not null
        AND 
        employee_id is not null
        AND 
        product_id is not null
        AND 
        inventory_id is not null
        AND 
        creation_date is not null
    )

select 
* exclude row_number
from unique_source
where 
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    creation_date >= '{{ var("start_date") }}'
    AND creation_date < '{{ var("end_date") }}'
    AND row_number = 1
  {% else %}
    creation_date > DATEADD(day,-1,(SELECT MAX(creation_date) FROM {{ this }}))
    AND row_number = 1
  {% endif %}
{% else %}
  1=1
{% endif %}

{%if target.name == 'dev'%}

    {{limit_ten_row()}}

  {%endif%}
