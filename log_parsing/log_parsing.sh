#!/usr/bin/env bash

####################################
# Author: Istiak Ahmed             #
# Date: 10-January-2026            #
# Task: log parser                 #
####################################

# ==== safety header ====
set -euo pipefail
IFS=$'\n\t'

# ==== exit clleanup ====
script_exit() {
    log "INFO" "Audit complete. Exit code: $1"
}
trap 'script_exit $?' EXIT

# ==== configuration ====
readonly log_file="${1:-/var/log/auth.log}"

# ==== log template ====
log() {
    local level="$1^^"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    printf "[%s] [%s]: %s\n" "$timestamp" "$level" "$message"

    case "$level" in
        "INFO") echo -e "$level" "$message" ;;
        "ERROR") echo -e "$level" "$message" ;;
    esac
}

# ==== brain ====
analyze_security() {
    log "INFO" "Analyzing $log_file for security threats..."

    awk -F'[ =]' '{
        user="unknown"; ip="0.0.0.0"; status="unknown"
        for (i=1; i<=NF; i++) {
            if ($i == "user") user=$(i+1)
            if ($i == "ip") ip=$(i+1)
            if ($i == "status") status=$(i+1)
        }
        if (status == "failed") {
            printf "Threat detected: User=$s, Origin=%s\n", user, ip
            }
    }' "$log_file"
}

# ==== Main function ====
main() {
    if [[ ! -f "$log_file" ]]; then
        log "ERROR" "File $log_file not found."
        exit 1
    fi
    analyze_security
}

main "$@"