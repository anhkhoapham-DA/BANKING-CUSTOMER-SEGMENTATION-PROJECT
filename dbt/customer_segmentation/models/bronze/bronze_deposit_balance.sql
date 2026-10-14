{{ config(materialized='view') }}

SELECT
      ngay
      ,so_tai_khoan
      ,so_du_tien_gui_ngay_nguyen_te  
      ,so_du_tien_gui_ngay_quy_doi
      ,so_du_tien_gui_bq_quy_quy_doi
      ,so_du_tien_gui_bq_nam_quy_doi,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'fact_tien_gui') }}