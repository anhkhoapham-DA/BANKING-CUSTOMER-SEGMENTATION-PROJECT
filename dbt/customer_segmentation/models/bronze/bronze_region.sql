{{ config(materialized='view') }}

SELECT
    ten_quan,
    dien_tich_km2,
    dan_so,
    mat_do,
    lat,
    long,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_khu_vuc') }}