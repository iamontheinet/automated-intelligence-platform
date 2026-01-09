create extension if not exists pg_lake_spatial cascade;

-- Foreign tables for Snowflake Iceberg data
-- These point to Iceberg metadata files (NOT raw parquet) to preserve Iceberg semantics

DROP FOREIGN TABLE IF EXISTS product_reviews;
CREATE FOREIGN TABLE product_reviews()
SERVER pg_lake
OPTIONS (path 's3://dash-iceberg-snowflake/demos/demos/pg_lake/product_reviews.I4eDpa3p/metadata/00001-4b132282-9eea-4b51-b0a3-87d8bd36e55a.metadata.json');

DROP FOREIGN TABLE IF EXISTS support_tickets;
CREATE FOREIGN TABLE support_tickets()
SERVER pg_lake
OPTIONS (path 's3://dash-iceberg-snowflake/demos/demos/pg_lake/support_tickets.qZPKfN5O/metadata/00001-fa1256ff-3810-45a6-8fbf-92a5a8f87bf4.metadata.json');
