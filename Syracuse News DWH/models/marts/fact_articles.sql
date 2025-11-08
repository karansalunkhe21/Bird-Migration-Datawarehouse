{{ config(
    materialized='table',
    schema='prod'
) }}

WITH enriched_articles AS (
    SELECT * FROM {{ ref('int_articles_categorized') }}
),

add_keys AS (
    SELECT
        a.*,
        
        -- Add dimension keys
        d.DATE_KEY,
        s.SOURCE_KEY,
        t.TOPIC_KEY
        
    FROM enriched_articles a
    LEFT JOIN {{ ref('dim_date') }} d 
        ON d.FULL_DATE = a.PUBLISHED_DATE
    LEFT JOIN {{ ref('dim_source') }} s 
        ON UPPER(s.SOURCE_NAME) = UPPER(a.SOURCE_NAME)
        AND s.IS_CURRENT = TRUE
    LEFT JOIN {{ ref('dim_topic') }} t 
        ON UPPER(t.TOPIC_NAME) = UPPER(a.TOPIC)
)

SELECT * FROM add_keys