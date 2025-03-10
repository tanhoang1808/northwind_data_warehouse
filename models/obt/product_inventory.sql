

with source as(
    SELECT
    fi.INVENTORY_TRANSACTIONS_ID,    
    dp.PRODUCT_ID,
    dp.PRODUCT_NAME,
    dp.STANDARD_COST,
    dp.LIST_PRICE,
    dp.REORDER_LEVEL,
    dp.TARGET_LEVEL,
    dp.QUANTITY_PER_UNIT,
    dp.DISCONTINUED,
    dp.MINIMUM_REORDER_QUANTITY,
    dp.CATEGORY,
    fi.SUPPLIER_COMPANY,
    fi.SUPPLIER_FIRST_NAME,
    fi.SUPPLIER_LAST_NAME,
    fi.inventory_quantity,
    fi.TRANSACTION_CREATED_DATE,
    fi.TRANSACTION_MODIFIED_DATE,
    fi.TYPE_NAME,
    fi.COMMENTS
    from {{ref("fact_inventory",v='1')}} fi
    LEFT JOIN {{ref('dim_products',v='1')}} dp
    ON dp.product_id = fi.product_id
    
)

SELECT * from source