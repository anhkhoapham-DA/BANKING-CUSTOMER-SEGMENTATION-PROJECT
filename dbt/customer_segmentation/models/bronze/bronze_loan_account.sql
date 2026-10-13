{{ config(materialized='view') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(so_tai_khoan)), '') AS account_number,
        NULLIF(LTRIM(RTRIM(CAST(CAST(CIF AS DECIMAL(38, 0)) AS VARCHAR(50)))), '') AS customer_id,
        NULLIF(LTRIM(RTRIM(CAST(ma_san_pham AS VARCHAR(50)))), '') AS product_id,
        NULLIF(LTRIM(RTRIM(CAST(ma_phong_ban AS VARCHAR(50)))), '') AS department_id,
        NULLIF(LTRIM(RTRIM(ma_can_bo)), '') AS staff_id,
        NULLIF(LTRIM(RTRIM(loai_tien)), '') AS currency_code,
        NULLIF(LTRIM(RTRIM(loai_ky_han)), '') AS term_type_source,
        CAST(CAST(lai_suat_thuc AS DECIMAL(9, 6)) / 100.0 AS DECIMAL(9, 6)) AS interest_rate,
        CAST(ngay_mo_tai_khoan AS DATE) AS account_open_date,
        CAST(ngay_dao_han AS DATE) AS maturity_date,
        CAST(ngay_giai_ngan_dau_tien AS DATE) AS first_disbursement_date,
        CAST(ngay_giai_ngan_gan_nhat AS DATE) AS latest_disbursement_date,
        CAST(ngay_dong_tai_khoan AS DATE) AS account_close_date
    FROM {{ source('banking', 'tk_no') }}
)

SELECT
    account_number,
    customer_id,
    product_id,
    department_id,
    staff_id,
    currency_code,
    {{ translate_term_type('term_type_source') }} AS term_type,
    interest_rate,
    account_open_date,
    maturity_date,
    first_disbursement_date,
    latest_disbursement_date,
    account_close_date
FROM cleaned_source