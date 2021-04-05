#!/bin/bash

echo "Starting Wizzy Entrypoint script"

set -e

if [ "$#" -eq 0 ]; then
    if [ -z "$GRAFANA_URL" ]; then echo "Must set environment variable GRAFANA_URL"; exit 1; fi
    if [ -z "$GRAFANA_USERNAME" ]; then echo "Must set environment variable GRAFANA_USERNAME"; exit 1; fi
    if [ -z "$GRAFANA_PASSWORD" ]; then echo "Must set environment variable GRAFANA_PASSWORD"; exit 1; fi
    wizzy init && \
    wizzy set grafana url $GRAFANA_URL && \
    wizzy set grafana username $GRAFANA_USERNAME && \
    wizzy set grafana password $GRAFANA_PASSWORD
    echo "Exporting Datasources"
    wizzy import datasources
    echo "Exporting Dashboards"
    wizzy import dashboards
else
    exec "$@"
fi

sleep 1d
