#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== pg_lake Demo Setup ==="
echo ""

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v docker compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

if [ ! -f ~/.aws/credentials ]; then
    echo "⚠️  AWS credentials not found at ~/.aws/credentials"
    echo "   pg_lake needs AWS credentials for S3 access."
    echo ""
fi

echo "Starting pg_lake container..."
docker compose up -d

echo ""
echo "Waiting for pg_lake to be ready..."
sleep 10

# Check if container is healthy
RETRIES=12
until docker compose exec -T pg_lake pg_isready -U postgres > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "  Waiting for PostgreSQL... ($RETRIES attempts left)"
    RETRIES=$((RETRIES-1))
    sleep 5
done

if [ $RETRIES -eq 0 ]; then
    echo "❌ pg_lake failed to start. Check logs:"
    echo "   docker compose logs pg_lake"
    exit 1
fi

echo ""
echo "✅ pg_lake is ready!"
echo ""
echo "=== Connection Info ==="
echo "  Host:     localhost"
echo "  Port:     5433"
echo "  User:     postgres"
echo "  Password: postgres"
echo "  Database: postgres"
echo ""
echo "=== Quick Commands ==="
echo "  Connect:  psql -h localhost -p 5433 -U postgres -d postgres"
echo "  Logs:     docker compose logs -f pg_lake"
echo "  Stop:     docker compose down"
echo ""
echo "=== Next Steps ==="
echo "  1. Connect to pg_lake: psql -h localhost -p 5433 -U postgres"
echo "  2. Run demo queries from: demo_queries.sql"
echo ""
