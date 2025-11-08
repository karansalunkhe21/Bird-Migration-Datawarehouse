{{ config(
    materialized='table',
    schema='transform'
) }}

WITH articles AS (
    SELECT * FROM {{ ref('int_articles_with_sentiment') }}
),

topic_detection AS (
    SELECT 
        ARTICLE_ID,
        LOWER(CONCAT(TITLE, ' ', CONTENT)) AS TEXT,
        
        CASE
            WHEN REGEXP_LIKE(TEXT, 'crime|police|arrest|shooting|robbery') THEN 'Crime'
            WHEN REGEXP_LIKE(TEXT, 'basketball|football|syracuse orange|sports') THEN 'Sports'
            WHEN REGEXP_LIKE(TEXT, 'snow|storm|weather|blizzard|winter') THEN 'Weather'
            WHEN REGEXP_LIKE(TEXT, 'school|student|university|education') THEN 'Education'
            WHEN REGEXP_LIKE(TEXT, 'housing|rent|apartment|landlord') THEN 'Housing'
            WHEN REGEXP_LIKE(TEXT, 'road|bridge|construction|i-81') THEN 'Infrastructure'
            WHEN REGEXP_LIKE(TEXT, 'business|restaurant|economy|jobs') THEN 'Business'
            WHEN REGEXP_LIKE(TEXT, 'mayor|council|government|politics') THEN 'Government'
            WHEN REGEXP_LIKE(TEXT, 'health|hospital|covid|medical') THEN 'Health'
            WHEN REGEXP_LIKE(TEXT, 'lake|pollution|environment') THEN 'Environment'
            ELSE 'General'
        END AS TOPIC
        
    FROM articles
)

-- Join to keep ALL original columns
SELECT 
    a.*,  -- This keeps all columns including SOURCE_NAME
    t.TOPIC
FROM articles a
LEFT JOIN topic_detection t ON a.ARTICLE_ID = t.ARTICLE_ID