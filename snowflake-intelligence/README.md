# Snowflake Intelligence Setup

This directory contains setup scripts for **Snowflake Intelligence** features: Cortex Analyst, Cortex Agent, and Cortex Search.

## Prerequisites

**Required:** Core setup must be completed first (includes semantic model stage creation)
```bash
snow sql -f setup.sql -c dash-builder-si
```

## Files

- `business_insights_semantic_model.yaml` - Semantic model definition for Cortex Analyst (uses logical table names for verified queries)
- `create_agent.sql` - Creates Cortex Agent in `AUTOMATED_INTELLIGENCE.SEMANTIC` schema for natural language queries
- `create_cortex_search.sql` - Creates Cortex Search service for product discovery

## Setup Instructions

### 1. Upload Semantic Model
```bash
snow stage copy snowflake-intelligence/business_insights_semantic_model.yaml \
  @automated_intelligence.raw.semantic_models/ --overwrite -c dash-builder-si
```

### 2. Create Cortex Agent
```bash
snow sql -f snowflake-intelligence/create_agent.sql -c dash-builder-si
```

### 3. Create Cortex Search Service
```bash
snow sql -f snowflake-intelligence/create_cortex_search.sql -c dash-builder-si
```

## What Gets Created

### Semantic Model Stage
- **Stage**: `automated_intelligence.raw.semantic_models`
- Stores YAML semantic model files for Cortex Analyst
- **Note**: Verified queries use logical table names (e.g., `orders`, `daily_business_metrics`) instead of physical table names

### Cortex Agent
- **Agent**: `automated_intelligence.semantic.order_analytics_agent`
- Created in the `SEMANTIC` schema using `AUTOMATED_INTELLIGENCE` role
- Enables natural language queries over order data
- Uses semantic model for context-aware SQL generation
- Requires `CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT` privilege

### Cortex Search Service
- **Service**: `automated_intelligence.raw.product_search_service`
- Enables semantic search over product catalog
- Useful for product discovery and recommendations

## Verification

### Verify Stage
```sql
LIST @automated_intelligence.raw.semantic_models;
```

### Test Cortex Agent
```sql
USE ROLE AUTOMATED_INTELLIGENCE;
USE DATABASE automated_intelligence;
USE SCHEMA semantic;

-- Ask questions in natural language
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'order_analytics_agent',
  'What were the top 5 products by revenue last month?'
);

-- Test discount analysis (now working with updated semantic model)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'order_analytics_agent',
  'What is the impact of discounts on revenue?'
);
```

### Test Cortex Search
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'automated_intelligence.raw.product_search_service',
    '{
      "query": "backcountry skiing equipment",
      "columns": ["product_name", "description", "price"],
      "limit": 5
    }'
  )
)['results'] AS search_results;
```

## Use Cases

### Cortex Analyst & Agent
- Business users asking questions in natural language
- Ad-hoc analytics without writing SQL
- Semantic understanding of business metrics

### Cortex Search
- Product discovery and recommendations
- Similar product suggestions
- Semantic product search in applications

## Related Demos
- **Streamlit Dashboard**: Integrates with Cortex Agent for natural language queries
