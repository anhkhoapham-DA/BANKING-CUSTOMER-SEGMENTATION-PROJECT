DECLARE @as_of_date DATE;

DECLARE @THR_100B DECIMAL(19,2) = 100000000000.00; -- 100 Billion
DECLARE @THR_10B  DECIMAL(19,2) = 10000000000.00;  -- 10 Billion
DECLARE @THR_5B   DECIMAL(19,2) = 5000000000.00;   -- 5 Billion
DECLARE @THR_1B   DECIMAL(19,2) = 1000000000.00;   -- 1 Billion
DECLARE @THR_100M DECIMAL(19,2) = 100000000.00;    -- 100 Million

-- Use the latest common snapshot date between deposits and loans
SELECT @as_of_date = MIN(x.max_date)
FROM (
    SELECT MAX(ngay) AS max_date FROM dbo.fact_tien_gui
    UNION ALL
    SELECT MAX(ngay) AS max_date FROM dbo.fact_du_no
) x;

WITH dep_snapshot_accounts AS (
    SELECT DISTINCT tg.CIF, tg.so_tai_khoan, tg.ma_san_pham, tg.ngay_mo_tai_khoan, tg.ngay_dong_tai_khoan
    FROM dbo.tk_tien_gui tg
    INNER JOIN dbo.fact_tien_gui ftg ON tg.so_tai_khoan = ftg.so_tai_khoan AND ftg.ngay = @as_of_date
),
loan_snapshot_accounts AS (
    SELECT DISTINCT tn.CIF, tn.so_tai_khoan, tn.ma_san_pham, tn.ngay_mo_tai_khoan, tn.ngay_giai_ngan_dau_tien, tn.ngay_dong_tai_khoan
    FROM dbo.tk_no tn
    INNER JOIN dbo.fact_du_no fdn ON tn.so_tai_khoan = fdn.so_tai_khoan AND fdn.ngay = @as_of_date
),
dep_metrics AS (
    SELECT tg.CIF,
        SUM(ISNULL(ftg.so_du_tien_gui_ngay_quy_doi, 0))   AS current_deposit_balance,
        SUM(ISNULL(ftg.so_du_tien_gui_bq_quy_quy_doi, 0)) AS avg_deposit_balance_90d,
        SUM(ISNULL(ftg.so_du_tien_gui_bq_nam_quy_doi, 0)) AS avg_deposit_balance_365d,
        COUNT(DISTINCT CASE WHEN ftg.so_tai_khoan IS NOT NULL THEN tg.so_tai_khoan END) AS num_deposit_accounts
    FROM dbo.tk_tien_gui tg
    LEFT JOIN dbo.fact_tien_gui ftg ON tg.so_tai_khoan = ftg.so_tai_khoan AND ftg.ngay = @as_of_date
    GROUP BY tg.CIF
),
loan_metrics AS (
    SELECT tn.CIF,
        SUM(ISNULL(fdn.du_no_ngay_quy_doi, 0))    AS current_loan_balance,
        SUM(ISNULL(fdn.du_no_bq_quy_quy_doi, 0))  AS avg_loan_balance_90d,
        SUM(ISNULL(fdn.du_no_bq_nam_quy_doi, 0))  AS avg_loan_balance_365d,
        COUNT(DISTINCT CASE WHEN fdn.so_tai_khoan IS NOT NULL THEN tn.so_tai_khoan END) AS num_loan_accounts,
        COUNT(DISTINCT tn.so_tai_khoan)           AS num_historical_loan_accounts, 
        MAX(ISNULL(fdn.nhom_no, 0))               AS worst_debt_group
    FROM dbo.tk_no tn
    LEFT JOIN dbo.fact_du_no fdn ON tn.so_tai_khoan = fdn.so_tai_khoan AND fdn.ngay = @as_of_date
    GROUP BY tn.CIF
),
collateral_check AS (
    SELECT tn.CIF,
        MAX(CASE WHEN tn.ma_san_pham NOT IN (5501, 5502, 5528, 6000, 6300) THEN 1 ELSE 0 END) AS has_collateral_loan -- unsecured product codes or consumer loans without collateral
    FROM dbo.tk_no tn
    INNER JOIN dbo.fact_du_no fdn ON tn.so_tai_khoan = fdn.so_tai_khoan AND fdn.ngay = @as_of_date
    GROUP BY tn.CIF
),
product_base AS (
    SELECT dsa.CIF, dsa.ma_san_pham FROM dep_snapshot_accounts dsa WHERE dsa.ma_san_pham IS NOT NULL
    UNION
    SELECT lsa.CIF, lsa.ma_san_pham FROM loan_snapshot_accounts lsa WHERE lsa.ma_san_pham IS NOT NULL
),
product_metrics AS (
    SELECT pb.CIF, COUNT(DISTINCT pb.ma_san_pham) AS num_products, COUNT(DISTINCT msp.nhom_san_pham) AS num_product_group
    FROM product_base pb
    LEFT JOIN dbo.master_san_pham msp ON pb.ma_san_pham = msp.ma_sp
    GROUP BY pb.CIF
),
relationship_start_base AS (
    SELECT tg.CIF, tg.ngay_mo_tai_khoan AS relationship_start_date FROM dbo.tk_tien_gui tg WHERE tg.ngay_mo_tai_khoan IS NOT NULL
    UNION ALL
    SELECT tn.CIF, COALESCE(tn.ngay_giai_ngan_dau_tien, tn.ngay_mo_tai_khoan) AS relationship_start_date FROM dbo.tk_no tn WHERE COALESCE(tn.ngay_giai_ngan_dau_tien, tn.ngay_mo_tai_khoan) IS NOT NULL
),
tenure_metrics AS (
    SELECT rsb.CIF, MIN(rsb.relationship_start_date) AS first_relationship_date, DATEDIFF(DAY, MIN(rsb.relationship_start_date), @as_of_date) AS relationship_tenure_days
    FROM relationship_start_base rsb GROUP BY rsb.CIF
),
account_status_base AS (
    SELECT tg.CIF, CONCAT('DEP|', tg.so_tai_khoan) AS account_key, tg.ngay_dong_tai_khoan FROM dbo.tk_tien_gui tg
    UNION ALL
    SELECT tn.CIF, CONCAT('LOAN|', tn.so_tai_khoan) AS account_key, tn.ngay_dong_tai_khoan FROM dbo.tk_no tn
),
account_metrics AS (
    SELECT a.CIF,
        COUNT(DISTINCT CASE WHEN a.ngay_dong_tai_khoan IS NULL OR a.ngay_dong_tai_khoan > @as_of_date THEN a.account_key END) AS num_active_accounts,
        COUNT(DISTINCT CASE WHEN a.ngay_dong_tai_khoan IS NOT NULL AND a.ngay_dong_tai_khoan > DATEADD(DAY, -90, @as_of_date) AND a.ngay_dong_tai_khoan <= @as_of_date THEN a.account_key END) AS num_closed_accounts_90d
    FROM account_status_base a GROUP BY a.CIF
),
base AS (
    SELECT kh.CIF,
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

        ISNULL(dm.current_deposit_balance, 0)   AS current_deposit_balance,
        ISNULL(dm.avg_deposit_balance_90d, 0)   AS avg_deposit_balance_90d,
        ISNULL(dm.avg_deposit_balance_365d, 0)  AS avg_deposit_balance_365d,
        ISNULL(dm.num_deposit_accounts, 0)      AS num_deposit_accounts,
        ISNULL(lm.current_loan_balance, 0)      AS current_loan_balance,
        ISNULL(lm.avg_loan_balance_90d, 0)      AS avg_loan_balance_90d,
        ISNULL(lm.avg_loan_balance_365d, 0)     AS avg_loan_balance_365d,
        ISNULL(lm.worst_debt_group, 0)          AS worst_debt_group,
        ISNULL(lm.num_loan_accounts, 0)         AS num_loan_accounts,
        CASE WHEN ISNULL(lm.num_loan_accounts, 0) > 0 THEN 1 ELSE 0 END AS have_borrowed,
        ISNULL(pm.num_products, 0)              AS num_products,
        ISNULL(pm.num_product_group, 0)         AS num_product_group,
        tm.first_relationship_date,
        ISNULL(tm.relationship_tenure_days, 0)  AS relationship_tenure_days,
        ISNULL(am.num_active_accounts, 0)       AS num_active_accounts,
        ISNULL(am.num_closed_accounts_90d, 0)   AS num_closed_accounts_90d,
        ISNULL(cc.has_collateral_loan, 0)       AS has_collateral_loan
    FROM dbo.master_khach_hang kh
    LEFT JOIN dep_metrics dm ON kh.CIF = dm.CIF
    LEFT JOIN loan_metrics lm ON kh.CIF = lm.CIF
    LEFT JOIN product_metrics pm ON kh.CIF = pm.CIF
    LEFT JOIN tenure_metrics tm ON kh.CIF = tm.CIF
    LEFT JOIN account_metrics am ON kh.CIF = am.CIF
    LEFT JOIN collateral_check cc ON kh.CIF = cc.CIF
),
calc AS (
    SELECT @as_of_date AS as_of_date, b.*,
        (b.current_deposit_balance + b.current_loan_balance) AS total_relationship_value,
        (b.current_deposit_balance - b.current_loan_balance) AS net_position,
        CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0 THEN ABS(b.current_deposit_balance - b.current_loan_balance) * 1.0 / (b.current_deposit_balance + b.current_loan_balance) ELSE 0 END AS balance_ratio,
        CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0 THEN b.current_deposit_balance * 1.0 / (b.current_deposit_balance + b.current_loan_balance) ELSE 0 END AS deposit_share,
        CASE WHEN (b.current_deposit_balance + b.current_loan_balance) > 0 THEN b.current_loan_balance * 1.0 / (b.current_deposit_balance + b.current_loan_balance) ELSE 0 END AS loan_share,
        CASE WHEN b.avg_deposit_balance_365d > 0 THEN b.avg_deposit_balance_90d * 1.0 / b.avg_deposit_balance_365d ELSE NULL END AS deposit_trend_ratio,
        CASE WHEN b.avg_loan_balance_365d > 0 THEN b.avg_loan_balance_90d * 1.0 / b.avg_loan_balance_365d ELSE NULL END AS loan_trend_ratio,
        CASE WHEN (b.avg_deposit_balance_365d + b.avg_loan_balance_365d) > 0 THEN (b.avg_deposit_balance_90d + b.avg_loan_balance_90d) * 1.0 / (b.avg_deposit_balance_365d + b.avg_loan_balance_365d) ELSE NULL END AS relationship_trend_ratio
    FROM base b
),
segments AS (
    SELECT c.*,

       CASE
            WHEN c.current_deposit_balance > @THR_100B AND c.current_loan_balance > @THR_100B THEN N'Large Dual Relationship'
            WHEN c.current_deposit_balance > @THR_100B THEN N'Large Deposit Customer'
            WHEN c.current_loan_balance > @THR_100B THEN N'Large Loan Customer'
            WHEN c.total_relationship_value > @THR_100B THEN N'Large Relationship'
            WHEN c.total_relationship_value > @THR_10B THEN N'High Relationship'
            WHEN c.total_relationship_value > @THR_5B THEN N'Medium Relationship'
            WHEN c.total_relationship_value > @THR_1B THEN N'Low Relationship'
            WHEN c.total_relationship_value > @THR_100M THEN N'Mass Relationship'
            ELSE N'Very Low Relationship'
        END AS value_segment,

        /* 2. Relationship segment */
        CASE
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance = 0 THEN N'Deposit Only'
            WHEN c.current_deposit_balance = 0 AND c.current_loan_balance > 0 THEN N'Loan Only'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio <= 0.20 THEN N'Balanced Relationship'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share >= 0.60 AND c.loan_share > 0 THEN N'Liquidity Surplus Customer'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share > 0 AND c.loan_share >= 0.90 THEN N'Leverage-Oriented Customer'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 THEN N'Dual Relationship'
            ELSE N'No Financial Relationship'
        END AS relationship_segment,

        /* 3. Product segment */
        CASE
        -- REMOVED DEEP MULTI-PRODUCT RELATIONSHIP GROUP
            WHEN c.num_product_group >= 3 AND c.num_products >= 4 THEN N'Multi-Product Relationship'
            WHEN c.num_product_group = 1 AND c.num_products <= 2 THEN N'Single Product Group Customer'
            WHEN c.num_product_group <= 2 AND c.num_products >= 3 THEN N'Shallow Product Group Customer'
            WHEN c.num_product_group = 0 OR c.num_products = 0 THEN N'No Product Customer'
            ELSE N'Standard Relationship'
        END AS product_segment,

        /* 4. Life cycle segment */
        CASE
            WHEN c.num_active_accounts = 0 THEN N'Closed Account'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days <= 90 THEN N'New to Bank'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days BETWEEN 91 AND 365 THEN N'Forming Relationship'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND (ISNULL(c.avg_deposit_balance_365d, 0) + ISNULL(c.avg_loan_balance_365d, 0)) = 0 THEN N'Dormant Relationship'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 1.20 THEN N'Growing'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.85 THEN N'Stable / Maintaining'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.50 THEN N'Shrinking'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio < 0.50 THEN N'Sharply Declining'
            ELSE N'Undetermined'
        END AS life_cycle_segment,

        /* 5. Risk segment */
        CASE 
            WHEN c.worst_debt_group >= 3 OR c.risk_score < 491 THEN N'High Risk Identified' 
            WHEN c.risk_score IS NULL THEN N'No Risk Score' 
            ELSE N'Low Risk Identified' 
        END AS risk_flag,

        CASE 
            WHEN c.total_relationship_value >= @THR_10B THEN N'High Value Identified'
            ELSE N'Low Value Identified' 
        END AS value_flag,

        CASE
            WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value >= @THR_10B THEN N'High Value - High Risk'
            WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value < @THR_10B THEN N'Low Value - High Risk'
            WHEN (ISNULL(c.worst_debt_group, 0) < 3 AND c.risk_score >= 491) AND c.total_relationship_value >= @THR_10B THEN N'High Value - Low Risk'
            WHEN c.risk_score IS NULL THEN N'Unscored Risk'
            ELSE N'Low Value - Low Risk'
        END AS risk_segment
    FROM calc c
),
final_segmented AS (
    SELECT s.*,
        CASE
            /* =========================================================================
               GROUP 1: RISK MANAGEMENT (Highest priority to protect capital)
               ========================================================================= */

            /* --- MINOR UNSECURED LOAN WARNING CONTROL: PRIORITY 1 ---
               Reason: Just having a loan and belonging to debt group >= 3 requires bad debt provisioning, regardless of collateral.
             */
            WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = N'High Value - High Risk' AND s.has_collateral_loan = 0) THEN 1

            /* --- RISK GROUP REQUIRING EXTENSION/ADDITIONAL LOAN EVALUATION: PRIORITY 2 ---
               Reason: Might have good repayment history (debt group 1, 2) but high risk score requires segmentation to determine if extension/extra loan/higher interest rate is needed, and no collateral.
             */
            WHEN s.current_loan_balance > 0 
                AND s.has_collateral_loan = 0
                AND s.risk_flag = N'High Risk Identified' -- Risk alert system (Low risk score or bad external CIC)
                THEN 2

            /* --- HIGH VALUE - HIGH RISK CUSTOMERS WITH COLLATERAL: PRIORITY 3 ---
               Reason: Purpose is to periodically check legal status and revalue collateral for large borrowers to avoid default or late payment risks. And to provision for bad debts immediately if needed.
             */
            WHEN s.risk_segment = N'High Value - High Risk' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN 3

            
            /* --- OTHER POTENTIAL RISK GROUPS: PRIORITY 4 & 5 --- 
                Reason: Customers who haven't borrowed here but might have borrowed elsewhere need assessment on whether to lend. Customers who borrowed here but paid off and still in high risk group also need assessment for new loans. Purpose: closer review for lending, or lend with low limit, high interest rate, and restrict loan product marketing to this group.
                Group 4: Used deposit products but shouldn't be marketed loan products due to risk, or needs careful appraisal before selling loans.
                Group 5: Currently no loans and no deposits. Can market deposit products and restrict loan product marketing.
            */
            WHEN s.risk_flag = N'High Risk Identified' AND current_loan_balance = 0 AND s.relationship_segment IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN 4
            WHEN s.risk_flag = N'High Risk Identified' AND current_loan_balance = 0 AND s.relationship_segment NOT IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN 5

            /* =========================================================================
               GROUP 2: VIP / HIGH VALUE CUSTOMERS (Low Risk - Priority 6 to 8)
               ========================================================================= */

            /* --- VIP POOL PROTECTION (FALSE ALARM FIX): PRIORITY 6 ---
               Reason: Account closure (num_closed_accounts_90d > 0) must be accompanied by 
               asset decline trend (relationship_trend_ratio < 0.95) to trigger alarm.
               Prevents VIPs from closing a junk credit card but depositing more money from being tagged as "capital withdrawal". */
            WHEN s.value_flag = N'High Value Identified' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN (N'Shrinking', N'Sharply Declining') OR (s.num_closed_accounts_90d > 0 AND ISNULL(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = N'Low Risk Identified' THEN 6
            
            /* --- VIP EXPANSION AND COMPREHENSIVE STRATEGY: PRIORITY 7 AND 8 --- */
            WHEN s.value_flag = N'High Value Identified' AND s.num_active_accounts > 0 AND s.product_segment IN (N'Single Product Group Customer', N'Shallow Product Group Customer') AND s.risk_flag = N'Low Risk Identified' THEN 7
            WHEN s.value_flag = N'High Value Identified' THEN 8


            /* =========================================================================
               GROUP 3: NEW CUSTOMERS & DEVELOPMENT POTENTIAL (Priority 9 to 12)
               ========================================================================= */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'New to Bank', N'Forming Relationship') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = N'Low Risk Identified' THEN 9
            WHEN s.num_active_accounts > 0 AND s.product_segment IN (N'Single Product Group Customer', N'Shallow Product Group Customer') AND s.risk_flag = N'Low Risk Identified' THEN 10
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Forming Relationship' AND s.product_segment = N'No Product Customer' AND s.risk_flag = N'Low Risk Identified' THEN 11

            /* --- PRIORITY 11: HAS ACCOUNT BUT NOT USING PRODUCTS ---
            Reason: Has active account (e.g. payroll) but hasn't used any deposit/loan products. This group needs approach to activate product usage. */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'New to Bank', N'Forming Relationship') AND s.risk_flag = N'Low Risk Identified' THEN 12


            /* =========================================================================
               GROUP 4: MATURE CUSTOMERS & SPECIFIC BEHAVIORS (Priority 13 to 17)
               ========================================================================= */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Growing' THEN 13
            WHEN s.num_active_accounts > 0 AND s.product_segment = N'Multi-Product Relationship' THEN 14
            WHEN s.num_active_accounts > 0 AND s.relationship_segment = N'Balanced Relationship' THEN 15
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN 16
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Loan Only', N'Leverage-Oriented Customer') THEN 17

            /* =========================================================================
               GROUP 5: INACTIVE / DORMANT CUSTOMERS (Priority 18 & 19)
               ========================================================================= */

            /* --- MISMATCH FIX SYNCHRONIZATION ---
               Reason: Group 18: accounts and customer status are still active, just haven't used products for a long time. Customers with long-term relationships (> 1 year) can be promoted.
               Group 19: customer status is inactive - customer is no longer active
             */
            WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = N'Dormant Relationship' THEN 18
            WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = N'Dormant Relationship' THEN 19

            /* --- BOTTOM OF FUNNEL MASS CUSTOMERS --- */
            ELSE 20
        END AS final_segmentation_priority,

        CASE
            /* IMPORTANT NOTE: This string-generating CASE block must strictly follow the  
               exact same condition structure (Line-by-Line Symmetry) as the number-generating CASE block above.
               Any mistake in row order here will result in segment name misalignment. */
               
            WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = N'High Value - High Risk' AND s.has_collateral_loan = 0) THEN N'Risk - Needs Bad Debt Provision' 
            WHEN s.current_loan_balance > 0 AND s.has_collateral_loan = 0 AND s.risk_flag = N'High Risk Identified' THEN N'Risk - Needs Re-appraisal'
            WHEN s.risk_segment = N'High Value - High Risk' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN N'Risk with Collateral - Needs Control'
            WHEN s.risk_flag = N'High Risk Identified' AND current_loan_balance = 0 AND s.relationship_segment IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN N'Potential Risk - Deposit Customer'
            WHEN s.risk_flag = N'High Risk Identified' AND current_loan_balance = 0 AND s.relationship_segment NOT IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN N'Potential Risk - No Product Relationship'

            WHEN s.value_flag = N'High Value Identified' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN (N'Shrinking', N'Sharply Declining') OR (s.num_closed_accounts_90d > 0 AND ISNULL(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = N'Low Risk Identified' THEN N'High Value Customer - Needs Retention'
            WHEN s.value_flag = N'High Value Identified' AND s.num_active_accounts > 0 AND s.product_segment IN (N'Single Product Group Customer', N'Shallow Product Group Customer') AND s.risk_flag = N'Low Risk Identified' THEN N'High Value Customer - Needs Relationship Expansion'
            WHEN s.value_flag = N'High Value Identified' THEN N'Stable High Value Customer'

            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'New to Bank', N'Forming Relationship') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = N'Low Risk Identified' THEN N'High Potential New Customer'
            WHEN s.num_active_accounts > 0 AND s.product_segment IN (N'Single Product Group Customer', N'Shallow Product Group Customer') AND s.risk_flag = N'Low Risk Identified' THEN N'Cross-sell Potential Customer'
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Forming Relationship' AND s.product_segment = N'No Product Customer' AND s.risk_flag = N'Low Risk Identified' THEN N'Passive Customer - No Product Used'
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'New to Bank', N'Forming Relationship') AND s.risk_flag = N'Low Risk Identified' THEN N'New Customer - Building Relationship'

            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Growing' THEN N'Mature Customer' 
            WHEN s.num_active_accounts > 0 AND s.product_segment = N'Multi-Product Relationship' THEN N'Deep Relationship Customer - Needs Maintenance'
            WHEN s.num_active_accounts > 0 AND s.relationship_segment = N'Balanced Relationship' THEN N'Stable Balanced Relationship Customer' 
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Deposit Only', N'Liquidity Surplus Customer') THEN N'Deposit-Leaning Customer'
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Loan Only', N'Leverage-Oriented Customer') THEN N'Loan-Leaning Customer'

            WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = N'Dormant Relationship' THEN N'Dormant Relationship Customer'
            WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = N'Dormant Relationship' THEN N'Closed / Inactive'
            ELSE N'Base Customer / Standard Relationship'
        END AS final_segmentation
    FROM segments s
)

