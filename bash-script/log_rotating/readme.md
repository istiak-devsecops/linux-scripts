# Log Rotation Script – Step by Step

This script automates log rotation by archiving old .log files and keeping your log directory clean.

## Instruction How to Create

- **Shebang & Header**  
  - Defined the shell with `#!/bin/bash`  
  - Added author/date info for reference  

- **Safety**  
  - Used `set -eo pipefail` to exit on errors  

- **Configuration**  
  - `LOG_FILE` → Path of the log file (`/var/log/syslog`)  
  - `KEYWORDS` → Patterns to search (`error|failed|denied`)  
  - `ALERT_FILE` → File where alerts are saved  

- **Find & Store Results**  
  - Used `tail -n 100` to check the latest 100 log lines  
  - Applied `grep -iE` to match error keywords  
  - Stored matches in a variable `MATCHES`  

- **Store Matches in File**  
  - If matches exist, append timestamp + entries into `alerts.log`  

- **Send Email Alert**  
  - If `mail` is installed → send an email with matches  
  - If not installed → print a warning (`mailutils is not installed`)  


## What It Does

- Looks in /var/log/myapp for .log files.
- Moves logs older than 7 days into an archives/ subfolder.
- Compresses them with gzip to save space.
- Keeps logs organized, prevents your disk from filling up.