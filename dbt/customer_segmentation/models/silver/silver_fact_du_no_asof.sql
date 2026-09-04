{{ config(materialized='view') }}

WITH as_of_date AS (
    SELECT MIN(max_date) AS as_of_date
    FROM (
        SELECT MAX(ngay) AS max_date FROM {{ source('banking', 'fact_tien_gui') }}
        UNION ALL
        SELECT MAX(ngay) AS max_date FROM {{ source('banking', 'fact_du_no') }}
    ) x
)

SELECT
    fdn.*,
    ao.as_of_date
FROM {{ source('banking', 'fact_du_no') }} AS fdn
CROSS JOIN as_of_date ao
WHERE fdn.ngay = ao.as_of_date
