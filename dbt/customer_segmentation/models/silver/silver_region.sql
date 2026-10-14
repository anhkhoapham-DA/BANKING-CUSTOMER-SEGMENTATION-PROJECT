{{ config(materialized='table') }}

WITH cleaned_source AS (
    SELECT
        NULLIF(LTRIM(RTRIM(ten_quan)), '') AS district_name_source,
        CAST(dien_tich_km2 AS DECIMAL(10, 2)) AS area_sq_km,
        CAST(dan_so AS BIGINT) AS population,
        CAST(mat_do AS INT) AS population_density_per_sq_km,
        CAST(lat AS DECIMAL(9, 6)) AS latitude,
        CAST(long AS DECIMAL(9, 6)) AS longitude
    FROM {{ source('banking', 'master_khu_vuc') }}
)

SELECT
    district_name_source,
    CASE district_name_source
        WHEN N'Quận 1' THEN N'District 1'
        WHEN N'Quận 3' THEN N'District 3'
        WHEN N'Quận 4' THEN N'District 4'
        WHEN N'Quận 5' THEN N'District 5'
        WHEN N'Quận 6' THEN N'District 6'
        WHEN N'Quận 7' THEN N'District 7'
        WHEN N'Quận 8' THEN N'District 8'
        WHEN N'Quận 10' THEN N'District 10'
        WHEN N'Quận 11' THEN N'District 11'
        WHEN N'Quận 12' THEN N'District 12'
        WHEN N'Quận Bình Tân' THEN N'Binh Tan District'
        WHEN N'Quận Bình Thạnh' THEN N'Binh Thanh District'
        WHEN N'Quận Gò Vấp' THEN N'Go Vap District'
        WHEN N'Quận Phú Nhuận' THEN N'Phu Nhuan District'
        WHEN N'Quận Tân Bình' THEN N'Tan Binh District'
        WHEN N'Quận Tân Phú' THEN N'Tan Phu District'
        WHEN N'Thành phố Thủ Đức' THEN N'Thu Duc City'
        ELSE district_name_source
    END AS district_name,
    area_sq_km,
    population,
    population_density_per_sq_km,
    latitude,
    longitude
FROM cleaned_source