#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 4-January-2026    #
####################################

# ==== safety header ====
set -euo pipefail

# ==== configuration ====
readonly script_log="${1:-/tmp/rotator_admin.log}"
readonly logfile="${2:-/tmp/service_monitor.log}"

# ==== log message template ===
log(){
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$script_log"

    case "${level^^}" in
        "INFO"|"WARN"|"ERROR") printf "[%s] %s\n" "$level" "$message" ;;
    esac
}

# ==== clean up ====
cleanup(){
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
    local script_log_dir 
    script_log_dir=$(dirname "$script_log")

    mkdir -p "$script_log_dir"
    touch "$script_log"
    log "INFO" "Created log dir and file"
}
setup

# ==== Environment validation ====
# check if log data is file is avaliable to rotate log
check(){
    if [[ ! -f "$logfile" ]]; then
        log "ERROR" "File $logfile not found. Nothing to rotate"
        return 0
    fi
}

# ==== Brain ====
main(){
    check

    log "INFO" "Starting rotation check on $logfile"

    local file_size
    file_size=$(du -b "$logfile" | awk '{print $1}')

    if [[ "$file_size" -gt 10240 ]]; then
        log "INFO" "Log file size exceeded 10KB. Rotating..."
        mv "$logfile" "${logfile}.old-$(date)"
        touch "$logfile"
        log "INFO" "Log file Rotateed successfully. New log file created"
    else
        log "INFO" "Log size ($file_size bytes) is healthy"
    fi
}

main "$@"