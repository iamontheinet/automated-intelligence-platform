-- ============================================================
-- Snowflake: Create Iceberg Tables for pg_lake
-- These tables export data to S3 in Iceberg format
-- ============================================================

USE DATABASE AUTOMATED_INTELLIGENCE;
USE WAREHOUSE AUTOMATED_INTELLIGENCE_WH;

-- Create schema for pg_lake Iceberg tables
CREATE SCHEMA IF NOT EXISTS PG_LAKE
  COMMENT = 'Iceberg tables for pg_lake demo - external Postgres access via S3';

USE SCHEMA PG_LAKE;

-- ------------------------------------------------------------
-- 1. Create Iceberg Tables from RAW data
-- ------------------------------------------------------------

-- Product Reviews Iceberg Table
CREATE OR REPLACE ICEBERG TABLE PRODUCT_REVIEWS
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = 'aws_s3_ext_volume_snowflake'
  BASE_LOCATION = 'demos/pg_lake/product_reviews'
AS SELECT * FROM AUTOMATED_INTELLIGENCE.RAW.PRODUCT_REVIEWS;

-- Support Tickets Iceberg Table (with timestamp precision fix for Iceberg)
CREATE OR REPLACE ICEBERG TABLE SUPPORT_TICKETS
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = 'aws_s3_ext_volume_snowflake'
  BASE_LOCATION = 'demos/pg_lake/support_tickets'
AS SELECT 
    TICKET_ID,
    CUSTOMER_ID,
    TICKET_DATE::TIMESTAMP_NTZ(6) AS TICKET_DATE,
    CATEGORY,
    PRIORITY,
    SUBJECT,
    DESCRIPTION,
    RESOLUTION,
    STATUS
FROM AUTOMATED_INTELLIGENCE.RAW.SUPPORT_TICKETS;

-- ------------------------------------------------------------
-- 2. Verify Tables
-- ------------------------------------------------------------

SELECT 'PRODUCT_REVIEWS' as table_name, COUNT(*) as row_count FROM PRODUCT_REVIEWS
UNION ALL
SELECT 'SUPPORT_TICKETS', COUNT(*) FROM SUPPORT_TICKETS;

-- ------------------------------------------------------------
-- 3. Get Iceberg Metadata Locations (for pg_lake foreign tables)
-- ------------------------------------------------------------

SELECT 
    'PRODUCT_REVIEWS' as table_name,
    PARSE_JSON(SYSTEM$GET_ICEBERG_TABLE_INFORMATION('AUTOMATED_INTELLIGENCE.PG_LAKE.PRODUCT_REVIEWS')):metadataLocation::STRING as metadata_location
UNION ALL
SELECT 
    'SUPPORT_TICKETS',
    PARSE_JSON(SYSTEM$GET_ICEBERG_TABLE_INFORMATION('AUTOMATED_INTELLIGENCE.PG_LAKE.SUPPORT_TICKETS')):metadataLocation::STRING;

-- ------------------------------------------------------------
-- 4. Refresh Iceberg Tables (run after RAW data changes)
-- ------------------------------------------------------------

-- To sync changes from RAW tables to Iceberg:
-- INSERT OVERWRITE INTO PRODUCT_REVIEWS SELECT * FROM RAW.PRODUCT_REVIEWS;
-- INSERT OVERWRITE INTO SUPPORT_TICKETS SELECT ... FROM RAW.SUPPORT_TICKETS;
