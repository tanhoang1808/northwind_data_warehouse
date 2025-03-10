{%- macro grant_select(schema=target.schema, database=target.database, role=target.role) -%}
    
    {% set sql %}
    USE ROLE {{ role }};
    GRANT USAGE ON SCHEMA {{ schema }} TO ROLE ANALYSIS;
    GRANT SELECT ON ALL TABLES IN SCHEMA {{ schema }} TO ROLE ANALYSIS;
    {% endset %}

    {{ log("target.name = " ~ target.name, info=True) }}

    {% if target.name == 'dev' %}
        {% do run_query(sql) %}
    {% else %}
        {{ log("You are running on " ~ target.name ~ ", which is not suitable for granting SELECT. Please contact your manager to solve.", info=True) }}
    {% endif %}

{%- endmacro -%}
