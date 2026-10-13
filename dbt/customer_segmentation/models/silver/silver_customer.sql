{{ config(materialized='view') }}

SELECT
    customer.customer_id,
    customer.customer_name,
    customer.segment_id_source,
    customer.segment_id,
    segment.segment_name,
    segment.segment_type,
    customer.customer_type,
    customer.district_name,
    customer.date_of_birth,
    customer.age_years,
    customer.age_group,
    customer.occupation,
    customer.risk_score,
    customer.customer_status
FROM {{ ref('bronze_customer') }} AS customer
LEFT JOIN {{ ref('bronze_customer_segment') }} AS segment
    ON customer.segment_id = segment.segment_id
