{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

SELECT
    location_key,
    location_name,
    latitude,
    longitude,
    region,
    habitat,
    location_type,
    usage_count,
    CASE 
        WHEN latitude >= 0 THEN 'Northern Hemisphere'
        ELSE 'Southern Hemisphere'
    END AS hemisphere,
    CASE 
        WHEN latitude >= 66.5 THEN 'Arctic'
        WHEN latitude >= 23.5 THEN 'North Temperate'
        WHEN latitude >= -23.5 THEN 'Tropical'
        WHEN latitude >= -66.5 THEN 'South Temperate'
        ELSE 'Antarctic'
    END AS climate_zone,
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
FROM {{ ref('int_locations') }}