{{ config(materialized='view') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(CAST(CAST(CIF AS DECIMAL(38, 0)) AS VARCHAR(50)))), '') AS customer_id,
        NULLIF(LTRIM(RTRIM(ten_khach_hang)), '') AS customer_name,
        NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '') AS segment_id_source,
        CASE NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '')
            -- CN09 is labeled "KHCN HANG ELITE" in master_khach_hang; CN07 is the matching Elite segment.
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
    FROM {{ source('banking', 'master_khach_hang') }}
)

SELECT
    customer_id,
    customer_name,
    customer.segment_id_source,
    customer.segment_id,
    customer_type_source,
    CASE customer_type_source
        WHEN N'Cá nhân' THEN N'Individual'
        WHEN N'Doanh nghiệp' THEN N'Business'
        ELSE customer_type_source
    END AS customer_type,
    date_of_birth,
    age_years,
    age_group,
    customer.district_name_source,
    COALESCE(region.district_name, customer.district_name_source) AS district_name,
    occupation_source,
    CASE occupation_source
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
        ELSE occupation_source
    END AS occupation,
    risk_score,
    customer_status
FROM cleaned_source AS customer
LEFT JOIN {{ ref('bronze_region') }} AS region
    ON customer.district_name_source = region.district_name_source