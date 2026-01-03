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

# ==== cleanup ====
cleanup() {
    local exit_code=$?
    if [[ "$exit_code" -ne 0 && "$exit_code" -ne 130 ]]; then
        log "ERROR" "Script crashed or failed with exit code: $exit_code"
    elif [[ "$exit_code" -eq 130 ]]; then
        log "WARN" "Script stopped by user."
    fi
}

trap cleanup EXIT
trap 'exit 130' SIGINT

# ==== Environment setup ====
setup(){
    local log_dir
    log_dir=$(dirname "$logfile")

    mkdir -p "$log_dir"
    touch "$logfile"
}

# ==== Brain ====
main(){
    setup

    local service="${1:-}"

    if [[ -z "$service" ]]; then
        log "ERROR" "Arguments missing! Usage: $0 <service_name>"
        exit 1
    fi

    if pgrep -x "$service" > /dev/null; then
        log "INFO" "Service '$service' is UP"
    else
        log "WARN" "Service '$service' is DOWN"
    fi
}

main "$@"

