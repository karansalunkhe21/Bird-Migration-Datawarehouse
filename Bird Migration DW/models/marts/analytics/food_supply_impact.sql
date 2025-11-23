{{
    config(
        materialized='table',
        tags=['analytics', 'environmental']
    )
}}

SELECT
    f.food_supply_level,
    b.species,
    d.season,
    
    -- Migration patterns
    COUNT(*) AS total_migrations,
    ROUND(AVG(CASE WHEN f.migration_success = 'SUCCESSFUL' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent,
    
    -- Distance and duration
    ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
    ROUND(AVG(f.flight_duration_hours), 2) AS avg_duration_hours,
    
    -- Physical condition indicators
    ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
    ROUND(AVG(f.rest_stops), 1) AS avg_rest_stops,
    
    -- Nesting outcomes
    ROUND(AVG(CASE WHEN f.nesting_success = 'SUCCESSFUL' THEN 1.0 ELSE 0.0 END) * 100, 2) AS nesting_success_rate,
    
    -- Behavioral changes
    ROUND(AVG(CASE WHEN f.migrated_in_flock THEN 1.0 ELSE 0.0 END) * 100, 2) AS flock_migration_percent,
    
    -- Recovery metrics
    ROUND(AVG(f.recovery_time_days), 1) AS avg_recovery_days
    
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key
INNER JOIN {{ ref('dim_date') }} d ON f.start_date_key = d.date_key

WHERE f.food_supply_level IS NOT NULL

GROUP BY f.food_supply_level, b.species, d.season
HAVING COUNT(*) >= 3
ORDER BY f.food_supply_level, success_rate_percent DESC