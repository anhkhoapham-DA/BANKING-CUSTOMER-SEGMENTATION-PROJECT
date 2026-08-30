{{ config(materialized='table') }}

{% set thr_100b = var('threshold_100b', 100000000000.00) %}
{% set thr_10b  = var('threshold_10b', 10000000000.00) %}
{% set thr_5b   = var('threshold_5b', 5000000000.00) %}
{% set thr_1b   = var('threshold_1b', 1000000000.00) %}
{% set thr_100m = var('threshold_100m', 100000000.00) %}

SELECT
    c.*,

    /* 1. Value segment */
    CASE
        WHEN c.current_deposit_balance > {{ thr_100b }} AND c.current_loan_balance > {{ thr_100b }} THEN 'Large Dual Relationship'
        WHEN c.current_deposit_balance > {{ thr_100b }} THEN 'Large Deposit Customer'
        WHEN c.current_loan_balance > {{ thr_100b }} THEN 'Large Loan Customer'
        WHEN c.total_relationship_value > {{ thr_100b }} THEN 'Large Relationship'
        WHEN c.total_relationship_value > {{ thr_10b }} THEN 'High Relationship'
        WHEN c.total_relationship_value > {{ thr_5b }} THEN 'Medium Relationship'
        WHEN c.total_relationship_value > {{ thr_1b }} THEN 'Low Relationship'
        WHEN c.total_relationship_value > {{ thr_100m }} THEN 'Mass Relationship'
        ELSE 'Very Low Relationship'
    END AS value_segment,

    /* 2. Relationship segment */
    CASE
        WHEN c.current_deposit_balance > 0 AND c.current_loan_balance = 0 THEN 'Deposit Only'
        WHEN c.current_deposit_balance = 0 AND c.current_loan_balance > 0 THEN 'Loan Only'
        WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio <= 0.20 THEN 'Balanced Relationship'
        WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share >= 0.60 AND c.loan_share > 0 THEN 'Liquidity Surplus Customer'
        WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share > 0 AND c.loan_share >= 0.90 THEN 'Leverage-Oriented Customer'
        WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 THEN 'Dual Relationship'
        ELSE 'No Financial Relationship'
    END AS relationship_segment,

    /* 3. Product segment */
    CASE
        WHEN c.num_product_group >= 3 AND c.num_products >= 4 THEN 'Multi-Product Relationship'
        WHEN c.num_product_group = 1 AND c.num_products <= 2 THEN 'Single Product Group Customer'
        WHEN c.num_product_group <= 2 AND c.num_products >= 3 THEN 'Shallow Product Group Customer'
        WHEN c.num_product_group = 0 OR c.num_products = 0 THEN 'No Product Customer'
        ELSE 'Standard Relationship'
    END AS product_segment,

    /* 4. Life cycle segment */
    CASE
        WHEN c.num_active_accounts = 0 THEN 'Closed Account'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days <= 90 THEN 'New to Bank'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days BETWEEN 91 AND 365 THEN 'Forming Relationship'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND (COALESCE(c.avg_deposit_balance_365d, 0) + COALESCE(c.avg_loan_balance_365d, 0)) = 0 THEN 'Dormant Relationship'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 1.20 THEN 'Growing'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.85 THEN 'Stable / Maintaining'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.50 THEN 'Shrinking'
        WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio < 0.50 THEN 'Sharply Declining'
        ELSE 'Undetermined'
    END AS life_cycle_segment,

    /* 5. Risk segment */
    CASE
        WHEN c.worst_debt_group >= 3 OR c.risk_score < 491 THEN 'High Risk Identified'
        WHEN c.risk_score IS NULL THEN 'No Risk Score'
        ELSE 'Low Risk Identified'
    END AS risk_flag,

    CASE
        WHEN c.total_relationship_value >= {{ thr_10b }} THEN 'High Value Identified'
        ELSE 'Low Value Identified'
    END AS value_flag,

    CASE
        WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value >= {{ thr_10b }} THEN 'High Value - High Risk'
        WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value < {{ thr_10b }} THEN 'Low Value - High Risk'
        WHEN (COALESCE(c.worst_debt_group, 0) < 3 AND c.risk_score >= 491) AND c.total_relationship_value >= {{ thr_10b }} THEN 'High Value - Low Risk'
        WHEN c.risk_score IS NULL THEN 'Unscored Risk'
        ELSE 'Low Value - Low Risk'
    END AS risk_segment

FROM {{ ref('gold_customer_base') }} c
