{{
    config(
        materialized='ephemeral'
    )
}}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['tag_type', 'tagged_by']) }} AS tag_key,
    tag_type,
    tagged_by,
    tag_weight_g,
    
    -- Quality metrics
    AVG(tag_battery_level_percent) AS avg_battery_level,
    AVG(signal_strength_db) AS avg_signal_strength,
    
    -- Performance stats - CORRECTED VALUES
    COUNT(*) AS total_deployments,
    SUM(CASE WHEN tracking_quality = 'Excellent' THEN 1 ELSE 0 END) AS excellent_quality_tracks,
    SUM(CASE WHEN tracking_quality = 'Good' THEN 1 ELSE 0 END) AS good_quality_tracks,
    SUM(CASE WHEN tracking_quality = 'Fair' THEN 1 ELSE 0 END) AS fair_quality_tracks,
    SUM(CASE WHEN tracking_quality = 'Poor' THEN 1 ELSE 0 END) AS poor_quality_tracks
    
FROM {{ ref('stg_bird_migration') }}
GROUP BY tag_type, tagged_by, tag_weight_g