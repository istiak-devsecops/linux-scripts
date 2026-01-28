#!/usr/bin/env bash

###############################################################################
# Author: Istiak Ahmed
# Date: 2026-01-21
# Description: [Health Check of the server]
###############################################################################

# 1. ==== SAFETY HEADER (The Armor) ====
set -euo pipefail
IFS=$'\n\t'

# 2. ==== CONFIGURATION (Statelessness) ====
readonly SCRIPT_LOG=${LOG_PATH:-/tmp/script_output.log}
readonly TARGET_DIR=${1:-/tmp/data}

# 3. ==== LOGGING TEMPLATE (Observability) ====
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Save to log file
    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$SCRIPT_LOG"

    # Print to console (stdout for INFO, stderr for ERROR)
    if [[ "${level^^}" == "ERROR" ]]; then
        printf "[%s] %s\n" "$level" "$message" >&2
    else
        printf "[%s] %s\n" "$level" "$message"
    fi
}

# 4. ==== CLEANUP & TRAPS (Fail-Fast Protection) ====
cleanup() {
    local exit_code=$?
    if [[ "$exit_code" -ne 0 && "$exit_code" -ne 130 ]]; then
        log "ERROR" "Script failed unexpectedly with exit code: $exit_code"
    fi
}
trap cleanup EXIT
trap 'exit 130' SIGINT # Handle Ctrl+C gracefully

# 5. ==== ENVIRONMENT SETUP & VALIDATION (Idempotency) ====
setup() {
    # Ensure log directory exists
    local log_dir
    log_dir=$(dirname "$SCRIPT_LOG")
    mkdir -p "$log_dir"
    
    # Validate dependencies (Check if needed tools are installed)
    for cmd in jq; do
        if ! command -v "$cmd" &> /dev/null; then
            log "ERROR" "Required command '$cmd' is not installed."
            exit 1
        fi
    done
}



# 6. ==== THE BRAIN (Main Logic) ====
main() {
    setup
    log "INFO" "Starting execution..."

    # Validate inputs
    if [[ ! -d "$TARGET_DIR" ]]; then
        log "ERROR" "Target directory $TARGET_DIR does not exist."
        exit 1
    fi

    # Execute Logic
   # Inside main() after your validation checks:

local input_file="nodes.json"
local cleanup_subdir="cleanup_required"

# 1. Fail-Fast if file is missing
if [[ ! -f "$input_file" ]]; then
    log "ERROR" "Input file $input_file not found."
    exit 1
fi

# 2. Use jq to get names of unhealthy nodes
# -r gives raw output (no quotes)
unhealthy_nodes=$(jq -r '.[] | select(.status == "unhealthy") | .hostname' "$input_file")

# 3. Process the nodes
for node in $unhealthy_nodes; do
    log "INFO" "Processing unhealthy node: $node"
    
    # IDEMPOTENCY: mkdir -p doesn't error if dir exists
    # We create a directory named after the node inside our TARGET_DIR
    mkdir -p "$TARGET_DIR/${node}_${cleanup_subdir}"
    
    log "INFO" "Cleanup directory ensured for $node"
done
    
    log "INFO" "Script completed successfully."
}

# 7. ==== EXECUTION ====
# Pass all command line arguments to main
main "$@"