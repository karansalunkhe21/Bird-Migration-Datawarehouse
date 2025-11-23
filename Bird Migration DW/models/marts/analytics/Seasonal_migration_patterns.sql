{{
    config(
        materialized='table',
        tags=['analytics', 'temporal']
    )
}}

SELECT
    d.season,
    d.month_name,
    d.month_number,
    d.migration_season,
    
    -- Migration volume
    COUNT(DISTINCT f.migration_key) AS total_migrations,
    COUNT(DISTINCT b.bird_key) AS active_species,
    
    -- Success metrics
    ROUND(AVG(CASE WHEN f.migration_success = 'SUCCESSFUL' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent,
    ROUND(AVG(CASE WHEN f.is_migration_interrupted THEN 1.0 ELSE 0.0 END) * 100, 2) AS interruption_rate_percent,
    
    -- Performance metrics
    ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
    ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
    ROUND(AVG(f.flight_duration_hours), 2) AS avg_duration_hours,
    
    -- Altitude patterns
    ROUND(AVG(f.max_altitude_m), 2) AS avg_max_altitude_m,
    
    -- Weather patterns
    ROUND(AVG(f.temperature_c), 1) AS avg_temperature_c,
    ROUND(AVG(f.wind_speed_kmph), 1) AS avg_wind_speed_kmph,
    ROUND(AVG(f.humidity_percent), 1) AS avg_humidity_percent,
    
    -- Behavioral patterns
    ROUND(AVG(f.rest_stops), 1) AS avg_rest_stops,
    ROUND(AVG(CASE WHEN f.migrated_in_flock THEN 1.0 ELSE 0.0 END) * 100, 2) AS flock_migration_percent,
    
    -- Top species in this season
    MODE(b.species) AS most_common_species,
    
    -- Risk indicators
    ROUND(AVG(f.predator_sightings), 2) AS avg_predator_sightings
    
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_date') }} d ON f.start_date_key = d.date_key
INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key

GROUP BY d.season, d.month_name, d.month_number, d.migration_season
ORDER BY d.month_number
