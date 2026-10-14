{{ config(materialized='table') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(ma_sp)), '') AS product_id,
        NULLIF(LTRIM(RTRIM(ten_san_pham)), '') AS product_name_source,
        NULLIF(LTRIM(RTRIM(nhom_san_pham)), '') AS product_group_source
    FROM {{ source('banking', 'master_san_pham') }}
)

SELECT
    product.product_id,
    COALESCE(mapping.product_name, product.product_name_source) AS product_name,
    COALESCE(mapping.product_short_name, product.product_name_source) AS product_short_name,
    COALESCE(mapping.product_group, product.product_group_source) AS product_group
FROM cleaned_source AS product
LEFT JOIN {{ ref('product_mapping') }} AS mapping
    ON product.product_id = mapping.product_id
