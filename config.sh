#!/usr/bin/env bash
ensure_volume() {
  local volume_name="$1"

  if docker volume inspect "$volume_name" >/dev/null 2>&1; then
    echo "✔ Volume exists: $volume_name"
  else
    echo "📦 Creating volume: $volume_name"
    docker volume create "$volume_name" >/dev/null
  fi
}

# =========================
# Ensure Docker network (from .env)
# =========================
ensure_network() {
  local env_file=".env"

  if [[ ! -f "$env_file" ]]; then
    echo "❌ .env file not found"
    return 1
  fi

  # load env vars (export them)
  set -a
  source "$env_file"
  set +a

  if [[ -z "$APP_NETWORK" ]]; then
    echo "❌ APP_NETWORK is not set in .env"
    return 1
  fi

  if docker network inspect "$APP_NETWORK" >/dev/null 2>&1; then
    echo "✔ Network exists: $APP_NETWORK"
  else
    echo "🌐 Creating network: $APP_NETWORK"
    docker network create "$APP_NETWORK" >/dev/null
  fi
}