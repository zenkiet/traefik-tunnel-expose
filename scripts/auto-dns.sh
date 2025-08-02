#!/bin/bash

# =============================================================================
# Traefik DNS Automation Script
# =============================================================================
# Description: Automatically creates DNS records in Cloudflare for Traefik hosts
# Author: ZenKiet
# Dependencies: curl, jq, yq
# =============================================================================

set -euo pipefail

CF_ZONE_API_TOKEN=${CF_ZONE_API_TOKEN}
ZONE_ID=${CF_ZONE_ID}
BASE_DOMAIN=${BASE_DOMAIN}
TRAEFIK_CONFIG_DIR=${TRAEFIK_CONFIG_DIR}
TRAEFIK_API_URL="http://127.0.0.1:8080/api"
LOG_FILE="${CONFIG_PATH}/logs/auto-dns.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}


# Get hosts from Traefik API
get_hosts_from_api() {
    curl -s "$TRAEFIK_API_URL/http/routers" 2>/dev/null | \
    jq -r '.[].rule // empty' | \
    grep -oE 'Host\(`[^`]+`\)' | \
    sed 's/Host(`\(.*\)`)/\1/' | \
    sort -u
}

# Get hosts from config files
get_hosts_from_config() {
    find "$TRAEFIK_CONFIG_DIR" -name "*.yml" -exec grep -l "Host(" {} \; 2>/dev/null | \
    xargs grep -h "Host(" 2>/dev/null | \
    grep -oE 'Host\(`[^`]+`\)' | \
    sed 's/Host(`\(.*\)`)/\1/' | \
    sort -u
}

# Get existing DNS records from Cloudflare
get_existing_dns_records() {
    curl -s -H "Authorization: Bearer $CF_ZONE_API_TOKEN" \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" | \
    jq -r '.result[].name' 2>/dev/null | sort -u
}

# Get existing DNS records
get_existing_dns_records() {
    curl -s -H "Authorization: Bearer $CF_ZONE_API_TOKEN" \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" | \
    jq -r '.result[].name' 2>/dev/null | sort -u
}

# Create DNS record
create_dns_record() {
    local hostname="$1"
    local subdomain="${hostname%.$BASE_DOMAIN}"

    [[ "$subdomain" == "$BASE_DOMAIN" ]] && return

    curl -s -X POST \
        -H "Authorization: Bearer $CF_ZONE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"type\":\"CNAME\",\"name\":\"$subdomain\",\"content\":\"$BASE_DOMAIN\",\"ttl\":1,\"proxied\":true}" \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" >/dev/null

    log "Created DNS record for $hostname"
    sleep 1
}

# Main execution
main() {
    log "Starting Traefik DNS automation"

    # Get all unique hosts
    all_hosts=$(
        {
            get_hosts_from_api
            get_hosts_from_config
        } | grep "$BASE_DOMAIN" | sort -u
    )

    host_count=$(echo "$all_hosts" | wc -l)
    log "Found $host_count hosts matching $BASE_DOMAIN"

    # Get existing DNS records
    existing_records=$(get_existing_dns_records)

    # Create missing DNS records
    echo "$all_hosts" | while IFS= read -r host; do
        [[ -z "$host" ]] && continue
        if ! echo "$existing_records" | grep -q "^$host$"; then
            create_dns_record "$host"
        fi
    done

    log "Completed Traefik DNS automation"
}

main "$@"
