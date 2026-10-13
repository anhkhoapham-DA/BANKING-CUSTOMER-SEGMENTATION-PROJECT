{{ config(materialized='view') }}

WITH relationship_start_base AS (
    SELECT customer_id, account_open_date AS relationship_start_date
    FROM {{ ref('bronze_deposit_account') }}
    WHERE account_open_date IS NOT NULL

    UNION ALL

    SELECT
        customer_id,
        COALESCE(first_disbursement_date, account_open_date) AS relationship_start_date
    FROM {{ ref('bronze_loan_account') }}
    WHERE COALESCE(first_disbursement_date, account_open_date) IS NOT NULL
),

as_of AS (
    SELECT as_of_date FROM {{ ref('silver_as_of_date') }}
)

SELECT
    rsb.customer_id,
    MIN(rsb.relationship_start_date) AS first_relationship_date,
    DATEDIFF(DAY, MIN(rsb.relationship_start_date), ao.as_of_date) AS relationship_tenure_days
FROM relationship_start_base rsb
CROSS JOIN as_of ao
GROUP BY rsb.customer_id, ao.as_of_date
