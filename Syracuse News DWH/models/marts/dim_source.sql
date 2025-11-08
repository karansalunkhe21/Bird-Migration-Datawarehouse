{{ config(
    materialized='table',
    schema='prod'
) }}

WITH unique_sources AS (
    SELECT DISTINCT
        SOURCE_NAME,
        SOURCE_TYPE
    FROM {{ ref('int_articles_categorized') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY SOURCE_NAME) AS SOURCE_KEY,
    SOURCE_NAME,
    SOURCE_TYPE,
    CURRENT_TIMESTAMP() AS EFFECTIVE_DATE,
    '2099-12-31'::DATE AS EXPIRATION_DATE,
    TRUE AS IS_CURRENT
FROM unique_sources