{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

WITH months AS (
    SELECT 1 AS month_number UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL
    SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
)

SELECT
    month_number AS date_key,
    month_number,
    CASE month_number
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March' WHEN 4 THEN 'April'
        WHEN 5 THEN 'May' WHEN 6 THEN 'June' WHEN 7 THEN 'July' WHEN 8 THEN 'August'
        WHEN 9 THEN 'September' WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END AS month_name,
    CASE 
        WHEN month_number IN (12, 1, 2) THEN 'Winter'
        WHEN month_number IN (3, 4, 5) THEN 'Spring'
        WHEN month_number IN (6, 7, 8) THEN 'Summer'
        WHEN month_number IN (9, 10, 11) THEN 'Fall'
    END AS season,
    CASE 
        WHEN month_number IN (3, 4, 5) THEN 'Spring Migration'
        WHEN month_number IN (8, 9, 10) THEN 'Fall Migration'
        ELSE 'Non-Migration'
    END AS migration_season,
    month_number IN (3, 4, 5, 8, 9, 10) AS is_peak_migration_month
FROM months