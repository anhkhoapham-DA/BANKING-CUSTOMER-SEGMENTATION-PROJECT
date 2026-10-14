{{ config(materialized='view') }}

SELECT
    CIF,
    ten_khach_hang,
    ma_phan_khuc,
    phan_loai,
    ngay_sinh,
    tuoi,
    nhom_tuoi,
    ten_quan,
    nghe_nghiep,
    diem_rui_ro,
    trang_thai,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_khach_hang') }}