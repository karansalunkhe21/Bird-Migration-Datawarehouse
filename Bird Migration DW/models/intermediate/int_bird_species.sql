{{
    config(
        materialized='ephemeral'
    )
}}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['species']) }} AS bird_key,
    species,
    
    COUNT(*) AS total_migrations,
    AVG(flight_distance_km) AS avg_migration_distance_km,
    MAX(flight_distance_km) AS max_migration_distance_km,
    AVG(flight_duration_hours) AS avg_flight_duration_hours,
    AVG(average_speed_kmph) AS avg_speed_kmph,
    AVG(max_altitude_m) AS avg_max_altitude_m,
    
    SUM(CASE WHEN migration_success = 'SUCCESSFUL' THEN 1 ELSE 0 END) AS successful_migrations,
    SUM(CASE WHEN migration_success = 'FAILED' THEN 1 ELSE 0 END) AS failed_migrations,
    
    AVG(CASE WHEN migrated_in_flock THEN 1.0 ELSE 0.0 END) AS flock_migration_rate,
    AVG(flock_size) AS avg_flock_size,
    AVG(rest_stops) AS avg_rest_stops,
    AVG(predator_sightings) AS avg_predator_sightings
    
FROM {{ ref('stg_bird_migration') }}
GROUP BY species