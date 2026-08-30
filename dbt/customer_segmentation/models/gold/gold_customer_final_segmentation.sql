{{ config(materialized='table') }}

SELECT
    s.*,

    CASE
        /* =========================================================================
           GROUP 1: RISK MANAGEMENT (Highest priority to protect capital)
           ========================================================================= */

        /* --- MINOR UNSECURED LOAN WARNING CONTROL: PRIORITY 1 ---
           Reason: Just having a loan and belonging to debt group >= 3 requires bad debt provisioning, regardless of collateral.
         */
        WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = 'High Value - High Risk' AND s.has_collateral_loan = 0) THEN 1

        /* --- RISK GROUP REQUIRING EXTENSION/ADDITIONAL LOAN EVALUATION: PRIORITY 2 ---
           Reason: Might have good repayment history (debt group 1, 2) but high risk score requires segmentation to determine if extension/extra loan/higher interest rate is needed, and no collateral.
         */
        WHEN s.current_loan_balance > 0
            AND s.has_collateral_loan = 0
            AND s.risk_flag = 'High Risk Identified'
            THEN 2

        /* --- HIGH VALUE - HIGH RISK CUSTOMERS WITH COLLATERAL: PRIORITY 3 ---
           Reason: Purpose is to periodically check legal status and revalue collateral for large borrowers to avoid default or late payment risks. And to provision for bad debts immediately if needed.
         */
        WHEN s.risk_segment = 'High Value - High Risk' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN 3


        /* --- OTHER POTENTIAL RISK GROUPS: PRIORITY 4 & 5 ---
            Reason: Customers who haven't borrowed here but might have borrowed elsewhere need assessment on whether to lend. Customers who borrowed here but paid off and still in high risk group also need assessment for new loans. Purpose: closer review for lending, or lend with low limit, high interest rate, and restrict loan product marketing to this group.
            Group 4: Used deposit products but shouldn't be marketed loan products due to risk, or needs careful appraisal before selling loans.
            Group 5: Currently no loans and no deposits. Can market deposit products and restrict loan product marketing.
        */
        WHEN s.risk_flag = 'High Risk Identified' AND s.current_loan_balance = 0 AND s.relationship_segment IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 4
        WHEN s.risk_flag = 'High Risk Identified' AND s.current_loan_balance = 0 AND s.relationship_segment NOT IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 5

        /* =========================================================================
           GROUP 2: VIP / HIGH VALUE CUSTOMERS (Low Risk - Priority 6 to 8)
           ========================================================================= */

        /* --- VIP POOL PROTECTION (FALSE ALARM FIX): PRIORITY 6 ---
           Reason: Account closure (num_closed_accounts_90d > 0) must be accompanied by
           asset decline trend (relationship_trend_ratio < 0.95) to trigger alarm.
           Prevents VIPs from closing a junk credit card but depositing more money from being tagged as "capital withdrawal". */
        WHEN s.value_flag = 'High Value Identified' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN ('Shrinking', 'Sharply Declining') OR (s.num_closed_accounts_90d > 0 AND COALESCE(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = 'Low Risk Identified' THEN 6

        /* --- VIP EXPANSION AND COMPREHENSIVE STRATEGY: PRIORITY 7 AND 8 --- */
        WHEN s.value_flag = 'High Value Identified' AND s.num_active_accounts > 0 AND s.product_segment IN ('Single Product Group Customer', 'Shallow Product Group Customer') AND s.risk_flag = 'Low Risk Identified' THEN 7
        WHEN s.value_flag = 'High Value Identified' THEN 8


        /* =========================================================================
           GROUP 3: NEW CUSTOMERS & DEVELOPMENT POTENTIAL (Priority 9 to 12)
           ========================================================================= */
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN ('New to Bank', 'Forming Relationship') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = 'Low Risk Identified' THEN 9
        WHEN s.num_active_accounts > 0 AND s.product_segment IN ('Single Product Group Customer', 'Shallow Product Group Customer') AND s.risk_flag = 'Low Risk Identified' THEN 10
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = 'Forming Relationship' AND s.product_segment = 'No Product Customer' AND s.risk_flag = 'Low Risk Identified' THEN 11

        /* --- PRIORITY 11: HAS ACCOUNT BUT NOT USING PRODUCTS ---
        Reason: Has active account (e.g. payroll) but hasn't used any deposit/loan products. This group needs approach to activate product usage. */
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN ('New to Bank', 'Forming Relationship') AND s.risk_flag = 'Low Risk Identified' THEN 12


        /* =========================================================================
           GROUP 4: MATURE CUSTOMERS & SPECIFIC BEHAVIORS (Priority 13 to 17)
           ========================================================================= */
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = 'Growing' THEN 13
        WHEN s.num_active_accounts > 0 AND s.product_segment = 'Multi-Product Relationship' THEN 14
        WHEN s.num_active_accounts > 0 AND s.relationship_segment = 'Balanced Relationship' THEN 15
        WHEN s.num_active_accounts > 0 AND s.relationship_segment IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 16
        WHEN s.num_active_accounts > 0 AND s.relationship_segment IN ('Loan Only', 'Leverage-Oriented Customer') THEN 17

        /* =========================================================================
           GROUP 5: INACTIVE / DORMANT CUSTOMERS (Priority 18 & 19)
           ========================================================================= */
        WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = 'Dormant Relationship' THEN 18
        WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = 'Dormant Relationship' THEN 19

        /* --- BOTTOM OF FUNNEL MASS CUSTOMERS --- */
        ELSE 20
    END AS final_segmentation_priority,

    CASE
        WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = 'High Value - High Risk' AND s.has_collateral_loan = 0) THEN 'Risk - Needs Bad Debt Provision'
        WHEN s.current_loan_balance > 0 AND s.has_collateral_loan = 0 AND s.risk_flag = 'High Risk Identified' THEN 'Risk - Needs Re-appraisal'
        WHEN s.risk_segment = 'High Value - High Risk' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN 'Risk with Collateral - Needs Control'
        WHEN s.risk_flag = 'High Risk Identified' AND s.current_loan_balance = 0 AND s.relationship_segment IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 'Potential Risk - Deposit Customer'
        WHEN s.risk_flag = 'High Risk Identified' AND s.current_loan_balance = 0 AND s.relationship_segment NOT IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 'Potential Risk - No Product Relationship'

        WHEN s.value_flag = 'High Value Identified' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN ('Shrinking', 'Sharply Declining') OR (s.num_closed_accounts_90d > 0 AND COALESCE(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = 'Low Risk Identified' THEN 'High Value Customer - Needs Retention'
        WHEN s.value_flag = 'High Value Identified' AND s.num_active_accounts > 0 AND s.product_segment IN ('Single Product Group Customer', 'Shallow Product Group Customer') AND s.risk_flag = 'Low Risk Identified' THEN 'High Value Customer - Needs Relationship Expansion'
        WHEN s.value_flag = 'High Value Identified' THEN 'Stable High Value Customer'

        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN ('New to Bank', 'Forming Relationship') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = 'Low Risk Identified' THEN 'High Potential New Customer'
        WHEN s.num_active_accounts > 0 AND s.product_segment IN ('Single Product Group Customer', 'Shallow Product Group Customer') AND s.risk_flag = 'Low Risk Identified' THEN 'Cross-sell Potential Customer'
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = 'Forming Relationship' AND s.product_segment = 'No Product Customer' AND s.risk_flag = 'Low Risk Identified' THEN 'Passive Customer - No Product Used'
        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN ('New to Bank', 'Forming Relationship') AND s.risk_flag = 'Low Risk Identified' THEN 'New Customer - Building Relationship'

        WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = 'Growing' THEN 'Mature Customer'
        WHEN s.num_active_accounts > 0 AND s.product_segment = 'Multi-Product Relationship' THEN 'Deep Relationship Customer - Needs Maintenance'
        WHEN s.num_active_accounts > 0 AND s.relationship_segment = 'Balanced Relationship' THEN 'Stable Balanced Relationship Customer'
        WHEN s.num_active_accounts > 0 AND s.relationship_segment IN ('Deposit Only', 'Liquidity Surplus Customer') THEN 'Deposit-Leaning Customer'
        WHEN s.num_active_accounts > 0 AND s.relationship_segment IN ('Loan Only', 'Leverage-Oriented Customer') THEN 'Loan-Leaning Customer'

        WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = 'Dormant Relationship' THEN 'Dormant Relationship Customer'
        WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = 'Dormant Relationship' THEN 'Closed / Inactive'
        ELSE 'Base Customer / Standard Relationship'
    END AS final_segmentation

FROM {{ ref('gold_customer_segments') }} s
