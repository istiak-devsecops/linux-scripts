#!/bin/bash

####################################
# Author: Istiak
# Date and time: 27 Aug 2025 9:16PM
####################################

set -eo pipefail

# Define log file
LOG_FILE="/var/log/syslog"

# Define keywords to search
KEYWORDS="error|failed|denied"

# Define output file
ALERT_FILE="alerts.log"

# add timestamp each entry
# Search last 100 line to search keywords and appead to alerts.log
MATCHES=$(tail -n 100 "$LOG_FILE" | grep -iE "$KEYWORDS)"

if [[ -n "$MATCHES" ]]; then
	echo "[$(date)] checking $LOG_FILE for alerts..." >> "$ALERT_FILE"
	echo "$MATCHES" >> "$ALERT_FILE"

	# send notification alerts to mail
	if command -v mail >/dev/null 2>&1; then 
		echo "$MATCHES" | mail -s "[$(date +%Y-%m-%d)] Log Alert from $(hostname)" alertmail@gmail.com
	else 
		echo "mailutils is not installed"
	fi
fi


