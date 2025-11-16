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
    avg_battery_level,
    avg_signal_strength,
    total_deployments,
    high_quality_tracks,
    medium_quality_tracks,
    low_quality_tracks,
    ROUND(high_quality_tracks::FLOAT / NULLIF(total_deployments, 0) * 100, 2) AS high_quality_rate_percent,
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
FROM {{ ref('int_tracking_devices') }}