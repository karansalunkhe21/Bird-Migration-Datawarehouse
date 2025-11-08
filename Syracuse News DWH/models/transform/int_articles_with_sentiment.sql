{{ config(
    materialized='table',
    schema='transform'
) }}

WITH articles AS (
    SELECT * FROM {{ ref('stg_articles_cleaned') }}
),

sentiment_analysis AS (
    SELECT 
        ARTICLE_ID,
        LOWER(CONCAT(TITLE, ' ', CONTENT)) AS FULL_TEXT,
        
        REGEXP_COUNT(FULL_TEXT, 
            'good|great|excellent|happy|positive|success|win|best|love|wonderful|amazing'
        ) AS POSITIVE_WORDS,
        
        REGEXP_COUNT(FULL_TEXT, 
            'bad|terrible|awful|negative|fail|worst|hate|crime|death|shooting|robbery|arrest'
        ) AS NEGATIVE_WORDS,
        
        CASE 
            WHEN (POSITIVE_WORDS + NEGATIVE_WORDS) = 0 THEN 0
            ELSE (POSITIVE_WORDS - NEGATIVE_WORDS) * 1.0 / 
                 NULLIF((POSITIVE_WORDS + NEGATIVE_WORDS), 0)
        END AS SENTIMENT_SCORE,
        
        CASE
            WHEN SENTIMENT_SCORE >= 0.2 THEN 'positive'
            WHEN SENTIMENT_SCORE <= -0.2 THEN 'negative'
            ELSE 'neutral'
        END AS SENTIMENT_CATEGORY
        
    FROM articles
)

-- Join to keep ALL original columns
SELECT 
    a.*,  -- This keeps all columns from staging
    s.SENTIMENT_SCORE,
    s.SENTIMENT_CATEGORY,
    s.POSITIVE_WORDS,
    s.NEGATIVE_WORDS
FROM articles a
LEFT JOIN sentiment_analysis s ON a.ARTICLE_ID = s.ARTICLE_ID