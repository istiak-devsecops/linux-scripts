#!/bin/bash

echo "Starting file removal process..."
read -p "Enter the path of the file to remove: " FILE_PATH
if [[ -f "$FILE_PATH" ]];then
    read -p "Are you sure you wants to remove $FILE_PATH? (y/n):" ACTION

    if [[ "$ACTION" == "y" ]]; then
        rm "$FILE_PATH"
        echo "File '$FILE_PATH' has been removed."
    else
        echo "Action canceled. '$FILE_PATH' is safe."
    fi
else
    echo "Error: '$FILE_PATH' doesn't exist or is not a file."
    
fi