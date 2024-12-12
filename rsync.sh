#!/bin/bash

#################################################################################
# Script for Automated Backup Using rsync and API Notification
# Author: Mohamed Naflan
# Email: hello@naflan.dev
# Description: Automates the backup process by syncing files to a remote server,
# logging the transfer details, and sending a notification via API.
#################################################################################

# Define variables
SOURCE_DIR="/var/www/your_source_directory"  # Masked source directory
DEST_DIR="user@your.remote.server:/path/to/backup/destination/"  # Masked destination directory
SSH_KEY="$HOME/.ssh/your_ssh_key"  # Path to SSH key (expanded correctly)
LOG_FILE="/path/to/your_log_directory/backup_log.txt"  # Log file location
API_URL="https://your_api_endpoint.url"  # Masked API URL

# Capture start time
start_time=$(date '+%Y-%m-%d %H:%M:%S')

# Run rsync with stats and capture output
RSYNC_OUTPUT=$(rsync -av --progress --stats -e "ssh -i $SSH_KEY -p 22" "$SOURCE_DIR" "$DEST_DIR")
rsync_exit_code=$?

# Capture end time
end_time=$(date '+%Y-%m-%d %H:%M:%S')

# Determine success based on rsync exit code
if [ $rsync_exit_code -eq 0 ]; then
    success=true
else
    success=false
fi

# Extract the total size of transferred files and convert to GB
raw_size=$(echo "$RSYNC_OUTPUT" | grep "Total transferred file size:" | awk -F: '{print $2}' | xargs)

# Check if raw_size has a valid size unit and convert to GB
if [[ "$raw_size" == *"bytes"* ]]; then
    size_in_gb=$(echo "$raw_size" | awk '{print $1 / (1024^3)}')
elif [[ "$raw_size" == *"Kbytes"* ]]; then
    size_in_gb=$(echo "$raw_size" | awk '{print $1 / 1024^2}')
elif [[ "$raw_size" == *"Mbytes"* ]]; then
    size_in_gb=$(echo "$raw_size" | awk '{print $1 / 1024}')
elif [[ "$raw_size" == *"Gbytes"* ]]; then
    size_in_gb=$(echo "$raw_size" | awk '{print $1}')
else
    size_in_gb="0"
fi

# Format size to two decimal places
total_size=$(printf "%.2f GB" "$size_in_gb")

# Log the date and the transferred size to the log file
echo "[$(date)] Total transferred file size: $total_size" >> "$LOG_FILE"

# JSON payload with function parameters
json_payload=$(cat <<EOF
{
    "success": $success,
    "subject": "System Backup",
    "start_time": "$start_time",
    "end_time": "$end_time",
    "file_name": "Files",
    "file_size": "$total_size",
    "backup_server": "your_backup_server_ip",  # Masked IP
    "backup_name": "System Backup"
}
EOF
)

# Trigger the API call with the JSON payload
curl -X POST -H "Content-Type: application/json" -d "$json_payload" "$API_URL"
curl_exit_code=$?

# Check if curl succeeded
if [ $curl_exit_code -eq 0 ]; then
    echo "API request sent successfully with payload: $json_payload"
else
    echo "Failed to send API request"
fi

# Optional: Print the rsync output for immediate feedback
echo "$RSYNC_OUTPUT"
echo "Transferred size logged to $LOG_FILE"
