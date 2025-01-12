#!/bin/bash

# Network Connectivity Checker Script

# Input file containing the list of targets
targets_file="targets.txt"
# Log file to store ping results
log_file="connectivity_log.txt"

# Check if the targets file exists
if [ ! -f "$targets_file" ]; then
    echo "Error: File $targets_file does not exist."
    exit 1
fi

# Log the start of the connectivity check
echo "$(date): Starting network connectivity check..." >> "$log_file"

# Read each line from the targets file
while IFS= read -r target; do
    if [ -n "$target" ]; then
        # Ping the target with 3 attempts and log the result
        if ping -c 3 "$target" > /dev/null 2>&1; then
            echo "$(date): Host '$target' is reachable." | tee -a "$log_file"
        else
            echo "$(date): Host '$target' is unreachable." | tee -a "$log_file"
            echo "Warning: Host '$target' is unreachable!"
        fi
    fi
done < "$targets_file"

# Log the end of the connectivity check
echo "$(date): Network connectivity check complete." >> "$log_file"
