-- ============================================================
-- pg_lake Demo Queries
-- Query Snowflake-exported data directly from Postgres
-- ============================================================

-- ------------------------------------------------------------
-- 1. Query Parquet files exported from Snowflake
-- ------------------------------------------------------------

-- Create foreign table pointing to Snowflake exports
-- (Run this after Snowflake exports data to S3)

CREATE FOREIGN TABLE daily_metrics ()
SERVER pg_lake
OPTIONS (path 's3://dash-iceberg-snowflake/demos/exports/daily_metrics/*.parquet');

-- Query the data
SELECT * FROM daily_metrics LIMIT 10;

-- Aggregations work too
SELECT 
    order_date,
    SUM(total_orders) as orders,
    SUM(total_revenue) as revenue
FROM daily_metrics
GROUP BY order_date
ORDER BY order_date DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 2. Create native Iceberg table in Postgres
-- ------------------------------------------------------------

-- Create an Iceberg table (data stored in S3)
CREATE TABLE events (
    event_id SERIAL,
    event_type TEXT,
    event_data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
) USING iceberg;

-- Insert data
INSERT INTO events (event_type, event_data) VALUES
    ('page_view', '{"page": "/home", "user_id": 123}'),
    ('click', '{"button": "buy_now", "user_id": 123}'),
    ('purchase', '{"order_id": 456, "amount": 99.99}');

-- Query it
SELECT * FROM events;

-- Check Iceberg metadata
SELECT table_name, metadata_location FROM iceberg_tables;


-- ------------------------------------------------------------
-- 3. COPY data to/from S3
-- ------------------------------------------------------------

-- Export query results to S3 as Parquet
COPY (SELECT * FROM events) 
TO 's3://dash-iceberg-snowflake/demos/pg_lake/exports/events.parquet';

-- Import data from S3
-- COPY events FROM 's3://dash-iceberg-snowflake/demos/pg_lake/exports/events.parquet';


-- ------------------------------------------------------------
-- 4. Query CSV/JSON files directly
-- ------------------------------------------------------------

-- If you have CSV files in S3:
-- CREATE FOREIGN TABLE my_csv ()
-- SERVER pg_lake
-- OPTIONS (path 's3://dash-iceberg-snowflake/demos/data/*.csv');

-- If you have JSON files:
-- CREATE FOREIGN TABLE my_json ()
-- SERVER pg_lake  
-- OPTIONS (path 's3://dash-iceberg-snowflake/demos/data/*.json');
