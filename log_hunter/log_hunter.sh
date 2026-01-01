#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 1-January-2026    #
####################################

# safety header {any command fails: -e | unset variable: -u | command fails in pipe command: -o pipefail } script stops
set -euo pipefail 

# Function to run if script is interrupted
cleanup() {
    # Check if log_file is defined before trying to log to it
    if [[ -n "${log_file:-}" ]]; then
        echo "[$(date)] [WARN] SCRIPT INTERRUPTED! Cleaning up..." >> "$log_file"
    fi
    echo -e "\n[WARN] Interrupted! Exiting..." >&2
    exit 1
}
trap cleanup 2 15

# This ensures Cron can find your commands
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Dynamic Base Dir: Use provided BASE_DIR or default to /home/arena
BASE_DIR="${BASE_DIR:-/home/arena}"
log_file="$BASE_DIR/log/audit.log"
MAX_SIZE="${MAX_SIZE:-102400}"

# configuration and counter
info_count=0
error_count=0
warn_count=0
timestamp=$(date +"%Y-%m %H:%M:%S")


# log function logic to store log
log() {
    local level="${1^^}" # level checking insensitive
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "[$timestamp] [$level] $message" >> "$log_file"

    # store logs and message based on the level and only shows error message as output in terminal
    case "$level" in 
        "INFO") echo -e "[INFO] $message";;
        "WARN") echo -e "[WARN] $message";;
        "ERROR") echo -e "[ERROR] $message" >&2;;

    esac
}

check_log_rotation() {
    # Only rotate if the file exists
    if [[ -f "$log_file" ]]; then
        local size
        size=$(stat -c%s "$log_file")
        
        if (( size > MAX_SIZE )); then
            # Use a clean timestamp for the old file name
            local rotate_ts
            rotate_ts=$(date +"%Y%m%d_%H%M%S")
            mv "$log_file" "${log_file}.${rotate_ts}"
            touch "$log_file"
            # We use echo here because log() would write to the new file
            echo "[$(date)] [INFO] Log rotated. Old log saved as ${log_file}.${rotate_ts}" >> "$log_file"
        fi
    fi
}

# main log checking function
check_log() {
    local file="$1"     
    local keyword="$2"

    # check if file exist
    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local count
    count=$(grep -ic "$keyword" "$file" 2> /dev/null) || count=0

  
    if [[ "$count" -gt 0 ]]; then
        echo "$count"
        return 0
    else
        return 2
    fi
}


touch "$log_file" 

# check if the log file has write permission if doesn't change the permission
if [[ ! -w "$log_file" ]]; then
    echo -e "[ERROR] Can't write to $log_file. Please run: chmod +w $log_file" >&2
    exit 1 # using exit code inside a if block won't trigger set -e logic
fi

# take keyword and arguments from the user and
# check if user provide at least one keyword and file
if [[ $# -lt 2 ]]; then
    echo -e "[ERROR] Usage: $0 <keyword> <file1> <file2>...">&2
    exit 1
fi

keyword="$1"
shift   # shift the arguments to the left

log "INFO" "Starting log hunter audit..." 

# take all the file name given as arguments and check them one by one
for logfile in "$@"; do
    status=0
    keyword_found=$(check_log "$logfile" "$keyword") || status=$? 
    # if the check_log succeed the status code is already 0 if its anything rather than 0 then $? will store the exit code of last execution

    case "$status" in
        0)
            log "INFO" "Keyword '$keyword' found $keyword_found times in: $logfile"
            ((info_count += keyword_found)) || true 
            ;;
        1)
            log "ERROR" "Target file missing!: $logfile"
            ((error_count++)) || true
            ;;
        2)
            log "WARN" "Keyword '$keyword' not found in: $logfile"
            ((warn_count++)) || true
            ;;
    esac
done

log "INFO" "Audit completed. [Found $info_count] [Missing Target $error_count] [Not Found $warn_count]"
echo "[| Detailed logs available in $log_file |]" >&2
if [[ "$info_count" -gt 0 ]]; then
    echo -e "!!! ALERT: Critical failures detected during audit !!!" >&2
fi
