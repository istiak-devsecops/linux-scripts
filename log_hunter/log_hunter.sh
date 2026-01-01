#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 1-January-2026    #
####################################

# safety header {any command fails: -e | unset variable: -u | command fails in pipe command: -o pipefail } script stops
set -euo pipefail 

# This ensures Cron can find your commands
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# configuration and counter
log_file="/home/arena/log/audit.log" # fileto store log data
info_count=0
error_count=0
warn_count=0

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

# main log checking function
check_log() {
    local file="$1"     
    local keyword="$2"

    # check if file exist
    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # check the status of the keyword given
    if grep -qi "$keyword" "$file" 2> /dev/null; then 
        return 0
    else
        return 2
    fi
}

log "INFO" "Starting log hunter audit..." 

# by default if file exist touch just modify the timestamp
mkdir -p "$(dirname "$log_file")"
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


# take all the file name given as arguments and check them one by one
for logfile in "$@"; do
    status=0
    check_log "$logfile" "$keyword" || status=$? 
    # if the check_log succeed the status code is already 0 if its anything rather than 0 then $? will store the exit code of last execution

    # store log data based on status code
    case "$status" in
        0) log "INFO" "Keyword $keyword found in: $logfile"
        ((info_count++))
        ;;
        1) log "ERROR" "Target file missing: $logfile"
        ((error_count++))
        ;;
        2) log "WARN" "keyword $keyword not found in: $logfile"
        ((warn_count++))
        ;;
    esac
done

log "INFO" "Audit completed. [Found $info_count] [Missing Target $error_count] [Not Found $warn_count] | Detailed logs available in $log_file"

if [[ "$error_count" -gt 0 ]]; then
    echo -e "!!! ALERT: Critical failures detected during audit !!!" >&2
fi
