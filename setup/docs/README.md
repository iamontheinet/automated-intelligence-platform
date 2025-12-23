# Setup Documentation & Maintenance Scripts

This directory contains reference documentation and maintenance scripts for the core setup infrastructure.

## Documentation

### Dynamic Tables
- `DYNAMIC_TABLE_CONFIGURATION.md` - Configuration reference for the 3-tier Dynamic Tables pipeline
- `DYNAMIC_TABLE_LAG_FIX.md` - Troubleshooting guide for lag configuration issues

**Covers:**
- TARGET_LAG settings (time-based vs DOWNSTREAM)
- Refresh behavior and cascading
- Performance optimization
- Common configuration mistakes

## Maintenance Scripts

⚠️ **Use with caution** - These scripts modify system configuration or reset data.

### Dynamic Tables Configuration
- `set_realtime_lag.sql` - Configure Dynamic Tables for real-time (1 second) lag

**When to use:**
- For demo scenarios requiring sub-second freshness
- Default is 12 hours (batch analytics), this switches to near real-time

### Data Management
- `reset_tables.sql` - Reset and recreate tables for fresh start

**When to use:**
- When you need to clear data and start fresh for demos
- Truncates raw tables and recreates Dynamic Tables

## Usage

### Read Documentation
```bash
# View configuration reference
cat setup/docs/DYNAMIC_TABLE_CONFIGURATION.md

# View troubleshooting guide
cat setup/docs/DYNAMIC_TABLE_LAG_FIX.md
```

### Run Maintenance Scripts
```bash
# Set real-time lag (for demos requiring sub-second freshness)
snow sql -f setup/docs/set_realtime_lag.sql -c dash-builder-si

# Reset tables (⚠️ deletes data!)
snow sql -f setup/docs/reset_tables.sql -c dash-builder-si
```

## When to Use These

**Documentation:**
- When configuring Dynamic Tables
- When debugging refresh issues
- When understanding pipeline architecture

**Maintenance Scripts:**
- ❌ **NOT** part of initial setup
- ✅ Use for troubleshooting or reconfiguration
- ✅ Use for demo resets

## Related Resources

- Core setup: `setup/setup.sql` (run this first)
- Examples: `setup/examples/` (tutorials and learning materials)
- Interactive tutorial: `setup/examples/Dash_AI_DT.ipynb`
