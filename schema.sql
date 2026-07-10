CREATE TABLE asteroids (
    id                  SERIAL PRIMARY KEY,
    asteroid_id         VARCHAR(20),
    name                VARCHAR(100),
    close_approach_date DATE,
    is_hazardous        BOOLEAN,
    diameter_min_km     FLOAT,
    diameter_max_km     FLOAT,
    diameter_avg_km     FLOAT,
    velocity_kmh        FLOAT,
    miss_distance_km    FLOAT,
    miss_distance_lunar FLOAT,
    ingested_at         TIMESTAMP,
    UNIQUE(asteroid_id, close_approach_date)  -- prevents duplicates on reruns
);