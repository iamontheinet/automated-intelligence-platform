# pg_lake Demo

Standalone pg_lake demo using Docker. Demonstrates Postgres querying data lake files (Parquet, Iceberg) in S3.

## Prerequisites

- Docker & Docker Compose
- AWS credentials configured (`~/.aws/credentials`) with access to `s3://dash-iceberg-snowflake/demos/`

## Quick Start

```bash
# Start pg_lake
docker compose up -d

# Wait for it to be ready (~30 seconds)
docker compose logs -f pg_lake

# Connect to Postgres
psql -h localhost -p 5433 -U postgres -d postgres
# Password: postgres
```

## What's Running

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL + pg_lake | 5433 | Main database with pg_lake extensions |
| pgduck_server | 5332 | DuckDB query engine (internal) |

## Demo Scenarios

### 1. Query Parquet files from S3

```sql
-- Create foreign table pointing to S3
CREATE FOREIGN TABLE my_data ()
SERVER pg_lake
OPTIONS (path 's3://dash-iceberg-snowflake/demos/exports/*.parquet');

-- Query it like a regular table
SELECT * FROM my_data LIMIT 10;
```

### 2. Create Iceberg tables

```sql
-- Create Iceberg table (data stored in S3)
CREATE TABLE events (
    event_id SERIAL,
    event_type TEXT,
    created_at TIMESTAMP DEFAULT NOW()
) USING iceberg;

-- Insert and query
INSERT INTO events (event_type) VALUES ('click'), ('view');
SELECT * FROM events;
```

### 3. Export data to S3

```sql
COPY (SELECT * FROM events) 
TO 's3://dash-iceberg-snowflake/demos/pg_lake/exports/events.parquet';
```

## Integration with Snowflake Demo

This pg_lake instance can query data exported from the main Snowflake demo:

```
Snowflake (AUTOMATED_INTELLIGENCE)
    │
    ├── COPY TO s3://dash-iceberg-snowflake/demos/exports/
    │
    └── pg_lake queries the same S3 location
```

### Export from Snowflake

```sql
-- In Snowflake: Export metrics to S3
COPY INTO @my_s3_stage/exports/daily_metrics/
FROM AUTOMATED_INTELLIGENCE.DYNAMIC_TABLES.DAILY_BUSINESS_METRICS
FILE_FORMAT = (TYPE = PARQUET)
HEADER = TRUE;
```

### Query in pg_lake

```sql
-- In pg_lake: Query the exported data
CREATE FOREIGN TABLE daily_metrics ()
SERVER pg_lake
OPTIONS (path 's3://dash-iceberg-snowflake/demos/exports/daily_metrics/*.parquet');

SELECT * FROM daily_metrics;
```

## S3 Configuration

- **Bucket**: `s3://dash-iceberg-snowflake/demos/`
- **Region**: `us-west-2`
- **External Volume** (Snowflake): `aws_s3_ext_volume_snowflake`

## Files

| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker setup for pg_lake |
| `init/01_init_pg_lake.sql` | Initializes pg_lake extensions |
| `demo_queries.sql` | Example queries to run |

## Cleanup

```bash
# Stop and remove containers
docker compose down

# Remove data volume too
docker compose down -v
```

## Troubleshooting

### Connection refused
Wait 30 seconds after `docker compose up` for pg_lake to initialize.

### S3 access denied
Ensure `~/.aws/credentials` has valid credentials with S3 read access.

### Extension not found
The pg_lake Docker image should have extensions pre-installed. Check logs:
```bash
docker compose logs pg_lake
```
