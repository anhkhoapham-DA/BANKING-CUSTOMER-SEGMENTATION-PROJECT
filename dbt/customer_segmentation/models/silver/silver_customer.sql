{{ config(materialized='table') }}

WITH raw_customer AS (
    SELECT * FROM {{ ref('bronze_customer') }}
),

cleaned_customer AS (
    SELECT
        NULLIF(LTRIM(RTRIM(CAST(CAST(CIF AS DECIMAL(38, 0)) AS VARCHAR(50)))), '') AS customer_id,
        NULLIF(LTRIM(RTRIM(ten_khach_hang)), '') AS customer_name,
        NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '') AS segment_id_source,
        CASE NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '')
            WHEN 'CN09' THEN 'CN07'
            ELSE NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '')
        END AS segment_id,
        NULLIF(LTRIM(RTRIM(phan_loai)), '') AS customer_type_source,
        CAST(ngay_sinh AS DATE) AS date_of_birth,
        CAST(tuoi AS INT) AS age_years,
        NULLIF(LTRIM(RTRIM(nhom_tuoi)), '') AS age_group,
        NULLIF(LTRIM(RTRIM(ten_quan)), '') AS district_name_source,
        NULLIF(LTRIM(RTRIM(nghe_nghiep)), '') AS occupation_source,
        CAST(diem_rui_ro AS INT) AS risk_score,
        NULLIF(LTRIM(RTRIM(trang_thai)), '') AS customer_status
    FROM raw_customer
),

translated_customer AS (
    SELECT
        c.*,
        CASE c.customer_type_source
            WHEN N'Cá nhân' THEN N'Individual'
            WHEN N'Doanh nghiệp' THEN N'Business'
            ELSE c.customer_type_source
        END AS customer_type,
        CASE c.occupation_source
            WHEN N'Bác sĩ' THEN N'Doctor'
            WHEN N'Chuyên viên tài chính' THEN N'Financial Specialist'
            WHEN N'Công chức nhà nước' THEN N'Government Employee'
            WHEN N'Giáo viên' THEN N'Teacher'
            WHEN N'Kinh doanh tự do' THEN N'Self-Employed Business Owner'
            WHEN N'Kỹ sư công nghệ thông tin' THEN N'Information Technology Engineer'
            WHEN N'Nhân viên văn phòng' THEN N'Office Employee'
            WHEN N'Nội trợ' THEN N'Homemaker'
            WHEN N'Sinh viên' THEN N'Student'
            WHEN N'Tài xế' THEN N'Driver'
            ELSE c.occupation_source
        END AS occupation
    FROM cleaned_customer c
)

SELECT
    tc.customer_id,
    tc.customer_name,
    tc.segment_id_source,
    tc.segment_id,
    seg.segment_name,
    seg.segment_type,
    tc.customer_type,
    COALESCE(reg.district_name, tc.district_name_source) AS district_name,
    tc.date_of_birth,
    tc.age_years,
    tc.age_group,
    tc.occupation,
    tc.risk_score,
    tc.customer_status
FROM translated_customer AS tc
LEFT JOIN {{ ref('silver_region') }} AS reg
    ON tc.district_name_source = reg.district_name_source
LEFT JOIN {{ ref('silver_customer_segment') }} AS seg
    ON tc.segment_id = seg.segment_id