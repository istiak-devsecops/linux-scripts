#!/bin/bash

####################################
# Author: Istiak
# Date and time: 27 Aug 2025 9:16PM
####################################

set -eo pipefail

# === CONFIGURATION ===
LOG_FILE="/var/log/syslog"
KEYWORDS="error|failed|denied"
ALERT_FILE="alerts.log"

# === FIND AND STORE RESULT IN VARIABLE ===
MATCHES=$(tail -n 100 "$LOG_FILE" | grep -iE "$KEYWORDS")

# === STORE RESULT IN A FILE ===
if [[ -n "$MATCHES" ]]; then
	echo "[$(date)] checking $LOG_FILE for alerts..." >> "$ALERT_FILE"
	echo "$MATCHES" >> "$ALERT_FILE"

# === SEND EMAIL ALERT ===
	if command -v mail >/dev/null 2>&1; then 
		echo "$MATCHES" | mail -s "[$(date +%Y-%m-%d)] Log Alert from $(hostname)" alertmail@gmail.com
	else 
		echo "mailutils is not installed"
	fi
fi


