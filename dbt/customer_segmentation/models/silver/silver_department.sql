{{ config(materialized='table') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(ma_phong_ban)), '') AS department_id,
        NULLIF(LTRIM(RTRIM(ten_phong_ban)), '') AS department_name_source
    FROM {{ ref('bronze_department') }}
)

SELECT
    department_id,
    CASE department_name_source
        WHEN N'CN Thành phố Hồ Chí Minh' THEN N'Ho Chi Minh City Branch'
        WHEN N'PGD Khu vực 1' THEN N'Area 1 Transaction Office'
        WHEN N'PGD Khu vực 2' THEN N'Area 2 Transaction Office'
        WHEN N'PGD Khu vực 3' THEN N'Area 3 Transaction Office'
        WHEN N'PGD Khu vực 4' THEN N'Area 4 Transaction Office'
        WHEN N'PGD Khu vực 5' THEN N'Area 5 Transaction Office'
        WHEN N'PGD Khu vực 6' THEN N'Area 6 Transaction Office'
        WHEN N'Phòng Bán lẻ' THEN N'Retail Banking Department'
        WHEN N'Phòng Hỗ trợ tín dụng' THEN N'Credit Support Department'
        WHEN N'Phòng KHDN FDI' THEN N'FDI Corporate Banking Department'
        WHEN N'Phòng KHDN Lớn' THEN N'Large Corporate Banking Department'
        WHEN N'Phòng KHDN Siêu Lớn' THEN N'Very Large Corporate Banking Department'
        WHEN N'Phòng KHDN Vừa & Nhỏ' THEN N'Small and Medium Enterprise Banking Department'
        WHEN N'Phòng Kế Toán Tài Chính' THEN N'Finance and Accounting Department'
        WHEN N'Phòng Ngân hàng giao dịch' THEN N'Transaction Banking Department'
        WHEN N'Phòng Tổ Chức Hành chính' THEN N'Organization and Administration Department'
        WHEN N'Phòng Tổng hợp' THEN N'General Affairs Department'
        WHEN N'Phòng dịch vụ khách hàng' THEN N'Customer Service Department'
        ELSE department_name_source
    END AS department_name
FROM cleaned_source