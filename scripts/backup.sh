
#!/bin/bash

# Automated Backup System
# Purpose: Compress log files and manage old backups.

set -Eeuo pipefail

# Identify the project directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Define directories
SOURCE_DIR="$ROOT_DIR/sample-logs"
BACKUP_DIR="$ROOT_DIR/backups"
LOG_DIR="$ROOT_DIR/logs"

# Load environment configuration
if [[ -f "$ROOT_DIR/.env" ]]; then
    set -a
    source "$ROOT_DIR/.env"
    set +a
fi

# Default retention period: 7 days
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Create required directories
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Log execution messages
LOG_FILE="$LOG_DIR/backup.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Validate retention setting
if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: RETENTION_DAYS must be a non-negative integer."
    exit 1
fi

# Check source directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_message "ERROR: Source directory does not exist."
    exit 1
fi

# Generate timestamp
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

# Define backup filename
ARCHIVE="$BACKUP_DIR/logs_backup_$TIMESTAMP.tar.gz"

log_message "Starting backup process."

# Find log files
mapfile -d '' LOG_FILES < <(
    find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.log" -print0
)

# Stop if no log files exist
if [[ ${#LOG_FILES[@]} -eq 0 ]]; then
    log_message "No log files found. Backup skipped."
    exit 0
fi

# Compress log files
if tar -czf "$ARCHIVE" -C "$SOURCE_DIR" \
    -- "${LOG_FILES[@]##*/}"; then

    log_message "Backup completed: $ARCHIVE"
else
    log_message "ERROR: Backup failed."
    exit 1
fi

# Delete backups older than the retention period
find "$BACKUP_DIR" -type f -name "logs_backup_*.tar.gz" \
    -mtime "+$RETENTION_DAYS" -delete

log_message "Old backup cleanup completed."

# Optional webhook notification
if [[ -n "${WEBHOOK_URL:-}" ]]; then
    if curl -fsS --connect-timeout 10 \
        -X POST \
        -H "Content-Type: text/plain" \
        --data "Backup completed: $ARCHIVE" \
        "$WEBHOOK_URL" >/dev/null; then

        log_message "Webhook notification sent."
    else
        log_message "WARNING: Webhook notification failed."
    fi
fi

log_message "Backup process finished successfully."
