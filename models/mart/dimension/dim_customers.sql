{{ config( materialized = 'table' ) }}

WITH source AS
(
	SELECT  c.customer_id
	       ,c.company_name
	       ,c.last_name
	       ,c.first_name
	       ,c.email
	       ,c.job_title
	       ,c.business_phone::varchar AS business_phone
	       ,c.home_phone::varchar     AS home_phone
	       ,c.mobile_phone::varchar   AS mobile_phone
	       ,c.fax_number
	       ,c.address
	       ,c.city
	       ,c.state_province
	       ,c.zip_postal_code
	       ,c.country_region
	       ,c.web_page_information
	       ,c.Notes_information
	       ,c.attachments_information
	FROM {{ ref
	('northwind_stg__customer'
	) }} c
)
SELECT  *
FROM source