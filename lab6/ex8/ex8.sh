#!/bin/bash

# Log Cleaner Script

log_cleaner() {
    local log_dir=$1
    local cleanup_log="cleanup.log"

    # Check if the directory exists
    if [ ! -d "$log_dir" ]; then
        echo "Error: Directory '$log_dir' does not exist."
        return 1
    fi

    # Create the cleanup log file if it doesn't exist
    touch "$cleanup_log"

    echo "Scanning directory '$log_dir' for log files older than 7 days..."

    # Find .log files older than 7 days and process them
    find "$log_dir" -type f -name "*.log" -mtime +7 | while read -r log_file; do
        echo "Found old log: $log_file"
        read -p "Delete $log_file? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            rm "$log_file"
            echo "$(date): Deleted $log_file" >> "$cleanup_log"
            echo "Deleted: $log_file"
        else
            echo "Skipped: $log_file"
        fi
    done

    echo "Log cleaning process completed. Deleted files are logged in $cleanup_log."
}

# Usage of the function
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log_directory>"
    exit 1
fi

log_cleaner "$1"
