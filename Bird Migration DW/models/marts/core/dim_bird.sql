{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

SELECT
    bird_key,
    species,
    total_migrations,
    avg_migration_distance_km,
    max_migration_distance_km,
    avg_flight_duration_hours,
    avg_speed_kmph,
    avg_max_altitude_m,
    successful_migrations,
    failed_migrations,
    CASE 
        WHEN (successful_migrations + failed_migrations) > 0 
        THEN ROUND(successful_migrations::FLOAT / (successful_migrations + failed_migrations) * 100, 2)
        ELSE NULL 
    END AS success_rate_percent,
    flock_migration_rate,
    avg_flock_size,
    avg_rest_stops,
    avg_predator_sightings,
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
FROM {{ ref('int_bird_species') }}