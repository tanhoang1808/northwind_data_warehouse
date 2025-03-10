{{
  config(
    materialized = 'incremental',
    on_schema_change = 'fail',
    tags = 'fi',
    unique_key = 'inventory_transactions_id'
    )
}}

with source as (
    select
    it.inventory_transactions_id,
    itp.type_name,
    s.company as supplier_company,
    s.last_name as supplier_last_name,
    s.first_name as supplier_first_name,
    it.transaction_created_date,
    it.transaction_modified_date,
    p.product_id,
    p.product_name,
    it.quantity as inventory_quantity,
    it.purchase_order_id as inventory_purchase_order_id,
    po.purchase_order_id as purchase_order_id,
    it.customer_order_id,
    CASE
        WHEN it.comments is NULL then 'No Comment'
        ELSE it.comments
    END as comments
    FROM {{ref('northwind_stg__inventory_transactions')}} it
    LEFT JOIN {{ref('northwind_stg__products')}} p
    ON p.product_id = it.product_id
    LEFT JOIN {{ref('northwind_stg__inventory_transaction_types')}} itp
    ON it.transaction_type = itp.inventory_transaction_types_id
    LEFT JOIN {{ref('northwind_stg__purchase_order_details')}} pod
    ON pod.inventory_id = it.inventory_transactions_id
    LEFT JOIN {{ref('northwind_stg__purchase_orders')}} po
    ON po.purchase_order_id = pod.purchase_order_id
    LEFT JOIN {{ref('northwind_stg__suppliers')}} s
    ON  po.supplier_id = s.supplier_id
),

unique_source AS( 
  select *,
  row_number() over( partition by supplier_company,inventory_transactions_id,type_name,product_id,product_name order by transaction_created_date) as row_number
  from source
)

select 
* exclude row_number
from unique_source
where 
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    transaction_created_date >= '{{ var("start_date") }}'
    AND transaction_created_date < '{{ var("end_date") }}'
    AND row_number = 1
  {% else %}
    transaction_created_date > DATEADD(day, -1, (SELECT MAX(transaction_created_date) FROM {{ this }}))
    AND row_number = 1
  {% endif %}
{% else %}
  1=1
{% endif %}

  {%if target.name == 'dev'%}

    {{limit_ten_row()}}

  {%endif%}