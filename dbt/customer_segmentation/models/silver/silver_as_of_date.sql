{{ config(materialized='view') }}

WITH max_dates AS (
    SELECT MAX(balance_date) AS max_date
    FROM {{ ref('bronze_deposit_balance') }}

    UNION ALL

    SELECT MAX(balance_date) AS max_date
    FROM {{ ref('bronze_loan_balance') }}
)

SELECT MIN(max_date) AS as_of_date
FROM max_dates
