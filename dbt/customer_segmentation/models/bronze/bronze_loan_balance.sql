{{ config(materialized='view') }}

SELECT
    CAST(ngay AS DATE) AS balance_date,
    NULLIF(LTRIM(RTRIM(so_tai_khoan)), '') AS account_number,
    CAST(nhom_no AS INT) AS debt_group,
    CAST(du_no_ngay_nguyen_te AS DECIMAL(19, 2)) AS daily_balance_original_currency,
    CAST(du_no_ngay_quy_doi AS DECIMAL(19, 2)) AS daily_balance_local_currency,
    CAST(du_no_bq_quy_quy_doi AS DECIMAL(19, 2)) AS quarterly_average_balance_local_currency,
    CAST(du_no_bq_nam_quy_doi AS DECIMAL(19, 2)) AS annual_average_balance_local_currency
FROM {{ source('banking', 'fact_du_no') }}