#!/bin/sh

# =============================================================================
# Traefik Services Script
# =============================================================================
# Description: Starts Traefik and Cloudflared services
# Author: ZenKiet
# Dependencies: ash, traefik, cloudflared
# =============================================================================

# Initialize PIDs array
pids=""

INIT_LOG="${CONFIG_PATH}/logs/init.log"

mkdir -p "$(dirname "$INIT_LOG")"

# Logging function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$INIT_LOG"
}

# Cleanup function
cleanup() {
  log "Caught signal, terminating processes..."
  for pid in $pids; do
    kill -TERM "$pid" 2>/dev/null
  done
  wait
  exit 0
}

trap cleanup TERM INT

# Start Traefik
log "Starting Traefik..."
traefik --configfile=/etc/traefik/traefik.yaml &
traefik_pid=$!
pids="$pids $traefik_pid"
log "Started Traefik with PID $traefik_pid"

# Start Cloudflared if enabled
if [ "${CF_ENABLED:-true}" = "true" ]; then
  log "Starting Cloudflared..."
  cloudflared tunnel --config /etc/cloudflared/config.yml run &
  cloudflared_pid=$!
  pids="$pids $cloudflared_pid"
  log "Started Cloudflared with PID $cloudflared_pid"

  # Start DNS auto updater
  log "Starting DNS auto updater..."
  while true; do
    /opt/scripts/auto-dns.sh
    sleep 120
  done &
  dns_pid=$!
  pids="$pids $dns_pid"
  log "Started DNS updater with PID $dns_pid"
else
  log "Cloudflare services disabled"
fi

# Start auto update checker if enabled
if [ "${AUTO_UPDATE:-true}" = "true" ]; then
  log "Starting auto update checker..."
  while true; do
    /opt/scripts/auto-update.sh
    sleep 21600  # 6 hours
  done &
  update_pid=$!
  pids="$pids $update_pid"
  log "Started auto update checker with PID $update_pid"
fi

# Wait for all processes
wait