#!/bin/bash

# Logging functions
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> /var/log/init.log
}

# Trap to forward signals and clean exit
_term() {
  log "Caught SIGTERM, terminating child processes..."
  kill -TERM "$traefik_pid" "$cloudflared_pid" "$dns_pid" 2>/dev/null
  wait
  exit 0
}

trap _term SIGTERM SIGINT

# Start Traefik
traefik --configfile=/etc/traefik/traefik.yaml >> /var/log/traefik/traefik-access.log 2>&1 &
traefik_pid=$!
log "Started Traefik with PID $traefik_pid"

# Start Cloudflared
cloudflared tunnel --config /etc/cloudflared/config.yml run >> /var/log/cloudflared/cloudflared.log 2>&1 &
cloudflared_pid=$!
log "Started Cloudflared with PID $cloudflared_pid"

# Start DNS auto updater in infinite loop
bash -c 'while true; do /opt/scripts/auto-dns.sh; sleep 120; done' >> /var/log/traefik-dns.log 2>&1 &
dns_pid=$!
log "Started Auto DNS updater with PID $dns_pid"

# Wait for all background processes
wait $traefik_pid $cloudflared_pid $dns_pid