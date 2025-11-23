{{
    config(
        materialized='table',
        tags=['analytics', 'reporting']
    )
}}

SELECT
    t.tag_type,
    t.tagged_by,
    
    -- Deployment metrics
    COUNT(DISTINCT f.migration_key) AS total_deployments,
    COUNT(DISTINCT f.bird_id) AS birds_tracked,
    COUNT(DISTINCT b.bird_key) AS species_tracked,
    
    -- Quality metrics
    ROUND(AVG(f.tag_battery_level_percent), 2) AS avg_battery_level,
    ROUND(AVG(f.signal_strength_db), 2) AS avg_signal_strength,
    
    -- Tracking quality distribution - CORRECTED VALUES
    ROUND(AVG(CASE WHEN f.tracking_quality = 'Excellent' THEN 1.0 ELSE 0.0 END) * 100, 2) AS excellent_quality_percent,
    ROUND(AVG(CASE WHEN f.tracking_quality = 'Good' THEN 1.0 ELSE 0.0 END) * 100, 2) AS good_quality_percent,
    ROUND(AVG(CASE WHEN f.tracking_quality = 'Fair' THEN 1.0 ELSE 0.0 END) * 100, 2) AS fair_quality_percent,
    ROUND(AVG(CASE WHEN f.tracking_quality = 'Poor' THEN 1.0 ELSE 0.0 END) * 100, 2) AS poor_quality_percent,
    
    -- Success correlation
    ROUND(AVG(CASE WHEN f.migration_success = 'SUCCESSFUL' THEN 1.0 ELSE 0.0 END) * 100, 2) AS migration_success_rate,
    
    -- Recovery metrics
    ROUND(AVG(CASE WHEN f.recovery_location_known THEN 1.0 ELSE 0.0 END) * 100, 2) AS recovery_rate_percent,
    ROUND(AVG(f.observation_counts), 1) AS avg_observations_per_migration
    
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_tracking') }} t ON f.tag_key = t.tag_key
INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key

GROUP BY t.tag_type, t.tagged_by
ORDER BY total_deployments DESC
