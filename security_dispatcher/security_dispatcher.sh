#!/usr/bin/env bash
#####################################
# Author: Istiak Ahmed              #
# Date: 11-January-2026             #
# Task: send notification of threat #
#####################################

set -euo pipefail

# ==== configuration ====
# Loading .env safely
if [[ -f ".env" ]]; then
    set -a 
    source .env
    set +a
else
    echo "Error: .env file missing"
    exit 1
fi

# ==== log template ====
log() { echo "[$(date +'%H:%M:%S')] [$1] $2"; }

# ==== alert notification ====
dispatch_alert() {
    local ip="$1"
    local target="$2"

    local payload
    payload=$(cat <<EOF
{
  "content": "**Security Alert**",
  "embeds": [{
    "title": "Unauthorized Access Attempt",
    "fields": [
      { "name": "Attacker IP", "value": "$ip", "inline": true },
      { "name": "Target", "value": "$target", "inline": true }
    ]
  }]
}
EOF
)

    # Note: No WEBHOOK_URL in the script! It comes from .env
    curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$WEBHOOK_URL"
    log "INFO" "Alert dispatched for IP: $ip"
}

# ==== MAIN ==== # (simulation)
raw_log="DATA: 2026-01-10T22:00Z | EVENT: login_fail | SOURCE: 103.44.12.5 | TARGET: admin_panel"
ext_ip=$(echo "$raw_log" | awk -F'[|: ]+' '{print $6}')
ext_target=$(echo "$raw_log" | awk -F'[|: ]+' '{print $8}')

dispatch_alert "$ext_ip" "$ext_target"