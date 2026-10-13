{{ config(materialized='view') }}

SELECT
    deposit_account.customer_id,
    SUM(COALESCE(balance.daily_balance_local_currency, 0)) AS current_deposit_balance,
    SUM(COALESCE(balance.quarterly_average_balance_local_currency, 0)) AS avg_deposit_balance_90d,
    SUM(COALESCE(balance.annual_average_balance_local_currency, 0)) AS avg_deposit_balance_365d,
    COUNT(DISTINCT CASE
        WHEN balance.account_number IS NOT NULL THEN deposit_account.account_number
    END) AS num_deposit_accounts
FROM {{ ref('bronze_deposit_account') }} AS deposit_account
LEFT JOIN {{ ref('silver_fact_tien_gui_asof') }} AS balance
    ON deposit_account.account_number = balance.account_number
GROUP BY deposit_account.customer_id
