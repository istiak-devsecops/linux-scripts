#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 3-January-2026    #
####################################

# ==== safety header ====
set -euo pipefail

# ==== configuration ====
DIR_PATH="$1"
BACKUP_DIR="$DIR_PATH/backups"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# ==== Environment validation and Setup ====
if [[ ! -d "$DIR_PATH" ]]; then
    echo -e "Not a Directory" >$2
    exit 1
fi

setup(){
    mkdir -p "$BACKUP_DIR"
}

# ==== Brain ====
main(){
    setup # called the function
    for file in "$DIR_PATH"/*.log; do 
        if [[ -f "$file" ]]; then
            FILENAME=$(basename "$file")

            cp "$file" "$BACKUP_DIR/$FILENAME-$TIMESTAMP.bak" || { echo "Failed to copy $file"; exit 1; }

            # truncate the original log
            > "$file"

            # compress the backup 
            gzip "$BACKUP_DIR/$FILENAME-$TIMESTAMP.bak"
            echo -e "Backed up and cleared: $FILENAME"
        fi
    done

    # clear the old log after the main work is done.
    echo "Clearning up backups older than 6 months..."
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +180 -delete 
}
main "$@" # calle the main function



