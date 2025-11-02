{{ config(
    materialized='table',
    schema='prod'
) }}

WITH enriched_articles AS (
    SELECT * FROM {{ ref('int_articles_categorized') }}
)

SELECT
    ARTICLE_ID,
    SOURCE_NAME,
    SOURCE_TYPE,
    TITLE,
    CONTENT,
    URL,
    AUTHOR,
    CONTENT_LENGTH AS WORD_COUNT,
    
    SENTIMENT_SCORE,
    SENTIMENT_CATEGORY,
    POSITIVE_WORDS,
    NEGATIVE_WORDS,
    
    TOPIC,
    
    PUBLISHED_TIMESTAMP,
    COLLECTED_TIMESTAMP,
    CURRENT_TIMESTAMP() AS PROCESSED_TIMESTAMP
    
FROM enriched_articles