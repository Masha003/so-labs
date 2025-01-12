#!/bin/bash

# Define the log file
LOG_FILE="process_log.txt"

# Get the current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Log the header with timestamp
echo "Process Tracker Log - $TIMESTAMP" >> "$LOG_FILE"
echo "===================================================" >> "$LOG_FILE"

# List processes sorted by memory usage and highlight the top 5
echo "Top 5 processes by memory usage:" >> "$LOG_FILE"
ps aux | awk 'NR>1 {print $0}' | sort -rk 4 | head -n 5 >> "$LOG_FILE"

# Add a footer to separate logs
echo "===================================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Print a message to the user
echo "Process log saved to $LOG_FILE"
