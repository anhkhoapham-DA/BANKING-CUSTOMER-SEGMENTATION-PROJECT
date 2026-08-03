DECLARE @as_of_date DATE;

DECLARE @THR_100B DECIMAL(19,2) = 100000000000.00; -- 100 tỷ
DECLARE @THR_10B  DECIMAL(19,2) = 10000000000.00;  -- 10 tỷ
DECLARE @THR_5B   DECIMAL(19,2) = 5000000000.00;   -- 5 tỷ
DECLARE @THR_1B   DECIMAL(19,2) = 1000000000.00;   -- 1 tỷ
DECLARE @THR_100M DECIMAL(19,2) = 100000000.00;    -- 100 triệu

-- Dùng ngày snapshot cuối cùng chung giữa tiền gửi và dư nợ
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
        COUNT(DISTINCT tn.so_tai_khoan)           AS so_luong_tk_vay_lich_su, 
        MAX(ISNULL(fdn.nhom_no, 0))               AS worst_debt_group
    FROM dbo.tk_no tn
    LEFT JOIN dbo.fact_du_no fdn ON tn.so_tai_khoan = fdn.so_tai_khoan AND fdn.ngay = @as_of_date
    GROUP BY tn.CIF
),
collateral_check AS (
    SELECT tn.CIF,
        MAX(CASE WHEN tn.ma_san_pham NOT IN (5501, 5502, 5528, 6000, 6300) THEN 1 ELSE 0 END) AS has_collateral_loan -- mã sản phẩm tín chấp hoặc vay tiêu dùng không có TSĐB
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

        /* 1. Value segment */
        CASE
            WHEN c.current_deposit_balance > @THR_100B AND c.current_loan_balance > @THR_100B THEN N'Quan hệ kép lớn'
            WHEN c.current_deposit_balance > @THR_100B THEN N'KH gửi tiền giá trị lớn'
            WHEN c.current_loan_balance > @THR_100B THEN N'KH vay giá trị lớn'
            WHEN c.total_relationship_value > @THR_100B THEN N'Quan hệ lớn'
            WHEN c.total_relationship_value > @THR_10B THEN N'Quan hệ cao'
            WHEN c.total_relationship_value > @THR_5B THEN N'Quan hệ trung bình'
            WHEN c.total_relationship_value > @THR_1B THEN N'Quan hệ thấp'
            WHEN c.total_relationship_value > @THR_100M THEN N'Quan hệ đại trà'
            ELSE N'Quan hệ rất thấp'
        END AS value_segment,

        /* 2. Relationship segment */
        CASE
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance = 0 THEN N'Chỉ tiền gửi'
            WHEN c.current_deposit_balance = 0 AND c.current_loan_balance > 0 THEN N'Chỉ vay'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio <= 0.20 THEN N'Quan hệ cân bằng'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share >= 0.60 AND c.loan_share > 0 THEN N'KH thặng dư thanh khoản'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 AND c.balance_ratio > 0.20 AND c.deposit_share > 0 AND c.loan_share >= 0.90 THEN N'KH thiên đòn bẩy'
            WHEN c.current_deposit_balance > 0 AND c.current_loan_balance > 0 THEN N'Quan hệ kép'
            ELSE N'Chưa có quan hệ tài chính'
        END AS relationship_segment,

        /* 3. Product segment */
        CASE
        -- ĐÃ BỎ NHÓM QUAN HỆ SÂU ĐA SẢN PHẨM
            WHEN c.num_product_group >= 3 AND c.num_products >= 4 THEN N'Quan hệ đa sản phẩm'
            WHEN c.num_product_group = 1 AND c.num_products <= 2 THEN N'KH một nhóm sản phẩm'
            WHEN c.num_product_group <= 2 AND c.num_products >= 3 THEN N'KH có sản phẩm nhưng nông nhóm'
            WHEN c.num_product_group = 0 OR c.num_products = 0 THEN N'KH chưa có sản phẩm'
            ELSE N'Quan hệ chuẩn'
        END AS product_segment,

        /* 4. Life cycle segment */
        CASE
            WHEN c.num_active_accounts = 0 THEN N'Đã đóng tài khoản'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days <= 90 THEN N'Mới đến ngân hàng'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days BETWEEN 91 AND 365 THEN N'Đang hình thành quan hệ'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND (ISNULL(c.avg_deposit_balance_365d, 0) + ISNULL(c.avg_loan_balance_365d, 0)) = 0 THEN N'Quan hệ ngủ đông'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 1.20 THEN N'Đang tăng trưởng'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.85 THEN N'Ổn định / duy trì'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio >= 0.50 THEN N'Đang thu hẹp'
            WHEN c.num_active_accounts > 0 AND c.relationship_tenure_days > 365 AND c.relationship_trend_ratio < 0.50 THEN N'Suy giảm mạnh'
            ELSE N'Chưa xác định'
        END AS life_cycle_segment,

        /* 5. Risk segment */
        CASE 
            WHEN c.worst_debt_group >= 3 OR c.risk_score < 491 THEN N'Xác định rủi ro cao' 
            WHEN c.risk_score IS NULL THEN N'Chưa có điểm rủi ro' 
            ELSE N'Xác định rủi ro thấp' 
        END AS risk_flag,

        CASE 
            WHEN c.total_relationship_value >= @THR_10B THEN N'Xác định giá trị cao'
            ELSE N'Xác định giá trị thấp' 
        END AS value_flag,

        CASE
            WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value >= @THR_10B THEN N'Giá trị cao - Rủi ro cao'
            WHEN (c.worst_debt_group >= 3 OR c.risk_score < 491) AND c.total_relationship_value < @THR_10B THEN N'Giá trị thấp - Rủi ro cao'
            WHEN (ISNULL(c.worst_debt_group, 0) < 3 AND c.risk_score >= 491) AND c.total_relationship_value >= @THR_10B THEN N'Giá trị cao - Rủi ro thấp'
            WHEN c.risk_score IS NULL THEN N'Chưa chấm điểm rủi ro'
            ELSE N'Giá trị thấp - Rủi ro thấp'
        END AS risk_segment
    FROM calc c
),
final_segmented AS (
    SELECT s.*,
        CASE
            /* =========================================================================
               CỤM 1: QUẢN TRỊ RỦI RO (Ưu tiên cao nhất để bảo vệ an toàn vốn)
               ========================================================================= */

            /* --- KHỐNG CHẾ CẢNH BÁO TÍN CHẤP LẶT VẶT: ƯU TIÊN SỐ 1 ---
               Lý do: chỉ cần vay và thuộc nhóm nợ trên 3 đều cần được lập dự phòng nợ xấu, bất kể có TSĐB hay không.
               . */
            WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = N'Giá trị cao - Rủi ro cao' AND s.has_collateral_loan = 0) THEN 1

            /* --- NHÓM RUỈ RO CẦN ĐÁNH GIÁ GIA HẠN/VAY THÊM: ƯU TIÊN SỐ 2 ---
               Lý do: có thể có lịch sự trả nợ tốt (nhóm nợ 1, 2) nhưng mà risk score cao thì cần được phân chia để xác định có nên cho gia hạn thêm/vay thêm/điều chỉnh lãi suất cao hơn
               và không có TSĐB.
             */
            WHEN s.current_loan_balance > 0 
                AND s.has_collateral_loan = 0
                AND s.risk_flag = N'Xác định rủi ro cao' -- Hệ thống báo rủi ro (Risk score thấp hoặc CIC ngoài xấu)
                THEN 2

            /* --- KH GIÁ TRỊ CAO - RỦI RO CAO CÓ TSĐB: ƯU TIÊN SỐ 3 ---
               Lý do: Mục đích để kiểm tra định kỳ tính pháp lý và định giá lại tài sản cho những KH vay nhiều để tránh rủi ro KH khất nợ hoặc trả chậm.
               Và nếu cần để lập dự phòng nợ xấu luôn.
             */
            WHEN s.risk_segment = N'Giá trị cao - Rủi ro cao' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN 3

            
            /* --- NHÓM RỦI RO TIỀM ẨN KHÁC: ƯU TIÊN SỐ 4 & 5 --- 
                Lý do: KH chưa từng vay ở NH này nhưng có thể đã từng vay ở NH khác cần được xem xét xem có nên cho vay không. KH đã từng vay ở NH này nhưng đã tất toán
                và vẫn nằm trong nhóm rủi ro cao cũng nên xem xét có nên cho vay mới không. Mục đích: cán bộ xem xét kĩ hơn có nên cho vay hoặc vay nhưng mà hạn mức thấp, lãi suất cao
                và không nên tiếp thị sản phẩm vay cho nhóm khách hàng này.
                Nhóm 4: KH đã sử dụng sản phẩm tiền gửi nhưng không nên tiếp thị sản phẩm vay vì rủi ro hoặc cần thẩm định kỹ trước khi bán sản phẩm vay.
                Nhóm 5: KH hiện không vay và cũng không dùng sản phẩm tiền gửi. Có thể tiếp thị sản phẩm tiền gửi và hạn chế tiếp thị sản phẩm vay.
            */
            WHEN s.risk_flag = N'Xác định rủi ro cao' AND current_loan_balance = 0 AND s.relationship_segment IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN 4
            WHEN s.risk_flag = N'Xác định rủi ro cao' AND current_loan_balance = 0 AND s.relationship_segment NOT IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN 5

            /* =========================================================================
               CỤM 2: KHÁCH HÀNG VIP / GIÁ TRỊ CAO (Rủi ro thấp - Ưu tiên số 6 đến 8)
               ========================================================================= */

            /* --- BẢO VỆ TỆP VIP (FALSE ALARM FIX): ƯU TIÊN SỐ 6 ---
               Lý do: Đóng tài khoản (num_closed_accounts_90d > 0) buộc phải đi kèm với 
               xu hướng sụt giảm tài sản (relationship_trend_ratio < 0.95) mới kích hoạt báo động.
               Tránh việc khách VIP đóng 1 cái thẻ tín dụng rác nhưng vẫn gửi thêm tiền mà bị gắn mác "rút vốn". */
            WHEN s.value_flag = N'Xác định giá trị cao' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN (N'Đang thu hẹp', N'Suy giảm mạnh') OR (s.num_closed_accounts_90d > 0 AND ISNULL(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = N'Xác định rủi ro thấp' THEN 6
            
            /* --- KHÁCH VIP MỞ RỘNG VÀ CHIẾN LƯỢC TOÀN DIỆN: ƯU TIÊN SỐ 7 VÀ 8 --- */
            WHEN s.value_flag = N'Xác định giá trị cao' AND s.num_active_accounts > 0 AND s.product_segment IN (N'KH một nhóm sản phẩm', N'KH có sản phẩm nhưng nông nhóm') AND s.risk_flag = N'Xác định rủi ro thấp' THEN 7
            WHEN s.value_flag = N'Xác định giá trị cao' THEN 8


            /* =========================================================================
               CỤM 3: KHÁCH HÀNG MỚI & TIỀM NĂNG PHÁT TRIỂN (Ưu tiên số 9 đến 12)
               ========================================================================= */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'Mới đến ngân hàng', N'Đang hình thành quan hệ') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = N'Xác định rủi ro thấp' THEN 9
            WHEN s.num_active_accounts > 0 AND s.product_segment IN (N'KH một nhóm sản phẩm', N'KH có sản phẩm nhưng nông nhóm') AND s.risk_flag = N'Xác định rủi ro thấp' THEN 10
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Đang hình thành quan hệ' AND s.product_segment = N'KH chưa có sản phẩm' AND s.risk_flag = N'Xác định rủi ro thấp' THEN 11

            /* --- ƯU TIÊN SỐ 11: KH CÓ TÀI KHOẢN NHƯNG CHƯA SỬ DỤNG SẢN PHẨM ---
            Lý do: Có tài khoản active (ví dụ TK thanh toán nhận lương) nhưng chưa sử dụng bất kỳ sản phẩm tiền gửi/vay nào. Đây là nhóm cần được tiếp cận để kích hoạt sử dụng sản phẩm. */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'Mới đến ngân hàng', N'Đang hình thành quan hệ') AND s.risk_flag = N'Xác định rủi ro thấp' THEN 12


            /* =========================================================================
               CỤM 4: KHÁCH HÀNG TRƯỞNG THÀNH & ĐẶC THÙ HÀNH VI (Ưu tiên số 13 đến 17)
               ========================================================================= */
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Đang tăng trưởng' THEN 13
            WHEN s.num_active_accounts > 0 AND s.product_segment = N'Quan hệ đa sản phẩm' THEN 14
            WHEN s.num_active_accounts > 0 AND s.relationship_segment = N'Quan hệ cân bằng' THEN 15
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN 16
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Chỉ vay', N'KH thiên đòn bẩy') THEN 17

            /* =========================================================================
               CỤM 5: KHÁCH HÀNG DỪNG HOẠT ĐỘNG / NGỦ ĐÔNG (Ưu tiên số 18 & 19)
               ========================================================================= */

            /* --- ĐỒNG BỘ MAPPING LỖI LỆCH PHA (MISMATCH FIX) ---
               Lý do: Nhóm 18: tài khoản và trạng thái KH còn active chỉ là đã lâu không sử dụng sản phẩm. KH có mối quan hệ lâu dài (> 1 năm) có thể thúc đẩy.
               Nhóm 19: trạng thái KH đã inactive - KH đã không còn hoạt động
             */
            WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = N'Quan hệ ngủ đông' THEN 18
            WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = N'Quan hệ ngủ đông' THEN 19

            /* --- ĐÁY PHỄU KHÁCH HÀNG ĐẠI TRÀ --- */
            ELSE 20
        END AS final_segmentation_priority,

        CASE
            /* GHI CHÚ QUAN TRỌNG: Khối CASE sinh tên này phải tuân thủ cấu trúc điều kiện 
               giống hệt 100% (Line-by-Line Symmetry) so với khối CASE sinh số ở trên.
               Bất kỳ sai sót nào về thứ tự dòng ở đây sẽ dẫn đến việc lệch tên phân khúc. */
               
            WHEN (s.current_loan_balance > 0 AND s.worst_debt_group >= 3) OR (s.current_loan_balance > 0 AND s.risk_segment = N'Giá trị cao - Rủi ro cao' AND s.has_collateral_loan = 0) THEN N'Rủi ro cần lập dự phòng nợ xấu' 
            WHEN s.current_loan_balance > 0 AND s.has_collateral_loan = 0 AND s.risk_flag = N'Xác định rủi ro cao' THEN N'Rủi ro cần giám định lại'
            WHEN s.risk_segment = N'Giá trị cao - Rủi ro cao' AND s.current_loan_balance > 0 AND s.has_collateral_loan = 1 THEN N'Rủi ro có TSĐB cần kiểm soát'
            WHEN s.risk_flag = N'Xác định rủi ro cao' AND current_loan_balance = 0 AND s.relationship_segment IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN N'Rủi ro tiềm ẩn - Khách tiền gửi'
            WHEN s.risk_flag = N'Xác định rủi ro cao' AND current_loan_balance = 0 AND s.relationship_segment NOT IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN N'Rủi ro tiềm ẩn - Chưa có quan hệ sản phẩm'

            WHEN s.value_flag = N'Xác định giá trị cao' AND s.num_active_accounts > 0 AND (s.life_cycle_segment IN (N'Đang thu hẹp', N'Suy giảm mạnh') OR (s.num_closed_accounts_90d > 0 AND ISNULL(s.relationship_trend_ratio, 1) < 0.95)) AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách giá trị cao cần giữ chân'
            WHEN s.value_flag = N'Xác định giá trị cao' AND s.num_active_accounts > 0 AND s.product_segment IN (N'KH một nhóm sản phẩm', N'KH có sản phẩm nhưng nông nhóm') AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách giá trị cao cần mở rộng quan hệ'
            WHEN s.value_flag = N'Xác định giá trị cao' THEN N'Khách giá trị cao ổn định'

            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'Mới đến ngân hàng', N'Đang hình thành quan hệ') AND (s.relationship_trend_ratio > 1.2 OR s.deposit_trend_ratio > 1.2 OR s.loan_trend_ratio > 1.2) AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách mới tiềm năng cao'
            WHEN s.num_active_accounts > 0 AND s.product_segment IN (N'KH một nhóm sản phẩm', N'KH có sản phẩm nhưng nông nhóm') AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách có tiềm năng bán chéo'
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Đang hình thành quan hệ' AND s.product_segment = N'KH chưa có sản phẩm' AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách thụ động - chưa sử dụng sản phẩm'
            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment IN (N'Mới đến ngân hàng', N'Đang hình thành quan hệ') AND s.risk_flag = N'Xác định rủi ro thấp' THEN N'Khách mới đang xây dựng quan hệ'

            WHEN s.num_active_accounts > 0 AND s.life_cycle_segment = N'Đang tăng trưởng' THEN N'Khách trưởng thành' 
            WHEN s.num_active_accounts > 0 AND s.product_segment = N'Quan hệ đa sản phẩm' THEN N'Khách quan hệ sâu cần duy trì'
            WHEN s.num_active_accounts > 0 AND s.relationship_segment = N'Quan hệ cân bằng' THEN N'Khách quan hệ cân bằng ổn định' 
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Chỉ tiền gửi', N'KH thặng dư thanh khoản') THEN N'Khách thiên tiền gửi'
            WHEN s.num_active_accounts > 0 AND s.relationship_segment IN (N'Chỉ vay', N'KH thiên đòn bẩy') THEN N'Khách thiên vay'

            WHEN s.trang_thai = 'Active' AND s.num_active_accounts > 0 AND s.life_cycle_segment = N'Quan hệ ngủ đông' THEN N'Khách quan hệ ngủ đông'
            WHEN (s.num_active_accounts = 0 AND s.current_deposit_balance = 0 AND s.current_loan_balance = 0) OR s.life_cycle_segment = N'Quan hệ ngủ đông' THEN N'Đã đóng / không hoạt động'
            ELSE N'Khách nền tảng / quan hệ chuẩn'
        END AS final_segmentation
    FROM segments s
)

-- SELECT * INTO #CustomerSegments FROM final_segmented;

-- BÁO CÁO 1: TỔNG HỢP (KIỂM TRA PHÂN BỔ)
SELECT 
    final_segmentation,
    final_segmentation_priority,
    COUNT(*) AS num_customers,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS pct
FROM #CustomerSegments
GROUP BY final_segmentation, final_segmentation_priority
ORDER BY final_segmentation_priority;

-- BÁO CÁO 2: DANH SÁCH CHI TIẾT DÀNH CHO RM (FULL DATA ĐỐI CHIẾU)
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

    /* Metric gốc */
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

--     /* Segment theo từng góc nhìn */
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
