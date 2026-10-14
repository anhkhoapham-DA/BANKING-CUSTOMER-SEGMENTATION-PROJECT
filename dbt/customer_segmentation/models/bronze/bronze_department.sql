{{ config(materialized='view') }}

SELECT
    ma_phong_ban,
    ten_phong_ban,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_phong_ban') }}