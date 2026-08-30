{{ config(materialized='table') }}

WITH base AS (
    SELECT
        kh.CIF,
        kh.ten_khach_hang,
        kh.ma_phan_khuc,
        kh.ten_phan_khuc,
        kh.loai_phan_khuc,
        kh.phan_loai,
        kh.ten_quan,
        kh.nhom_tuoi,
        kh.nghe_nghiep,
        kh.trang_thai,
        kh.diem_rui_ro AS risk_score,

        COALESCE(dm.current_deposit_balance, 0)  AS current_deposit_balance,
        COALESCE(dm.avg_deposit_balance_90d, 0)  AS avg_deposit_balance_90d,
        COALESCE(dm.avg_deposit_balance_365d, 0) AS avg_deposit_balance_365d,
        COALESCE(dm.num_deposit_accounts, 0)     AS num_deposit_accounts,

        COALESCE(lm.current_loan_balance, 0)     AS current_loan_balance,
        COALESCE(lm.avg_loan_balance_90d, 0)     AS avg_loan_balance_90d,
        COALESCE(lm.avg_loan_balance_365d, 0)    AS avg_loan_balance_365d,
        COALESCE(lm.worst_debt_group, 0)         AS worst_debt_group,
        COALESCE(lm.num_loan_accounts, 0)        AS num_loan_accounts,
        CASE WHEN COALESCE(lm.num_loan_accounts, 0) > 0 THEN 1 ELSE 0 END AS have_borrowed,
        COALESCE(lm.has_collateral_loan, 0)      AS has_collateral_loan,

        COALESCE(pm.num_products, 0)             AS num_products,
        COALESCE(pm.num_product_group, 0)        AS num_product_group,

        tm.first_relationship_date,
        COALESCE(tm.relationship_tenure_days, 0) AS relationship_tenure_days,

        COALESCE(am.num_active_accounts, 0)      AS num_active_accounts,
        COALESCE(am.num_closed_accounts_90d, 0)  AS num_closed_accounts_90d

    FROM {{ source('banking', 'master_khach_hang') }} AS kh
    LEFT JOIN {{ ref('silver_deposit_metrics') }} AS dm ON kh.CIF = dm.CIF
    LEFT JOIN {{ ref('silver_loan_metrics') }}    AS lm ON kh.CIF = lm.CIF
    LEFT JOIN {{ ref('silver_product_metrics') }} AS pm ON kh.CIF = pm.CIF
    LEFT JOIN {{ ref('silver_tenure_metrics') }}  AS tm ON kh.CIF = tm.CIF
    LEFT JOIN {{ ref('silver_account_metrics') }} AS am ON kh.CIF = am.CIF
)

SELECT
    b.*,
    (b.current_deposit_balance + b.current_loan_balance) AS total_relationship_value,
    (b.current_deposit_balance - b.current_loan_balance) AS net_position,

    CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0
         THEN ABS(b.current_deposit_balance - b.current_loan_balance) * 1.0
              / (b.current_deposit_balance + b.current_loan_balance)
         ELSE 0 END AS balance_ratio,

    CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0
         THEN b.current_deposit_balance * 1.0 / (b.current_deposit_balance + b.current_loan_balance)
         ELSE 0 END AS deposit_share,

    CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0
         THEN b.current_loan_balance * 1.0 / (b.current_deposit_balance + b.current_loan_balance)
         ELSE 0 END AS loan_share,

    CASE WHEN b.avg_deposit_balance_365d > 0
         THEN b.avg_deposit_balance_90d * 1.0 / b.avg_deposit_balance_365d
         ELSE NULL END AS deposit_trend_ratio,

    CASE WHEN b.avg_loan_balance_365d > 0
         THEN b.avg_loan_balance_90d * 1.0 / b.avg_loan_balance_365d
         ELSE NULL END AS loan_trend_ratio,

    CASE WHEN (b.avg_deposit_balance_365d + b.avg_loan_balance_365d) > 0
         THEN (b.avg_deposit_balance_90d + b.avg_loan_balance_90d) * 1.0
              / (b.avg_deposit_balance_365d + b.avg_loan_balance_365d)
         ELSE NULL END AS relationship_trend_ratio
FROM base b
