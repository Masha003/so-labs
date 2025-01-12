#!/bin/bash

# Define the log file
LOG_FILE="disk_usage.log"

# Get the current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Check disk usage using df
df -h | awk 'NR>1 {print $5, $6}' | while read -r usage partition; do
    # Remove the '%' from the usage value
    usage_value=${usage%\%}
    
    # Check if usage is above 80%
    if [ "$usage_value" -gt 80 ]; then
        # Display a warning message
        echo "Warning: Partition $partition is above 80% usage."
        # Log the warning with a timestamp
        echo "$TIMESTAMP - Warning: Partition $partition is above 80% usage." >> "$LOG_FILE"
    fi
done

# Log the completion of the check
echo "$TIMESTAMP - Disk usage check completed." >> "$LOG_FILE"




