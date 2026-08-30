{{ config(materialized='view') }}

WITH relationship_start_base AS (
    SELECT tg.CIF, tg.ngay_mo_tai_khoan AS relationship_start_date
    FROM {{ source('banking', 'tk_tien_gui') }} AS tg
    WHERE tg.ngay_mo_tai_khoan IS NOT NULL

    UNION ALL

    SELECT tn.CIF, COALESCE(tn.ngay_giai_ngan_dau_tien, tn.ngay_mo_tai_khoan) AS relationship_start_date
    FROM {{ source('banking', 'tk_no') }} AS tn
    WHERE COALESCE(tn.ngay_giai_ngan_dau_tien, tn.ngay_mo_tai_khoan) IS NOT NULL
),

as_of AS (
    SELECT MAX(as_of_date) AS as_of_date FROM {{ ref('silver_fact_tien_gui_asof') }}
)

SELECT
    rsb.CIF,
    MIN(rsb.relationship_start_date) AS first_relationship_date,
    DATEDIFF(DAY, MIN(rsb.relationship_start_date), ao.as_of_date) AS relationship_tenure_days
FROM relationship_start_base rsb
CROSS JOIN as_of ao
GROUP BY rsb.CIF, ao.as_of_date
