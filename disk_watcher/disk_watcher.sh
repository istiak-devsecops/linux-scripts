#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 2-January-2026    #
####################################

# ==== Safety Header ====
set -euo pipefail 
IFS=$'\n\t'     # new line and tab as a default seperator


# ==== configuration ====
readonly logfile=${LOG:-/tmp/disk_monitor.log}


# ==== cleanup function ====
cleanup() {
    local exit_code=$?
    if [[ "$exit_code" -eq 130 ]]; then
        log "[WARN]" "Warning: Process interrupted by user (Ctrl+C)"
    elif [[ "$exit_code" -ne 0 ]]; then
        log "[ERROR]" "Script exited with an error (Code: $exit_code)."
    fi 
}

trap cleanup EXIT
trap 'exit 130' SIGINT


# ==== log function ====
log() {
        local level="$1"
        local message="$2"
        local timestamp
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        printf "[$timestamp] [$level] [$message]" >> "$logfile"

        case "${level^^}" in
            "INFO") printf "[$level] $message" ;;
            "WARN") printf "[$level] $message" ;;
        esac
}


# ==== Environment validation ====
log_dir=$(dirname "$logfile")

if [[ ! -d "$log_dir" ]]; then # if the log dir doesn't exist create one
    mkdir -p "$log_dir"
fi

if [[ ! -f "$logfile" ]]; then # if the file doesn't exist create one
    touch "$logfile"
fi


# ==== Brain ====
main() {
    usage=$(df -h / | awk 'NR==2 {print $5}')

    if [ "${usage%\%}" -gt 80 ]; then
        log "WARN" "Disk is almost full"
    else
        log "INFO" "Disk space is healthy"
    fi
}

main "$@"

