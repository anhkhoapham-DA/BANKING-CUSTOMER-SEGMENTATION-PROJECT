{{ config(materialized='table') }}

WITH product_base AS (
    SELECT DISTINCT deposit_account.customer_id, deposit_account.product_id
    FROM {{ ref('bronze_deposit_account') }} AS deposit_account
    INNER JOIN {{ ref('silver_fact_tien_gui_asof') }} AS balance
        ON deposit_account.account_number = balance.account_number
    WHERE deposit_account.product_id IS NOT NULL

    UNION

    SELECT DISTINCT loan_account.customer_id, loan_account.product_id
    FROM {{ ref('bronze_loan_account') }} AS loan_account
    INNER JOIN {{ ref('silver_fact_du_no_asof') }} AS balance
        ON loan_account.account_number = balance.account_number
    WHERE loan_account.product_id IS NOT NULL
),
customer_product AS (
    SELECT DISTINCT
        pb.customer_id,
        product.product_group
    FROM product_base AS pb
    INNER JOIN {{ ref('bronze_product') }} AS product
        ON pb.product_id = product.product_id
),
pair AS (
    SELECT
        a.product_group AS product_a,
        b.product_group AS product_b,
        COUNT(DISTINCT a.customer_id) AS customers_with_both
    FROM customer_product a
    INNER JOIN customer_product b
        ON a.customer_id = b.customer_id
        AND a.product_group <> b.product_group
    GROUP BY a.product_group, b.product_group
),
prod_base AS (
    SELECT
        product_group,
        COUNT(DISTINCT customer_id) AS customers_with_product
    FROM customer_product
    GROUP BY product_group
)
SELECT
    p.product_a,
    p.product_b,
    CAST(p.customers_with_both * 1.0 / b.customers_with_product AS DECIMAL(10,4)) AS cross_sell_pct
FROM pair p
INNER JOIN prod_base b ON p.product_a = b.product_group