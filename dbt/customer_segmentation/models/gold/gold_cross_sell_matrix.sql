{{ config(materialized='table') }}

WITH product_base AS (
    SELECT DISTINCT tg.CIF, tg.ma_san_pham
    FROM {{ source('banking', 'tk_tien_gui') }} AS tg
    INNER JOIN {{ ref('silver_fact_tien_gui_asof') }} AS ftg
        ON tg.so_tai_khoan = ftg.so_tai_khoan
    WHERE tg.ma_san_pham IS NOT NULL

    UNION

SELECT DISTINCT tn.CIF, tn.ma_san_pham
FROM {{ source('banking', 'tk_no') }} AS tn
INNER JOIN {{ ref('silver_fact_du_no_asof') }} AS fdn
    ON tn.so_tai_khoan = fdn.so_tai_khoan
WHERE tn.ma_san_pham IS NOT NULL
),
customer_product AS (
    SELECT DISTINCT 
        pb.CIF, 
        sp.nhom_san_pham
    FROM product_base AS pb
    INNER JOIN {{ source('banking', 'master_san_pham') }} AS sp
        ON pb.ma_san_pham = sp.ma_sp
),
pair AS (
    SELECT 
        a.nhom_san_pham AS product_a,
        b.nhom_san_pham AS product_b,
        COUNT(DISTINCT a.CIF) AS kh_both
    FROM customer_product a
    INNER JOIN customer_product b ON a.CIF = b.CIF AND a.nhom_san_pham <> b.nhom_san_pham
    GROUP BY a.nhom_san_pham, b.nhom_san_pham
),
prod_base AS (
    SELECT 
        nhom_san_pham,
        COUNT(DISTINCT CIF) AS kh_a
    FROM customer_product
    GROUP BY nhom_san_pham
)
SELECT 
    p.product_a,
    p.product_b,
    CAST(p.kh_both * 1.0 / b.kh_a AS DECIMAL(10,4)) AS cross_sell_pct
FROM pair p
INNER JOIN prod_base b ON p.product_a = b.nhom_san_pham;