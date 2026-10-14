{{ config(materialized='view') }}

SELECT
      so_tai_khoan
      ,CIF
      ,ma_san_pham
      ,ma_phong_ban
      ,ma_can_bo
      ,loai_tien
      ,loai_ky_han
      ,lai_suat_thuc
      ,ngay_mo_tai_khoan
      ,ngay_dao_han
      ,ngay_giai_ngan_dau_tien
      ,ngay_giai_ngan_gan_nhat
      ,ngay_dong_tai_khoan,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'tk_no') }}