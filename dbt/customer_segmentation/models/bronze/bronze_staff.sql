{{ config(materialized='view') }}

SELECT
       ma_can_bo
      ,ten_can_bo
      ,ma_phong_ban
      ,phong_ban
      ,gioi_tinh
      ,chuc_vu,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_can_bo') }}