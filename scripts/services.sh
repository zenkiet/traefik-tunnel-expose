#!/bin/bash

# =============================================================================
# Traefik Services Script
# =============================================================================
# Description: Starts Traefik and Cloudflared services
# Author: ZenKiet
# Dependencies: bash, traefik, cloudflared
# =============================================================================

# Initialize PIDs array
declare -a pids=()

INIT_LOG="${CONFIG_PATH}/logs/init.log"

mkdir -p "$(dirname "$INIT_LOG")"

# Logging functions
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> $INIT_LOG
}

# Trap to forward signals and clean exit
_term() {
  log "Caught SIGTERM, terminating child processes..."
  for pid in "${pids[@]}"; do
    kill -TERM "$pid" 2>/dev/null
  done
  wait
  exit 0
}

trap _term SIGTERM SIGINT

# Start Traefik
traefik --configfile=/etc/traefik/traefik.yaml
traefik_pid=$!
pids+=($traefik_pid)
log "Started Traefik with PID $traefik_pid"

# Check if Cloudflare is enabled
if [ "${CF_ENABLED:-true}" = "true" ]; then
  # Start Cloudflared
  cloudflared tunnel --config /etc/cloudflared/config.yml run
  cloudflared_pid=$!
  pids+=($cloudflared_pid)
  log "Started Cloudflared with PID $cloudflared_pid"

  # Start DNS auto updater in infinite loop
  bash -c 'while true; do /opt/scripts/auto-dns.sh; sleep 120; done'
  dns_pid=$!
  pids+=($dns_pid)
  log "Started Auto DNS updater with PID $dns_pid"
else
  log "Cloudflare services disabled (CF_ENABLED=false), skipping Cloudflared and DNS auto updater"
fi

# Start auto update checker in infinite loop
if [ "${AUTO_UPDATE:-true}" = "true" ]; then
  if [ -n "${SCHEDULE_UPDATE:-0 0 * * *}" ]; then
    bash -c "crontab -l | { cat; echo \"${SCHEDULE_UPDATE} /opt/scripts/auto-update.sh\"; } | crontab -"
  fi
  auto_update_pid=$!
  pids+=($auto_update_pid)
  log "Started Auto Update checker with PID $auto_update_pid"
fi

# Wait for all background processes
wait "${pids[@]}"