{{ config(materialized='view') }}

WITH dep_snapshot_accounts AS (
    SELECT DISTINCT
        tg.CIF,
        tg.so_tai_khoan,
        tg.ma_san_pham,
        tg.ngay_mo_tai_khoan,
        tg.ngay_dong_tai_khoan
    FROM {{ source('banking', 'tk_tien_gui') }} AS tg
    INNER JOIN {{ ref('silver_fact_tien_gui_asof') }} AS ftg
        ON tg.so_tai_khoan = ftg.so_tai_khoan
)

SELECT
    tg.CIF,
    SUM(COALESCE(ftg.so_du_tien_gui_ngay_quy_doi, 0))    AS current_deposit_balance,
    SUM(COALESCE(ftg.so_du_tien_gui_bq_quy_quy_doi, 0))  AS avg_deposit_balance_90d,
    SUM(COALESCE(ftg.so_du_tien_gui_bq_nam_quy_doi, 0))  AS avg_deposit_balance_365d,
    COUNT(DISTINCT CASE WHEN ftg.so_tai_khoan IS NOT NULL THEN tg.so_tai_khoan END) AS num_deposit_accounts
FROM {{ source('banking', 'tk_tien_gui') }} AS tg
LEFT JOIN {{ ref('silver_fact_tien_gui_asof') }} AS ftg
    ON tg.so_tai_khoan = ftg.so_tai_khoan
GROUP BY tg.CIF
