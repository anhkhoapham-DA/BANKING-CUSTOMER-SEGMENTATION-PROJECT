{{ config(materialized='view') }}

SELECT
       ma_sp
      ,ten_san_pham
      ,ten_viet_gom
      ,nhom_san_pham,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_san_pham') }}