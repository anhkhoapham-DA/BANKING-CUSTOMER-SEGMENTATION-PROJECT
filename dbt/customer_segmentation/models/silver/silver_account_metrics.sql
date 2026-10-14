{{ config(materialized='view') }}

WITH account_status_base AS (
    SELECT
        customer_id,
        CONCAT('DEP|', account_number) AS account_key,
        account_close_date
    FROM {{ ref('silver_deposit_account') }}

    UNION ALL

    SELECT
        customer_id,
        CONCAT('LOAN|', account_number) AS account_key,
        account_close_date
    FROM {{ ref('silver_loan_account') }}
),

as_of AS (
    SELECT as_of_date FROM {{ ref('silver_as_of_date') }}
)

SELECT
    a.customer_id,
    COUNT(DISTINCT CASE
        WHEN a.account_close_date IS NULL OR a.account_close_date > ao.as_of_date
        THEN a.account_key
    END) AS num_active_accounts,
    COUNT(DISTINCT CASE
        WHEN a.account_close_date IS NOT NULL
             AND a.account_close_date > DATEADD(DAY, -90, ao.as_of_date)
             AND a.account_close_date <= ao.as_of_date
        THEN a.account_key
    END) AS num_closed_accounts_90d
FROM account_status_base a
CROSS JOIN as_of ao
GROUP BY a.customer_id
