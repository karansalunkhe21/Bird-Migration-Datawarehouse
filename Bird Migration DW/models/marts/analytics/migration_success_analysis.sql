{{
    config(
        materialized='table',
        tags=['analytics']
    )
}}

SELECT
    b.species,
    d_start.season AS migration_season,
    f.migration_reason,
    COUNT(*) AS total_migrations,
    SUM(CASE WHEN f.migration_success = 'YES' THEN 1 ELSE 0 END) AS successful_count,
    ROUND(AVG(CASE WHEN f.migration_success = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent,
    SUM(CASE WHEN f.is_migration_interrupted THEN 1 ELSE 0 END) AS interrupted_count,
    ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
    ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
    ROUND(AVG(f.rest_stops), 1) AS avg_rest_stops
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key
INNER JOIN {{ ref('dim_date') }} d_start ON f.start_date_key = d_start.date_key
GROUP BY b.species, d_start.season, f.migration_reason
HAVING COUNT(*) >= 5