SELECT * INTO #CustomerSegments FROM final_segmented;

-- REPORT 1: SUMMARY (DISTRIBUTION CHECK)
SELECT 
    final_segmentation,
    final_segmentation_priority,
    COUNT(*) AS num_customers,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS pct
FROM #CustomerSegments
GROUP BY final_segmentation, final_segmentation_priority
ORDER BY final_segmentation_priority;

SELECT
fs.as_of_date,
fs.CIF,
fs.ten_khach_hang,
fs.ma_phan_khuc,
fs.ten_phan_khuc,
fs.loai_phan_khuc,
fs.phan_loai,
fs.ten_quan,
fs.nhom_tuoi,
fs.nghe_nghiep,
fs.trang_thai,

    /* Base metrics */
fs.risk_score,
fs.worst_debt_group,
fs.current_deposit_balance,
fs.avg_deposit_balance_90d,
fs.avg_deposit_balance_365d,
fs.current_loan_balance,
fs.avg_loan_balance_90d,
fs.avg_loan_balance_365d,

fs.total_relationship_value,
fs.net_position,
fs.balance_ratio,
fs.deposit_share,
fs.loan_share,

fs.num_deposit_accounts,
fs.num_loan_accounts,
fs.num_products,
fs.num_product_group,

fs.first_relationship_date,
fs.relationship_tenure_days,
fs.num_active_accounts,
fs.num_closed_accounts_90d,

fs.deposit_trend_ratio,
fs.loan_trend_ratio,
fs.relationship_trend_ratio,

--     /* Segments by perspective */
fs.value_segment,
fs.relationship_segment,
fs.product_segment,
fs.life_cycle_segment,
fs.risk_flag,
fs.value_flag,
fs.risk_segment,
fs.has_collateral_loan,

--     /* Final segment */
fs.final_segmentation_priority,
fs.final_segmentation

FROM #CustomerSegments fs
ORDER BY
fs.final_segmentation_priority,
fs.total_relationship_value DESC,
fs.risk_score DESC,
fs.CIF;

DROP TABLE #CustomerSegments;
