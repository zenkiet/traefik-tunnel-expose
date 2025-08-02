#!/bin/bash

# =============================================================================
# Gotify Notification Service
# =============================================================================
# Description: Send notifications via Gotify push service
# Author: ZenKiet
# Environment Variables: GOTIFY_URL, GOTIFY_TOKEN
# =============================================================================

set -euo pipefail

# Configuration
LOG_FILE="${CONFIG_PATH}/logs/notification.log"
NOTIFICATION_TYPES=("info" "warning" "error" "success")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

check_valid() {
    if [[ -z "${GOTIFY_URL:-}" ]] || [[ -z "${GOTIFY_TOKEN:-}" ]]; then
        log "Gotify not configured - GOTIFY_URL or GOTIFY_TOKEN not set"
        return 1
    fi
    
    # Validate URL format
    if [[ ! "$GOTIFY_URL" =~ ^https?:// ]]; then
        log "Invalid GOTIFY_URL format: $GOTIFY_URL"
        return 1
    fi
    return 0
}

# Send notification to Gotify
send() {
    local title="$1"
    local message="$2"
    local priority="${3:-5}"
    local notification_type="${4:-info}"
    
    # Validate priority (0-10)
    if ! [[ "$priority" =~ ^[0-9]+$ ]] || [[ "$priority" -lt 0 ]] || [[ "$priority" -gt 10 ]]; then
        log "Invalid priority: $priority, using default (5)"
        priority=5
    fi
    
    # Validate notification type
    if [[ ! " ${NOTIFICATION_TYPES[*]} " =~ " ${notification_type} " ]]; then
        log "Invalid notification type: $notification_type, using default (info)"
        notification_type="info"
    fi
    
    if ! check_valid; then
        log "Cannot send notification - Gotify not configured"
        return 1
    fi
    
    # Prepare JSON payload
    local payload
    payload=$(cat <<EOF
{
    "title": "$title",
    "message": "$message",
    "priority": $priority
}
EOF
)
    
    log "Sending notification: $title (priority: $priority, type: $notification_type)"
    
    local response
    response=$(curl -s -w "%{http_code}" -o /tmp/gotify_response.json \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-Gotify-Key: $GOTIFY_TOKEN" \
        -d "$payload" \
        "$GOTIFY_URL/message" 2>/dev/null || echo "000")
    
    if [[ "$response" == "200" ]]; then
        log "Notification sent successfully"
        rm -f /tmp/gotify_response.json
        return 0
    else
        log "Failed to send notification - HTTP $response"
        rm -f /tmp/gotify_response.json
        return 1
    fi
}

# Send info notification
send_info() {
    local title="$1"
    local message="$2"
    local priority="${3:-5}"
    
    send "$title" "$message" "$priority" "info"
}

# Send warning notification
send_warning() {
    local title="$1"
    local message="$2"
    local priority="${3:-7}"
    
    send "$title" "$message" "$priority" "warning"
}

# Send error notification
send_error() {
    local title="$1"
    local message="$2"
    local priority="${3:-9}"
    
    send "$title" "$message" "$priority" "error"
}

# Send success notification
send_success() {
    local title="$1"
    local message="$2"
    local priority="${3:-3}"
    
    send "$title" "$message" "$priority" "success"
}

# Send update notification
send_update() {
    local component="$1"
    local old_version="$2"
    local new_version="$3"
    local status="$4"
    
    case "$status" in
        "available")
            send_info "📦 Update Available" "$component: $old_version → $new_version"
            ;;
        "downloading")
            send_info "⬇️ Downloading Update" "$component: $old_version → $new_version"
            ;;
        "installing")
            send_info "🔧 Installing Update" "$component: $old_version → $new_version"
            ;;
        "completed")
            send_success "✅ Update Completed" "$component: $old_version → $new_version"
            ;;
        "failed")
            send_error "❌ Update Failed" "$component: $old_version → $new_version"
            ;;
        *)
            send_info "ℹ️ Update Status" "$component: $status"
            ;;
    esac
}


# Main function
main() {
    log "Notification script started"
    
    case "${1}" in
        "info")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 info <title> <message>"
                exit 1
            fi
            send_info "$2" "$3" "$4"
            ;;
        "warning")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 warning <title> <message>"
                exit 1
            fi
            send_warning "$2" "$3" "$4"
            ;;
        "error")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 error <title> <message>"
                exit 1
            fi
            send_error "$2" "$3" "$4"
            ;;
        "success")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 success <title> <message>"
                exit 1
            fi
                send_success "$2" "$3" "$4"
            ;;
        "update")
            if [[ $# -lt 5 ]]; then
                echo "Usage: $0 update <component> <old> <new> <status>"
                exit 1
            fi
            send_update "$2" "$3" "$4" "$5"
            ;;
    esac
    
    log "Notification script finished"
}

# Execute main function
main "$@"
