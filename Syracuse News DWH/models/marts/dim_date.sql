{{ config(
    materialized='table',
    schema='prod'
) }}

WITH date_range AS (
    SELECT 
        DATEADD(DAY, SEQ4(), '2023-01-01'::DATE) AS DATE_DAY
    FROM TABLE(GENERATOR(ROWCOUNT => 1826))  -- 5 years
),

date_details AS (
    SELECT
        TO_NUMBER(TO_CHAR(DATE_DAY, 'YYYYMMDD')) AS DATE_KEY,
        DATE_DAY AS FULL_DATE,
        YEAR(DATE_DAY) AS YEAR,
        QUARTER(DATE_DAY) AS QUARTER,
        MONTH(DATE_DAY) AS MONTH,
        TO_CHAR(DATE_DAY, 'MMMM') AS MONTH_NAME,
        WEEK(DATE_DAY) AS WEEK,
        DAY(DATE_DAY) AS DAY,
        DAYOFWEEK(DATE_DAY) AS DAY_OF_WEEK,
        TO_CHAR(DATE_DAY, 'DY') AS DAY_NAME,
        CASE WHEN DAYOFWEEK(DATE_DAY) IN (0, 6) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY,
        CASE 
            WHEN MONTH(DATE_DAY) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(DATE_DAY) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(DATE_DAY) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END AS SEASON
    FROM date_range
)

SELECT * FROM date_details