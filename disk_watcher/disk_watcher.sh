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

# ==== log function ====
log() {
        local level="$1"
        local message="$2"
        local timestamp
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        echo -e "[$timestamp] [$level] [$message]" >> "$logfile"

        case "${level^^}" in
            "INFO") echo -e "[$level] $message" ;;
            "WARN") echo -e "[$level] $message" ;;
        esac
}


# ==== Brain ====
usage=$(df -h / | awk 'NR==2 {print $5}')

if [ "${usage%\%}" -gt 80 ]; then
    log "WARN" "Disk is almost full"
else
    log "INFO" "Disk space is healthy"
fi
