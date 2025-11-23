{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

SELECT
    tag_key,
    tag_type,
    tagged_by,
    tag_weight_g,
    
    -- Performance metrics
    avg_battery_level,
    avg_signal_strength,
    
    -- Quality distribution - CORRECTED
    total_deployments,
    excellent_quality_tracks,
    good_quality_tracks,
    fair_quality_tracks,
    poor_quality_tracks,
    
    -- Calculate percentages
    ROUND(excellent_quality_tracks::FLOAT / NULLIF(total_deployments, 0) * 100, 2) AS excellent_quality_percent,
    ROUND(good_quality_tracks::FLOAT / NULLIF(total_deployments, 0) * 100, 2) AS good_quality_percent,
    ROUND(fair_quality_tracks::FLOAT / NULLIF(total_deployments, 0) * 100, 2) AS fair_quality_percent,
    ROUND(poor_quality_tracks::FLOAT / NULLIF(total_deployments, 0) * 100, 2) AS poor_quality_percent,
    
    -- Metadata
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
    
FROM {{ ref('int_tracking_devices') }}
