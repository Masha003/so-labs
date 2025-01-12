#!/bin/bash

cron_job_monitor() {
    local user=$1
    local log_file="/var/log/system.log"
    local failure_log="cron_failures.log"
    local current_date=$(date -v-1d +"%b %_d") # Date for the past 24 hours (macOS format)

    echo "$(date): Checking cron jobs for user '$user'..." >> "$failure_log"

    # Check if the user has active cron jobs
    crontab -l -u "$user" 2>/dev/null | while read -r job; do
        # Skip empty lines or comments
        if [[ -z "$job" || "$job" == \#* ]]; then
            continue
        fi

        # Extract the command part of the cron job
        job_command=$(echo "$job" | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed 's/^ *//')

        # Check the system log for the job command
        grep "$current_date" "$log_file" | grep -q "$job_command"

        if [ $? -ne 0 ]; then
            echo "$(date): Cron job failed or did not run: $job_command" >> "$failure_log"
        fi
    done

    echo "$(date): Cron job monitoring completed for user '$user'." >> "$failure_log"
}

# Usage of the script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Run the cron job monitor function
cron_job_monitor "$1"
