{{ config(materialized='view') }}

WITH fact_du_no_asof AS (
    SELECT fdn.*
    FROM {{ source('banking', 'fact_du_no') }} AS fdn
    INNER JOIN (SELECT MAX(ngay) AS as_of_date FROM {{ source('banking', 'fact_du_no') }}) ao
        ON fdn.ngay = ao.as_of_date
),

loan_metrics AS (
    SELECT
        tn.CIF,
        SUM(COALESCE(fdn.du_no_ngay_quy_doi, 0))    AS current_loan_balance,
        SUM(COALESCE(fdn.du_no_bq_quy_quy_doi, 0))  AS avg_loan_balance_90d,
        SUM(COALESCE(fdn.du_no_bq_nam_quy_doi, 0))  AS avg_loan_balance_365d,
        COUNT(DISTINCT CASE WHEN fdn.so_tai_khoan IS NOT NULL THEN tn.so_tai_khoan END) AS num_loan_accounts,
        COUNT(DISTINCT tn.so_tai_khoan)             AS num_historical_loan_accounts,
        MAX(COALESCE(fdn.nhom_no, 0))               AS worst_debt_group
    FROM {{ source('banking', 'tk_no') }} AS tn
    LEFT JOIN fact_du_no_asof AS fdn
        ON tn.so_tai_khoan = fdn.so_tai_khoan
    GROUP BY tn.CIF
),

collateral_check AS (
    SELECT
        tn.CIF,
        MAX(CASE WHEN tn.ma_san_pham NOT IN (5501, 5502, 5528, 6000, 6300) THEN 1 ELSE 0 END) AS has_collateral_loan
    FROM {{ source('banking', 'tk_no') }} AS tn
    INNER JOIN fact_du_no_asof AS fdn
        ON tn.so_tai_khoan = fdn.so_tai_khoan
    GROUP BY tn.CIF
)

SELECT
    lm.CIF,
    lm.current_loan_balance,
    lm.avg_loan_balance_90d,
    lm.avg_loan_balance_365d,
    lm.num_loan_accounts,
    lm.num_historical_loan_accounts,
    lm.worst_debt_group,
    COALESCE(cc.has_collateral_loan, 0) AS has_collateral_loan
FROM loan_metrics lm
LEFT JOIN collateral_check cc ON lm.CIF = cc.CIF
