{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['weather_condition', 'temperature_c', 'wind_speed_kmph']) }} AS weather_key,
    weather_condition,
    temperature_c,
    wind_speed_kmph,
    humidity_percent,
    pressure_hpa,
    visibility_km,
    CASE 
        WHEN temperature_c < -10 THEN 'Extreme Cold'
        WHEN temperature_c < 0 THEN 'Freezing'
        WHEN temperature_c < 10 THEN 'Cold'
        WHEN temperature_c < 20 THEN 'Mild'
        WHEN temperature_c < 30 THEN 'Warm'
        ELSE 'Hot'
    END AS temperature_category,
    CASE 
        WHEN wind_speed_kmph < 10 THEN 'Calm'
        WHEN wind_speed_kmph < 20 THEN 'Light Breeze'
        WHEN wind_speed_kmph < 40 THEN 'Moderate Wind'
        WHEN wind_speed_kmph < 60 THEN 'Strong Wind'
        ELSE 'Gale'
    END AS wind_category,
    CASE 
        WHEN humidity_percent < 30 THEN 'Dry'
        WHEN humidity_percent < 60 THEN 'Moderate'
        ELSE 'Humid'
    END AS humidity_category,
    CASE 
        WHEN visibility_km < 1 THEN 'Poor'
        WHEN visibility_km < 5 THEN 'Moderate'
        ELSE 'Good'
    END AS visibility_category,
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
FROM {{ ref('stg_bird_migration') }}
WHERE weather_condition IS NOT NULL