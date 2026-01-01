#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 1-January-2026    #
####################################

set -euo pipefail

DIR_PATH="$1"
BACKUP_DIR="$DIR_PATH/backups"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# create a backup dir if it doesn't exist
mkdir -p "$BACKUP_DIR"

if [[ -d "$DIR_PATH" ]]; then
    for file in "$DIR_PATH"/*.log; do 
        if [[ -f "$file" ]]; then
            FILENAME=$(basename "$file")

            cp "$file" "BACKUP_DIR/$FILENAME-$TIMESTAMP.bak"

            # truncate the original log
            > "$file"

            # compress the backup 
            gzip "$BACKUP_DIR/$FILENAME-$TIMESTAMP.bak"
            echo "Backed up and cleared: $FILENAME"
        fi
    done

    echo "Clearning up backups older than 6 months..."
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +180 -delete
else
    echo "Directory not found"
    exit 1
fi