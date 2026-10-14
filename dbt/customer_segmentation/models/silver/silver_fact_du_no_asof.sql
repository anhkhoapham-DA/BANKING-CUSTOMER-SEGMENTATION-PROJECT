{{ config(materialized='view') }}

SELECT
    loan_balance.*,
    ao.as_of_date
FROM {{ ref('silver_loan_balance') }} AS loan_balance
CROSS JOIN {{ ref('silver_as_of_date') }} AS ao
WHERE loan_balance.balance_date = ao.as_of_date
