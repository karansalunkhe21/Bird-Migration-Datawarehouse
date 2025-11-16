{{
    config(
        materialized='ephemeral'
    )
}}

WITH origin_locations AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['origin', 'start_latitude', 'start_longitude']) }} AS location_key,
        origin AS location_name,
        valid_start_latitude AS latitude,
        valid_start_longitude AS longitude,
        region,
        habitat,
        'Origin' AS location_type
    FROM {{ ref('stg_bird_migration') }}
    WHERE origin IS NOT NULL
),

destination_locations AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['destination', 'end_latitude', 'end_longitude']) }} AS location_key,
        destination AS location_name,
        valid_end_latitude AS latitude,
        valid_end_longitude AS longitude,
        region,
        habitat,
        'Destination' AS location_type
    FROM {{ ref('stg_bird_migration') }}
    WHERE destination IS NOT NULL
),

all_locations AS (
    SELECT * FROM origin_locations
    UNION
    SELECT * FROM destination_locations
)

SELECT 
    location_key,
    location_name,
    latitude,
    longitude,
    region,
    habitat,
    location_type,
    COUNT(*) AS usage_count
FROM all_locations
GROUP BY 1, 2, 3, 4, 5, 6, 7