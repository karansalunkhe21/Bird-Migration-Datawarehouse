{{
    config(
        materialized='table',
        tags=['fact', 'core']
    )
}}

WITH migration_facts AS (
    SELECT
        stg.migration_key,
        bird.bird_key,
        origin_loc.location_key AS origin_location_key,
        dest_loc.location_key AS destination_location_key,
        stg.migration_start_month AS start_date_key,
        stg.migration_end_month AS end_date_key,
        weather.weather_key,
        tag.tag_key,
        stg.bird_id,
        stg.species,
        stg.migration_reason,
        stg.migration_duration_months,
        stg.migration_success,
        stg.is_migration_interrupted,
        stg.interrupted_reason,
        stg.flight_distance_km,
        stg.flight_duration_hours,
        stg.average_speed_kmph,
        stg.max_altitude_m,
        stg.min_altitude_m,
        stg.altitude_range_m,
        stg.temperature_c,
        stg.wind_speed_kmph,
        stg.humidity_percent,
        stg.pressure_hpa,
        stg.visibility_km,
        stg.rest_stops,
        stg.predator_sightings,
        stg.migrated_in_flock,
        stg.flock_size,
        stg.food_supply_level,
        stg.nesting_success,
        stg.tag_battery_level_percent,
        stg.signal_strength_db,
        stg.tracking_quality,
        stg.recovery_location_known,
        stg.recovery_time_days,
        stg.observation_counts,
        stg.observation_quality,
        CURRENT_TIMESTAMP() AS dw_created_at
    FROM {{ ref('stg_bird_migration') }} stg
    LEFT JOIN {{ ref('dim_bird') }} bird
        ON {{ dbt_utils.generate_surrogate_key(['stg.species']) }} = bird.bird_key
    LEFT JOIN {{ ref('dim_location') }} origin_loc
        ON {{ dbt_utils.generate_surrogate_key(['stg.origin', 'stg.valid_start_latitude', 'stg.valid_start_longitude']) }} = origin_loc.location_key
    LEFT JOIN {{ ref('dim_location') }} dest_loc
        ON {{ dbt_utils.generate_surrogate_key(['stg.destination', 'stg.valid_end_latitude', 'stg.valid_end_longitude']) }} = dest_loc.location_key
    LEFT JOIN {{ ref('dim_weather') }} weather
        ON {{ dbt_utils.generate_surrogate_key(['stg.weather_condition', 'stg.temperature_c', 'stg.wind_speed_kmph']) }} = weather.weather_key
    LEFT JOIN {{ ref('dim_tracking') }} tag
        ON {{ dbt_utils.generate_surrogate_key(['stg.tag_type', 'stg.tagged_by']) }} = tag.tag_key
)

SELECT * FROM migration_facts