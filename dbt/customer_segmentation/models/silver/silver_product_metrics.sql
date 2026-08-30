{{ config(materialized='view') }}

WITH product_base AS (
    SELECT DISTINCT tg.CIF, tg.ma_san_pham
    FROM {{ source('banking', 'tk_tien_gui') }} AS tg
    INNER JOIN {{ ref('silver_fact_tien_gui_asof') }} AS ftg
        ON tg.so_tai_khoan = ftg.so_tai_khoan
    WHERE tg.ma_san_pham IS NOT NULL

    UNION

    SELECT DISTINCT tn.CIF, tn.ma_san_pham
    FROM {{ source('banking', 'tk_no') }} AS tn
    INNER JOIN {{ source('banking', 'fact_du_no') }} AS fdn
        ON tn.so_tai_khoan = fdn.so_tai_khoan
    WHERE tn.ma_san_pham IS NOT NULL
)

SELECT
    pb.CIF,
    COUNT(DISTINCT pb.ma_san_pham) AS num_products,
    COUNT(DISTINCT msp.nhom_san_pham) AS num_product_group
FROM product_base pb
LEFT JOIN {{ source('banking', 'master_san_pham') }} AS msp
    ON pb.ma_san_pham = msp.ma_sp
GROUP BY pb.CIF
