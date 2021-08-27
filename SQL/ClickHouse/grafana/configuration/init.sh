#!/bin/bash

GRAFANA_LINK=localhost:3000

# install the necessary "curl"
apk add curl

grafana-cli plugins install vertamedia-clickhouse-datasource 2.3.1

curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -u demo:demo \
    -T /configuration/datasource.json \
    -v \
    ${GRAFANA_LINK}/api/datasources

# https://grafana.com/docs/grafana/latest/http_api/dashboard/
curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -u demo:demo \
    -T /configuration/dashboard.json \
    -v \
    ${GRAFANA_LINK}/api/dashboards/db
