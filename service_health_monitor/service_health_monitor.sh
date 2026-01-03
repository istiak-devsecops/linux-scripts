#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 3-January-2026    #
####################################

# ==== safety header ====
set -euo pipefail
IFS=$'\n\t'

# ==== configuration ====
readonly logfile=${LOG:-/tmp/service_monitor.log}


# ==== log storing template ====
log(){
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$logfile"

    case "${level^^}" in
        "INFO"|"WARN"|"ERROR") printf "[%s] %s\n" "$level" "$message" ;;
    esac
}

# ==== Brain ====
main(){
    if [[ -z "$1" ]]; then
        log "[ERROR]" "Arguments missing"
        exit 1
    fi

    if pgrep -x "$1" > /dev/null; then
        echo "UP"
    else
        echo "DOWN"
    fi
}
main "$@"

