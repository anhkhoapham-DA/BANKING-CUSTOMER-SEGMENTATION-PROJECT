{{ config(materialized='view') }}

SELECT
    deposit_balance.*,
    ao.as_of_date
FROM {{ ref('silver_deposit_balance') }} AS deposit_balance
CROSS JOIN {{ ref('silver_as_of_date') }} AS ao
WHERE deposit_balance.balance_date = ao.as_of_date
