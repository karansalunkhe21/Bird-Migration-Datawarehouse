{{
    config(
        materialized='table',
        tags=['analytics']
    )
}}

SELECT
    t.tag_type,
    t.tagged_by,
    COUNT(DISTINCT f.migration_key) AS total_deployments,
    ROUND(AVG(f.tag_battery_level_percent), 2) AS avg_battery_level,
    ROUND(AVG(f.signal_strength_db), 2) AS avg_signal_strength,
    ROUND(AVG(CASE WHEN f.tracking_quality = 'High' THEN 1.0 ELSE 0.0 END) * 100, 2) AS high_quality_percent,
    ROUND(AVG(CASE WHEN f.migration_success = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS migration_success_rate
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_tracking') }} t ON f.tag_key = t.tag_key
GROUP BY t.tag_type, t.tagged_by