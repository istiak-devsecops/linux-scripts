#!/bin/bash

# A list of items separated by spaces
FILES="config.txt settings.json users.db"

for FILE in $FILES; do
    echo "Backing up $FILE..."
    cp "$FILE" "$FILE.bak"
done

echo "All backups complete!"