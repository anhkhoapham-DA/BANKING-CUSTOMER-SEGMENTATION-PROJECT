{{ config(materialized='table') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(ma_can_bo)), '') AS staff_id,
        NULLIF(LTRIM(RTRIM(ten_can_bo)), '') AS staff_name,
        NULLIF(LTRIM(RTRIM(CAST(ma_phong_ban AS VARCHAR(50)))), '') AS department_id,
        NULLIF(LTRIM(RTRIM(gioi_tinh)), '') AS gender_source,
        NULLIF(LTRIM(RTRIM(chuc_vu)), '') AS job_title_source
    FROM {{ source('banking', 'master_can_bo') }}
)

SELECT
    staff_id,
    staff_name,
    staff.department_id,
    department.department_name,
    CASE gender_source
        WHEN N'Nam' THEN N'Male'
        WHEN N'Nữ' THEN N'Female'
        ELSE gender_source
    END AS gender,
    CASE job_title_source
        WHEN N'Chuyên viên hỗ trợ tín dụng' THEN N'Credit Support Specialist'
        WHEN N'Chuyên viên khách hàng cá nhân' THEN N'Personal Banking Specialist'
        WHEN N'Chuyên viên khách hàng doanh nghiệp' THEN N'Corporate Banking Specialist'
        WHEN N'Giao dịch viên' THEN N'Teller'
        WHEN N'Giám đốc chi nhánh' THEN N'Branch Director'
        WHEN N'Phó giám đốc chi nhánh' THEN N'Deputy Branch Director'
        WHEN N'Phó phòng' THEN N'Deputy Department Head'
        WHEN N'Trưởng phòng' THEN N'Department Head'
        ELSE job_title_source
    END AS job_title
FROM cleaned_source AS staff
LEFT JOIN {{ ref('silver_department') }} AS department
    ON staff.department_id = department.department_id