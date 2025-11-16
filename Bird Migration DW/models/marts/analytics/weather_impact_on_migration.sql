{{
    config(
        materialized='table',
        tags=['analytics']
    )
}}

SELECT
    w.weather_condition,
    w.temperature_category,
    w.wind_category,
    COUNT(DISTINCT f.migration_key) AS total_migrations,
    ROUND(AVG(CASE WHEN f.migration_success = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent,
    ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
    ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
    ROUND(AVG(f.rest_stops), 2) AS avg_rest_stops
FROM {{ ref('fact_bird_migration') }} f
INNER JOIN {{ ref('dim_weather') }} w ON f.weather_key = w.weather_key
GROUP BY w.weather_condition, w.temperature_category, w.wind_category
HAVING COUNT(*) >= 10