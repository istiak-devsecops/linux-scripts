#!/bin/bash

####################################
# Author: Istiak
# Date and time: 27 Aug 2025 9:16PM
####################################

set -eo pipefail

# === CONFIGURATION ===
LOG_DIR="/var/log/myapp"          
ARCHIVE_ROOT="$LOG_DIR/archives"   # Where compressed logs will be stored
DAYS_OLD=7                         # Rotate logs older than this many days

# === PREPARE ARCHIVE FOLDER ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_DIR="$ARCHIVE_ROOT/archive_$TIMESTAMP"
mkdir -p "$ARCHIVE_DIR"

echo "[$(date)] Starting log rotation for $LOG_DIR..."
echo "Archiving logs older than $DAYS_OLD days into $ARCHIVE_DIR"

# === FIND AND COMPRESS OLD LOGS ===
find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS_OLD | while read -r logfile; do
    BASENAME=$(basename "$logfile")
    gzip -c "$logfile" > "$ARCHIVE_DIR/$BASENAME.gz"
    echo "Archived: $logfile → $ARCHIVE_DIR/$BASENAME.gz"
    rm "$logfile"
done

echo "[$(date)] Log rotation complete."
