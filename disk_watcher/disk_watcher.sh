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

        printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$logfile"

        case "${level^^}" in
            "INFO") printf "[%s] %s\n" "[$level]" "$message" ;;
            "WARN") printf "[%s] %s\n" "[$level]" "$message" ;;
            "ERROR") printf "[%s] %s\n" "[$level]" "$message" ;;
        esac
}


# ==== Environment validation ====
setup(){
    local log_dir
    log_dir=$(dirname "$logfile")

    mkdir -p "$log_dir"
    touch "$logfile"
}


# ==== Brain ====
main() {
    setup # Initialize environment

    local target_dir="${1:-/}" # either it will be first arguments or /
    log "INFO" "Checking disk usage for: $target_dir"

    if [[ ! -d "$target_dir" ]]; then # check if the given directory exist
        log "ERROR" "Directory Doesn't exist"
        exit 1
    fi

    local usage
    usage=$(df -h "$target_dir" | awk 'NR==2 {print $5}')

    if [[ "${usage%\%}" -gt 80 ]]; then
        log "WARN" "Disk space critical on $target_dir: $usage"
    else
        log "INFO" "Disk space is healthy $target_dir: $usage"
    fi
}

main "$@"

