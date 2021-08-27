
- [Quick Start](#quick-start)
- [Grafana](#grafana)

This repo sets up everything for Airflow to run locally.

## Quick Start
1. Start up Grafana, ClickHouse with both server and client via `bash setup.sh`
2. Go to "localhost:8123/play" for the UI
3. Start writing SQL to try ClickHouse out

Note that the UI only accepts one SQL statement at a time.


## Grafana
To keep a dashboard, copy its corresponding json file and wrap it as:
```json
{
    "dashboard": {
        ...
    }
}
```
