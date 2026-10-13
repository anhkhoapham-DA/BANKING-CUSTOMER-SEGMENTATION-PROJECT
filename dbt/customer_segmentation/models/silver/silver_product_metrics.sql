{{ config(materialized='view') }}

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
)

SELECT
    product_base.customer_id,
    COUNT(DISTINCT product_base.product_id) AS num_products,
    COUNT(DISTINCT product.product_group) AS num_product_group
FROM product_base
LEFT JOIN {{ ref('bronze_product') }} AS product
    ON product_base.product_id = product.product_id
GROUP BY product_base.customer_id
