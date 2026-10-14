{{ config(materialized='view') }}
WITH loan_metrics AS (
    SELECT
        loan_account.customer_id,
        SUM(COALESCE(balance.daily_balance_local_currency, 0)) AS current_loan_balance,
        SUM(COALESCE(balance.quarterly_average_balance_local_currency, 0)) AS avg_loan_balance_90d,
        SUM(COALESCE(balance.annual_average_balance_local_currency, 0)) AS avg_loan_balance_365d,
        COUNT(DISTINCT CASE
            WHEN balance.account_number IS NOT NULL THEN loan_account.account_number
        END) AS num_loan_accounts,
        COUNT(DISTINCT loan_account.account_number) AS num_historical_loan_accounts,
        MAX(COALESCE(balance.debt_group, 0)) AS worst_debt_group
    FROM {{ ref('silver_loan_account') }} AS loan_account
    LEFT JOIN {{ ref('silver_fact_du_no_asof') }} AS balance
        ON loan_account.account_number = balance.account_number
    GROUP BY loan_account.customer_id
),

collateral_check AS (
    SELECT
        loan_account.customer_id,
        MAX(CASE
            WHEN loan_account.product_id NOT IN ('5501', '5502', '5528', '6000', '6300') THEN 1
            ELSE 0
        END) AS has_collateral_loan
    FROM {{ ref('silver_loan_account') }} AS loan_account
    INNER JOIN {{ ref('silver_fact_du_no_asof') }} AS balance
        ON loan_account.account_number = balance.account_number
    GROUP BY loan_account.customer_id
)

SELECT
    lm.customer_id,
    lm.current_loan_balance,
    lm.avg_loan_balance_90d,
    lm.avg_loan_balance_365d,
    lm.num_loan_accounts,
    lm.num_historical_loan_accounts,
    lm.worst_debt_group,
    COALESCE(cc.has_collateral_loan, 0) AS has_collateral_loan
FROM loan_metrics AS lm
LEFT JOIN collateral_check AS cc ON lm.customer_id = cc.customer_id
