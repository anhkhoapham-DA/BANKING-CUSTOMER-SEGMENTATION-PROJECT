{{ config(materialized='view') }}

SELECT
    ma_phan_khuc,
    ten_phan_khuc,
    ma_ten_phan_khuc,
    loai_phan_lhuc,
    CURRENT_TIMESTAMP AS _loaded_at
FROM {{ source('banking', 'master_phan_khuc') }}