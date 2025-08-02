#!/bin/bash

# =============================================================================
# Traefik Auto Update Script
# =============================================================================
# Description: Automatically updates Traefik and Cloudflared to the latest version
# Author: ZenKiet
# Dependencies: curl, jq, systemctl (optional)
# =============================================================================

set -euo pipefail

LOG_FILE="${CONFIG_PATH}/logs/auto-update.log"
BACKUP_DIR="/tmp/traefik-backup-$(date +%Y%m%d-%H%M%S)"
TRAEFIK_BIN="${TRAEFIK_BIN:-/usr/local/bin/traefik}"
CLOUDFLARED_BIN="${CLOUDFLARED_BIN:-/usr/local/bin/cloudflared}"

mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> $LOG_FILE
}

fetch_latest_release() {
    local repo="$1"
    local tag
    tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | jq -r '.tag_name' 2>/dev/null || true)
    if [[ -n "$tag" && "$tag" != "null" ]]; then
        echo "$tag"
    else
        echo "unknown"
    fi
}


stop_process() {
    local name="$1"
    if pgrep -f "$name" >/dev/null 2>&1; then
        log "Stopping $name..."
        pkill -TERM -f "$name" || true
        sleep 3
        pkill -KILL -f "$name" || true
        log "$name stopped"
    fi
}


start_services() {
    log "Starting services..."
    log "Launching Traefik"
    nohup "$TRAEFIK_BIN" --configfile=/etc/traefik/traefik.yaml >/dev/null 2>&1 &
    log "Traefik started with PID $!"

    if [[ "${CF_ENABLED:-true}" == "true" ]]; then
        log "Launching Cloudflared"
        nohup "$CLOUDFLARED_BIN" tunnel --config /etc/cloudflared/config.yml run >/dev/null 2>&1 &
        log "Cloudflared started with PID $!"
    fi
}

update_binary() {
    local name="$1" latest_tag="$2" url="$3" decompress="$4" target="$5"
    log "Updating $name to version $latest_tag..."

    # Back up existing binary if present
    mkdir -p "$BACKUP_DIR"
    if [[ -f "$target" ]]; then
        cp "$target" "$BACKUP_DIR/"
    fi

    # Perform the download and installation
    if [[ "$decompress" == "true" ]]; then
        # Download tarball and extract the binary
        if ! curl -fsSL "$url" | tar -xz -C /tmp/; then
            log "Failed to download $name archive"
            return 1
        fi
        # Move the extracted binary to target
        mv "/tmp/$name" "$target"
    else
        if ! curl -fsSL "$url" -o "$target"; then
            log "Failed to download $name binary"
            return 1
        fi
    fi
    chmod +x "$target"
}

main() {
    log "Auto-update script started"

    local traefik_current="unknown" cloudflare_current="unknown"
    if command -v traefik >/dev/null 2>&1; then
        traefik_current=$(traefik version 2>/dev/null | sed -n 's/.*Version: //p' | awk '{$1=$1;print}' || echo "unknown")
    fi
    if command -v cloudflared >/dev/null 2>&1; then
        cloudflare_current=$(cloudflared --version 2>/dev/null | awk 'NR==1{print $3}' | sed 's/^v//' || echo "unknown")
    fi

    # Fetch the latest release tags from GitHub
    local tf_latest cf_latest
    tf_latest=$(fetch_latest_release "traefik/traefik")
    cf_latest=$(fetch_latest_release "cloudflare/cloudflared")

    log "Traefik version: $traefik_current (installed) -> $tf_latest (latest)"
    log "Cloudflared version: $cloudflare_current (installed) -> $cf_latest (latest)"

    # If the latest version is not "unknown", mark for update.
    local update_traefik=false update_cloudflared=false
    if [[ "$tf_latest" != "unknown" && "$traefik_current" != "$tf_latest" ]]; then
        update_traefik=true
    fi
    if [[ "$cf_latest" != "unknown" && "$cloudflare_current" != "$cf_latest" ]]; then
        update_cloudflared=true
    fi

    if [[ "$update_traefik" == false && "$update_cloudflared" == false ]]; then
        log "No updates available"
        log "Auto-update script finished"
        return 0
    fi

    # Stop existing processes to ensure binaries can be replaced cleanly
    stop_process "traefik"
    stop_process "cloudflared"

    # Attempt updates, rolling back if installation fails
    local result=0
    if [[ "$update_traefik" == true ]]; then
        if ! update_binary "traefik" "$tf_latest" \
            "https://github.com/traefik/traefik/releases/download/${tf_latest}/traefik_${tf_latest}_linux_amd64.tar.gz" \
            true "$TRAEFIK_BIN"; then
            # Restore backup if available
            cp "$BACKUP_DIR/traefik" "$TRAEFIK_BIN" 2>/dev/null || true
            result=1
            log "Traefik update failed; restored from backup"
            # Send notification about failed update
            /opt/scripts/notification.sh update traefik "$traefik_current" "$tf_latest" failed 2>/dev/null || true
        else
            log "Traefik updated successfully to $tf_latest"
            # Send notification about completed update
            /opt/scripts/notification.sh update traefik "$traefik_current" "$tf_latest" completed 2>/dev/null || true
        fi
    fi
    if [[ "$update_cloudflared" == true ]]; then
        if ! update_binary "cloudflared" "$cf_latest" \
            "https://github.com/cloudflare/cloudflared/releases/download/${cf_latest}/cloudflared-linux-amd64" \
            false "$CLOUDFLARED_BIN"; then
            cp "$BACKUP_DIR/cloudflared" "$CLOUDFLARED_BIN" 2>/dev/null || true
            result=1
            log "Cloudflared update failed; restored from backup"
            # Send notification about failed update
            /opt/scripts/notification.sh update cloudflared "$cloudflare_current" "$cf_latest" failed 2>/dev/null || true
        else
            log "Cloudflared updated successfully to $cf_latest"
            # Send notification about completed update
            /opt/scripts/notification.sh update cloudflared "$cloudflare_current" "$cf_latest" completed 2>/dev/null || true
        fi
    fi

    # Clean up backup data once updates complete or fail
    rm -rf "$BACKUP_DIR" 2>/dev/null || true

    # Restart services if at least one update succeeded
    start_services

    if [[ "$result" -eq 0 ]]; then
        log "Auto-update process completed successfully"
    else
        log "Auto-update process completed with errors"
    fi
    log "Auto-update script finished"
    return "$result"
}

# Execute the main function
main "$@"