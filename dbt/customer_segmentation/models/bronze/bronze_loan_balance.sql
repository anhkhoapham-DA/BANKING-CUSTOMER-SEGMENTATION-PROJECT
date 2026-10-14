{{ config(materialized='view') }}

SELECT
    ngay,
    so_tai_khoan,
    nhom_no,
    du_no_ngay_nguyen_te,
    du_no_ngay_quy_doi,
    du_no_bq_quy_quy_doi,
    du_no_bq_nam_quy_doi,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'fact_du_no') }}