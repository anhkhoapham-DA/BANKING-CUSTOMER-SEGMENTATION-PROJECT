{{ config(materialized='view') }}

SELECT
    so_tai_khoan,
    CIF,
    ma_san_pham,
    ma_phong_ban,
    ma_can_bo,
    seri_so_tien_kiem,
    loai_tien,
    ngay_mo_tai_khoan,
    ngay_dao_han,
    ngay_dong_tai_khoan,
    loai_ky_han,
    ky_han,
    lai_suat,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'tk_tien_gui') }}