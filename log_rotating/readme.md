# Log Rotation Script – Step by Step

This script automates log rotation by archiving old .log files and keeping your log directory clean.
---

## instruction how to create

>> Shebang to define the shell, Added author/date info.
>> Used set -eo pipefail to stop script on errors.
>> Configuration: 
                - Defined LOG_DIR → Log dir path
                - Defined ARCHIVE_ROOT → where compressed logs are stored.
                - Set DAYS_OLD → how many days old logs must be before rotation.
>> Preparation: 
                - Prepare Archive Folder
                - Created timestamped directories (e.g., archive_20250924_211600) inside archives/.
                - Added starting messages before the search operation
>> Find & Compress Old Logs: 
                - Used find to detect .log files older than DAYS_OLD.
                - Compressed each file into .gz format.
                - Deleted the original log after archiving and send status Updates
                - Printed progress and completion messages with timestamps.

## What It Does

>> Looks in /var/log/myapp for .log files.
>> Moves logs older than 7 days into an archives/ subfolder.
>> Compresses them with gzip to save space.
>> Keeps logs organized, prevents your disk from filling up.