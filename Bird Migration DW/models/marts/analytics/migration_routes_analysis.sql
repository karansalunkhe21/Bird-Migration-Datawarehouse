{{
    config(
        materialized='table',
        tags=['analytics']
    )
}}

SELECT
    b.species,
    origin.location_name AS origin_location,
    dest.location_name AS destination_location,
    COUNT(*) AS migration_count,
    ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
    ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
    ROUND(AVG(CASE WHEN f.migration_success = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key
INNER JOIN {{ ref('dim_location') }} origin ON f.origin_location_key = origin.location_key
INNER JOIN {{ ref('dim_location') }} dest ON f.destination_location_key = dest.location_key
WHERE origin.location_name IS NOT NULL AND dest.location_name IS NOT NULL
GROUP BY b.species, origin.location_name, dest.location_name
HAVING COUNT(*) >= 3