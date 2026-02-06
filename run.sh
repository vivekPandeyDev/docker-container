#!/usr/bin/env bash
set -e

# load functions
source ./config.sh

ensure_network
ensure_volume grafana-data
ensure_volume tempo-data