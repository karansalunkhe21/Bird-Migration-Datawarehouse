{{ config(
    materialized='table',
    schema='prod'
) }}

SELECT
    ROW_NUMBER() OVER (ORDER BY TOPIC_NAME) AS TOPIC_KEY,
    TOPIC_NAME,
    KEYWORDS
FROM (
    SELECT 'Crime' AS TOPIC_NAME, 'crime|police|arrest|shooting' AS KEYWORDS
    UNION ALL SELECT 'Sports', 'basketball|football|syracuse orange'
    UNION ALL SELECT 'Weather', 'snow|storm|weather|blizzard'
    UNION ALL SELECT 'Education', 'school|student|university'
    UNION ALL SELECT 'Housing', 'housing|rent|apartment'
    UNION ALL SELECT 'Infrastructure', 'road|bridge|construction|i-81'
    UNION ALL SELECT 'Business', 'business|restaurant|economy'
    UNION ALL SELECT 'Government', 'mayor|council|government'
    UNION ALL SELECT 'Health', 'health|hospital|medical'
    UNION ALL SELECT 'Environment', 'lake|pollution|environment'
    UNION ALL SELECT 'General', 'news|syracuse|local'
)