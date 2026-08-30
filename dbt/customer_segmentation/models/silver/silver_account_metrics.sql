{{ config(materialized='view') }}

WITH account_status_base AS (
    SELECT tg.CIF, CONCAT('DEP|', tg.so_tai_khoan) AS account_key, tg.ngay_dong_tai_khoan
    FROM {{ source('banking', 'tk_tien_gui') }} AS tg

    UNION ALL

    SELECT tn.CIF, CONCAT('LOAN|', tn.so_tai_khoan) AS account_key, tn.ngay_dong_tai_khoan
    FROM {{ source('banking', 'tk_no') }} AS tn
),

as_of AS (
    SELECT MAX(as_of_date) AS as_of_date FROM {{ ref('silver_fact_tien_gui_asof') }}
)

SELECT
    a.CIF,
    COUNT(DISTINCT CASE
        WHEN a.ngay_dong_tai_khoan IS NULL OR a.ngay_dong_tai_khoan > ao.as_of_date
        THEN a.account_key
    END) AS num_active_accounts,
    COUNT(DISTINCT CASE
        WHEN a.ngay_dong_tai_khoan IS NOT NULL
             AND a.ngay_dong_tai_khoan > DATEADD(DAY, -90, ao.as_of_date)
             AND a.ngay_dong_tai_khoan <= ao.as_of_date
        THEN a.account_key
    END) AS num_closed_accounts_90d
FROM account_status_base a
CROSS JOIN as_of ao
GROUP BY a.CIF
