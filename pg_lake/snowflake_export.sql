-- ============================================================
-- Snowflake: Export Data to S3 for pg_lake
-- Run this in Snowflake to populate S3 with data
-- ============================================================

USE DATABASE AUTOMATED_INTELLIGENCE;
USE SCHEMA DYNAMIC_TABLES;
USE WAREHOUSE AUTOMATED_INTELLIGENCE_WH;

-- ------------------------------------------------------------
-- 1. Create internal stage for exports (if needed)
-- ------------------------------------------------------------

-- Create a named stage pointing to our S3 location
CREATE OR REPLACE STAGE pg_lake_export_stage
  URL = 's3://dash-iceberg-snowflake/demos/pg_lake/exports/'
  STORAGE_INTEGRATION = (SELECT STORAGE_INTEGRATION FROM INFORMATION_SCHEMA.EXTERNAL_VOLUMES WHERE EXTERNAL_VOLUME_NAME = 'AWS_S3_EXT_VOLUME_SNOWFLAKE' LIMIT 1)
  FILE_FORMAT = (TYPE = PARQUET);

-- Alternative: Use directory table with external volume
-- The external volume aws_s3_ext_volume_snowflake is already configured


-- ------------------------------------------------------------
-- 2. Export Daily Business Metrics
-- ------------------------------------------------------------

-- Export the daily metrics data to S3 as Parquet
COPY INTO 's3://dash-iceberg-snowflake/demos/pg_lake/exports/daily_metrics/'
FROM (
    SELECT 
        order_date,
        total_orders,
        total_revenue,
        unique_customers,
        avg_order_value,
        total_quantity
    FROM AUTOMATED_INTELLIGENCE.DYNAMIC_TABLES.DAILY_BUSINESS_METRICS
)
STORAGE_INTEGRATION = dash_snowflake_s3_integration
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE
HEADER = TRUE;


-- ------------------------------------------------------------
-- 3. Export Customer Summary
-- ------------------------------------------------------------

COPY INTO 's3://dash-iceberg-snowflake/demos/pg_lake/exports/customer_summary/'
FROM (
    SELECT 
        customer_id,
        customer_name,
        total_orders,
        total_revenue,
        first_order_date,
        last_order_date,
        avg_order_value
    FROM AUTOMATED_INTELLIGENCE.DYNAMIC_TABLES.CUSTOMER_PURCHASE_SUMMARY
)
STORAGE_INTEGRATION = dash_snowflake_s3_integration
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE
HEADER = TRUE;


-- ------------------------------------------------------------
-- 4. Export Product Performance
-- ------------------------------------------------------------

COPY INTO 's3://dash-iceberg-snowflake/demos/pg_lake/exports/product_performance/'
FROM (
    SELECT 
        product_id,
        product_name,
        category,
        total_quantity_sold,
        total_revenue,
        unique_customers,
        avg_unit_price
    FROM AUTOMATED_INTELLIGENCE.DYNAMIC_TABLES.PRODUCT_PERFORMANCE_SUMMARY
)
STORAGE_INTEGRATION = dash_snowflake_s3_integration
FILE_FORMAT = (TYPE = PARQUET)
OVERWRITE = TRUE
HEADER = TRUE;


-- ------------------------------------------------------------
-- 5. Verify exports
-- ------------------------------------------------------------

-- List exported files
LIST 's3://dash-iceberg-snowflake/demos/pg_lake/exports/';
