{{
    config(
        materialized='table',
        tags=['analytics', 'comparison']
    )
}}

WITH species_metrics AS (
    SELECT
        b.species,
        
        -- Basic counts
        COUNT(DISTINCT f.migration_key) AS total_migrations,
        COUNT(DISTINCT f.bird_id) AS individual_birds,
        
        -- Success metrics
        ROUND(AVG(CASE WHEN f.migration_success = 'SUCCESSFUL' THEN 1.0 ELSE 0.0 END) * 100, 2) AS success_rate_percent,
        
        -- Distance metrics
        ROUND(AVG(f.flight_distance_km), 2) AS avg_distance_km,
        ROUND(MAX(f.flight_distance_km), 2) AS max_distance_km,
        ROUND(MIN(f.flight_distance_km), 2) AS min_distance_km,
        ROUND(STDDEV(f.flight_distance_km), 2) AS distance_std_dev,
        
        -- Speed metrics
        ROUND(AVG(f.average_speed_kmph), 2) AS avg_speed_kmph,
        ROUND(MAX(f.average_speed_kmph), 2) AS max_speed_kmph,
        
        -- Duration metrics
        ROUND(AVG(f.flight_duration_hours), 2) AS avg_duration_hours,
        
        -- Altitude metrics
        ROUND(AVG(f.max_altitude_m), 2) AS avg_max_altitude_m,
        ROUND(AVG(f.altitude_range_m), 2) AS avg_altitude_range_m,
        
        -- Behavioral metrics
        ROUND(AVG(f.rest_stops), 1) AS avg_rest_stops,
        ROUND(AVG(f.predator_sightings), 1) AS avg_predator_sightings,
        ROUND(AVG(CASE WHEN f.migrated_in_flock THEN 1.0 ELSE 0.0 END) * 100, 2) AS flock_migration_percent,
        ROUND(AVG(f.flock_size), 1) AS avg_flock_size,
        
        -- Weather conditions during migration
        ROUND(AVG(f.temperature_c), 1) AS avg_temperature,
        ROUND(AVG(f.wind_speed_kmph), 1) AS avg_wind_speed,
        
        -- Tracking quality
        ROUND(AVG(f.tag_battery_level_percent), 1) AS avg_battery_level
        
    FROM {{ ref('fact_bird_migration') }} f
    INNER JOIN {{ ref('dim_bird') }} b ON f.bird_key = b.bird_key
    GROUP BY b.species
),

rankings AS (
    SELECT
        *,
        -- Rank species by different metrics
        RANK() OVER (ORDER BY success_rate_percent DESC) AS success_rank,
        RANK() OVER (ORDER BY avg_distance_km DESC) AS distance_rank,
        RANK() OVER (ORDER BY avg_speed_kmph DESC) AS speed_rank,
        RANK() OVER (ORDER BY total_migrations DESC) AS activity_rank,
        
        -- Calculate percentiles
        PERCENT_RANK() OVER (ORDER BY success_rate_percent) AS success_percentile,
        PERCENT_RANK() OVER (ORDER BY avg_distance_km) AS distance_percentile,
        PERCENT_RANK() OVER (ORDER BY avg_speed_kmph) AS speed_percentile
        
    FROM species_metrics
)

SELECT
    species,
    total_migrations,
    individual_birds,
    success_rate_percent,
    success_rank,
    avg_distance_km,
    distance_rank,
    max_distance_km,
    min_distance_km,
    distance_std_dev,
    avg_speed_kmph,
    speed_rank,
    max_speed_kmph,
    avg_duration_hours,
    avg_max_altitude_m,
    avg_altitude_range_m,
    avg_rest_stops,
    avg_predator_sightings,
    flock_migration_percent,
    avg_flock_size,
    avg_temperature,
    avg_wind_speed,
    avg_battery_level,
    
    -- Performance categories
    CASE 
        WHEN success_percentile >= 0.75 THEN 'Top Performer'
        WHEN success_percentile >= 0.50 THEN 'Above Average'
        WHEN success_percentile >= 0.25 THEN 'Below Average'
        ELSE 'Poor Performer'
    END AS performance_category,
    
    -- Efficiency score (distance per hour)
    ROUND(avg_distance_km / NULLIF(avg_duration_hours, 0), 2) AS efficiency_score
    
FROM rankings
ORDER BY success_rate_percent DESC