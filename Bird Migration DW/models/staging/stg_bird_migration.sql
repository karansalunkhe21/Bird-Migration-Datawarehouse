{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('raw', 'bird_migration_raw') }}
),

cleaned AS (
    SELECT
        -- Unique Key
        {{ dbt_utils.generate_surrogate_key(['bird_id', 'migration_start_month', 'origin', 'destination']) }} AS migration_key,
        
        -- Bird Identification
        TRIM(bird_id) AS bird_id,
        TRIM(UPPER(species)) AS species,
        TRIM(tag_type) AS tag_type,
        TRIM(tagged_by) AS tagged_by,
        tag_weight_g,
        
        -- Geographic Information
        TRIM(region) AS region,
        TRIM(habitat) AS habitat,
        TRIM(origin) AS origin,
        TRIM(destination) AS destination,
        start_latitude,
        start_longitude,
        end_latitude,
        end_longitude,
        
        -- Validate coordinates
        CASE WHEN start_latitude BETWEEN -90 AND 90 THEN start_latitude ELSE NULL END AS valid_start_latitude,
        CASE WHEN start_longitude BETWEEN -180 AND 180 THEN start_longitude ELSE NULL END AS valid_start_longitude,
        CASE WHEN end_latitude BETWEEN -90 AND 90 THEN end_latitude ELSE NULL END AS valid_end_latitude,
        CASE WHEN end_longitude BETWEEN -180 AND 180 THEN end_longitude ELSE NULL END AS valid_end_longitude,
        
        -- Migration Details
        TRIM(migration_reason) AS migration_reason,
        
        -- Convert month names to numbers
        CASE TRIM(UPPER(migration_start_month))
            WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
            WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
            WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
            WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
            WHEN 'MAY' THEN 5
            WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
            WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
            WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
            WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
            WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
            WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
            WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
            ELSE TRY_CAST(migration_start_month AS INTEGER)  -- Handle if already a number
        END AS migration_start_month,
        
        CASE TRIM(UPPER(migration_end_month))
            WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
            WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
            WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
            WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
            WHEN 'MAY' THEN 5
            WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
            WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
            WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
            WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
            WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
            WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
            WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
            ELSE TRY_CAST(migration_end_month AS INTEGER)  -- Handle if already a number
        END AS migration_end_month,
        
        -- Calculate migration duration
        CASE 
            WHEN CASE TRIM(UPPER(migration_end_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_end_month AS INTEGER)
                END >= 
                CASE TRIM(UPPER(migration_start_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_start_month AS INTEGER)
                END
            THEN 
                CASE TRIM(UPPER(migration_end_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_end_month AS INTEGER)
                END - 
                CASE TRIM(UPPER(migration_start_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_start_month AS INTEGER)
                END + 1
            ELSE 
                (12 - CASE TRIM(UPPER(migration_start_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_start_month AS INTEGER)
                END) + 
                CASE TRIM(UPPER(migration_end_month))
                    WHEN 'JAN' THEN 1 WHEN 'JANUARY' THEN 1
                    WHEN 'FEB' THEN 2 WHEN 'FEBRUARY' THEN 2
                    WHEN 'MAR' THEN 3 WHEN 'MARCH' THEN 3
                    WHEN 'APR' THEN 4 WHEN 'APRIL' THEN 4
                    WHEN 'MAY' THEN 5
                    WHEN 'JUN' THEN 6 WHEN 'JUNE' THEN 6
                    WHEN 'JUL' THEN 7 WHEN 'JULY' THEN 7
                    WHEN 'AUG' THEN 8 WHEN 'AUGUST' THEN 8
                    WHEN 'SEP' THEN 9 WHEN 'SEPT' THEN 9 WHEN 'SEPTEMBER' THEN 9
                    WHEN 'OCT' THEN 10 WHEN 'OCTOBER' THEN 10
                    WHEN 'NOV' THEN 11 WHEN 'NOVEMBER' THEN 11
                    WHEN 'DEC' THEN 12 WHEN 'DECEMBER' THEN 12
                    ELSE TRY_CAST(migration_end_month AS INTEGER)
                END + 1
        END AS migration_duration_months,
        
        TRIM(UPPER(migration_success)) AS migration_success,
        CASE 
            WHEN TRIM(UPPER(migration_interrupted)) IN ('YES', 'TRUE', '1') THEN TRUE
            WHEN TRIM(UPPER(migration_interrupted)) IN ('NO', 'FALSE', '0') THEN FALSE
            ELSE NULL
        END AS is_migration_interrupted,
        TRIM(interrupted_reason) AS interrupted_reason,
        
        -- Flight Metrics
        NULLIF(flight_distance_km, 0) AS flight_distance_km,
        NULLIF(flight_duration_hours, 0) AS flight_duration_hours,
        average_speed_kmph,
        max_altitude_m,
        min_altitude_m,
        
        CASE 
            WHEN max_altitude_m IS NOT NULL AND min_altitude_m IS NOT NULL 
            THEN max_altitude_m - min_altitude_m 
            ELSE NULL 
        END AS altitude_range_m,
        
        -- Weather Conditions
        TRIM(weather_condition) AS weather_condition,
        temperature_c,
        wind_speed_kmph,
        humidity_percent,
        pressure_hpa,
        visibility_km,
        
        -- Behavioral Data
        rest_stops,
        predator_sightings,
        CASE 
            WHEN TRIM(UPPER(migrated_in_flock)) IN ('YES', 'TRUE', '1') THEN TRUE
            WHEN TRIM(UPPER(migrated_in_flock)) IN ('NO', 'FALSE', '0') THEN FALSE
            ELSE NULL
        END AS migrated_in_flock,
        flock_size,
        TRIM(food_supply_level) AS food_supply_level,
        TRIM(nesting_success) AS nesting_success,
        
        -- Tracking Quality
        tag_battery_level_percent,
        signal_strength_db,
        TRIM(tracking_quality) AS tracking_quality,
        
        -- Recovery & Observation
        CASE 
            WHEN TRIM(UPPER(recovery_location_known)) IN ('YES', 'TRUE', '1') THEN TRUE
            WHEN TRIM(UPPER(recovery_location_known)) IN ('NO', 'FALSE', '0') THEN FALSE
            ELSE NULL
        END AS recovery_location_known,
        recovery_time_days,
        observation_counts,
        TRIM(observation_quality) AS observation_quality
        
    FROM source
    WHERE bird_id IS NOT NULL
    AND species IS NOT NULL
)

SELECT * FROM cleaned