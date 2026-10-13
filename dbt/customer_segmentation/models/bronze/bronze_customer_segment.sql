{{ config(materialized='view') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(ma_phan_khuc)), '') AS segment_id,
        NULLIF(LTRIM(RTRIM(loai_phan_lhuc)), '') AS segment_type_source
    FROM {{ source('banking', 'master_phan_khuc') }}
)

SELECT
    segment_id,
    CASE segment_id
        WHEN 'DN00' THEN N'Unclassified Corporate Segment'
        WHEN 'DN01' THEN N'Micro Enterprise'
        WHEN 'DN02' THEN N'Small Enterprise'
        WHEN 'DN03' THEN N'Medium Enterprise'
        WHEN 'DN04' THEN N'Medium and Small FDI Enterprises'
        WHEN 'DN05' THEN N'Cash-Intensive Corporate Customers'
        WHEN 'DN06' THEN N'State-Owned Corporation'
        WHEN 'DN07' THEN N'Large Enterprise'
        WHEN 'DN08' THEN N'Very Large Enterprise'
        WHEN 'DN09' THEN N'Large FDI Enterprise'
        WHEN 'CN01' THEN N'Mass Retail Customer'
        WHEN 'CN02' THEN N'Affluent Customer'
        WHEN 'CN03' THEN N'Gold Customer'
        WHEN 'CN04' THEN N'Platinum Customer'
        WHEN 'CN05' THEN N'Diamond Customer'
        WHEN 'CN06' THEN N'Diamond Plus Customer'
        WHEN 'CN07' THEN N'Elite Customer'
        ELSE NULL
    END AS segment_name,
    CASE segment_id
        WHEN 'DN00' THEN N'DN00 - Unclassified Corporate Segment'
        WHEN 'DN01' THEN N'DN01 - Micro Enterprise'
        WHEN 'DN02' THEN N'DN02 - Small Enterprise'
        WHEN 'DN03' THEN N'DN03 - Medium Enterprise'
        WHEN 'DN04' THEN N'DN04 - Medium and Small FDI Enterprises'
        WHEN 'DN05' THEN N'DN05 - Cash-Intensive Corporate Customers'
        WHEN 'DN06' THEN N'DN06 - State-Owned Corporation'
        WHEN 'DN07' THEN N'DN07 - Large Enterprise'
        WHEN 'DN08' THEN N'DN08 - Very Large Enterprise'
        WHEN 'DN09' THEN N'DN09 - Large FDI Enterprise'
        WHEN 'CN01' THEN N'CN01 - Mass Retail Customer'
        WHEN 'CN02' THEN N'CN02 - Affluent Customer'
        WHEN 'CN03' THEN N'CN03 - Gold Customer'
        WHEN 'CN04' THEN N'CN04 - Platinum Customer'
        WHEN 'CN05' THEN N'CN05 - Diamond Customer'
        WHEN 'CN06' THEN N'CN06 - Diamond Plus Customer'
        WHEN 'CN07' THEN N'CN07 - Elite Customer'
        ELSE NULL
    END AS segment_code_name,
    CASE segment_type_source
        WHEN N'Khách hàng cá nhân' THEN N'Individual Customer'
        WHEN N'Khách hàng doanh nghiệp' THEN N'Business Customer'
        ELSE segment_type_source
    END AS segment_type
FROM cleaned_source