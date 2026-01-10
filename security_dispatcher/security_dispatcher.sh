#!/usr/bin/env bash

#####################################
# Author: Istiak Ahmed              #
# Date: 10-January-2026             #
# Task: send notification of threat #
#####################################

# ==== safety header ====
set -euo pipefail


# ==== configuration ====
readonly webhook_url="${1:-https://discord.com/api/webhooks/537637291053547520}"

# ==== alert notification ====
alert() {
    local ip="$1"
    local target="$2"

    local payload
    payload=$(cat << EOF
    {
        "content": "**Security Alert**",
        "embeds": [{
            "description": "Unauthorized access attempt detected.",
            "fields": [
                { "name": "Attacker IP", "value": "$ip", "inline": true },
                { "name": "Target System", "value": "$target", "inline": true },
                { "name": "Severity", "value": "High", "inline": true },
            ],
            "footer": { "text": "Source: Production Log Monitor" } 
        }]
    }
    EOF
    )


}