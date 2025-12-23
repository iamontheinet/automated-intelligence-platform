# Setup Documentation

This directory contains reference documentation for the core setup infrastructure.

## Documentation

### Dynamic Tables
- `DYNAMIC_TABLE_CONFIGURATION.md` - Configuration reference for the 3-tier Dynamic Tables pipeline
- `DYNAMIC_TABLE_LAG_FIX.md` - Troubleshooting guide for lag configuration issues

**Covers:**
- TARGET_LAG settings (time-based vs DOWNSTREAM)
- Refresh behavior and cascading
- Performance optimization
- Common configuration mistakes

## Usage

### Read Documentation
```bash
# View configuration reference
cat setup/docs/DYNAMIC_TABLE_CONFIGURATION.md

# View troubleshooting guide
cat setup/docs/DYNAMIC_TABLE_LAG_FIX.md
```

## Resetting for Fresh Demo

To completely reset and start fresh:

```bash
# Drop everything
DROP DATABASE automated_intelligence CASCADE;
DROP ROW ACCESS POLICY IF EXISTS automated_intelligence.raw.customers_region_policy;
DROP ROLE IF EXISTS west_coast_manager;

# Re-run setup
snow sql -f setup/setup.sql -c dash-builder-si
```

This ensures you're always working with the latest setup configuration.

## Related Resources

- Core setup: `setup/setup.sql` (run this first)
- Examples: `setup/examples/` (tutorials and learning materials)
- Interactive tutorial: `setup/examples/Dash_AI_DT.ipynb`
