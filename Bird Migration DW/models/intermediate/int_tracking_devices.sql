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
    
    AVG(tag_battery_level_percent) AS avg_battery_level,
    AVG(signal_strength_db) AS avg_signal_strength,
    
    COUNT(*) AS total_deployments,
    SUM(CASE WHEN tracking_quality = 'High' THEN 1 ELSE 0 END) AS high_quality_tracks,
    SUM(CASE WHEN tracking_quality = 'Medium' THEN 1 ELSE 0 END) AS medium_quality_tracks,
    SUM(CASE WHEN tracking_quality = 'Low' THEN 1 ELSE 0 END) AS low_quality_tracks
    
FROM {{ ref('stg_bird_migration') }}
GROUP BY tag_type, tagged_by, tag_weight_g