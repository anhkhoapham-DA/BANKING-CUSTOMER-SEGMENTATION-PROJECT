{{ config(materialized='table') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(so_tai_khoan)), '') AS account_number,
        NULLIF(LTRIM(RTRIM(CAST(CAST(CIF AS DECIMAL(38, 0)) AS VARCHAR(50)))), '') AS customer_id,
        NULLIF(LTRIM(RTRIM(CAST(ma_san_pham AS VARCHAR(50)))), '') AS product_id,
        NULLIF(LTRIM(RTRIM(CAST(ma_phong_ban AS VARCHAR(50)))), '') AS department_id,
        NULLIF(LTRIM(RTRIM(ma_can_bo)), '') AS staff_id,
        NULLIF(LTRIM(RTRIM(seri_so_tien_kiem)), '') AS passbook_serial_number,
        NULLIF(LTRIM(RTRIM(loai_tien)), '') AS currency_code,
        CAST(ngay_mo_tai_khoan AS DATE) AS account_open_date,
        CAST(ngay_dao_han AS DATE) AS maturity_date,
        CAST(ngay_dong_tai_khoan AS DATE) AS account_close_date,
        NULLIF(LTRIM(RTRIM(loai_ky_han)), '') AS term_type_source,
        CAST(ky_han AS DECIMAL(10, 2)) AS term_months,
        CAST(lai_suat AS DECIMAL(9, 6)) AS interest_rate
    FROM {{ source('banking', 'tk_tien_gui') }}
)

SELECT
    account_number,
    customer_id,
    product_id,
    department_id,
    staff_id,
    passbook_serial_number,
    currency_code,
    account_open_date,
    maturity_date,
    account_close_date,
    {{ translate_term_type('term_type_source') }} AS term_type,
    term_months,
    interest_rate
FROM cleaned_source