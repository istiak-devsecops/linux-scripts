#!/bin/bash

####################################
# Author: Istiak Ahmed             #
# Date and time: 3-January-2026    #
####################################

# ==== saftey header ====
set -euo pipefail

# ==== Environment Validation ====
if [[ $# -eq 0 ]]; then
    echo -e "Usage: $0 <file-to-remove>" >&2
    exit 1
fi

# ==== Brain ====
# Define a function to handle the removal of a single item safely
remove_item() {
    local target="$1"
    
    if [[ -f "$target" || -d "$target" ]]; then
        rm -rf "$target"
        echo -e "[SUCCESS] Removed: $target"
    else
        echo -e "[SKIP] '$target' does not exist or is not a regular file/dir" >&2
    fi
}

main() {
    echo "Starting removal process for $# items..."
    
    # Iterate through all arguments passed to the script
    for item in "$@"; do
        remove_item "$item"
    done
    
    echo "Process complete."
}

# Execute main with all script arguments
main "$@"
