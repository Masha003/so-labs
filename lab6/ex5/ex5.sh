#!/bin/bash

# Function to check and restart services if needed
service_status_checker() {
    # If no arguments are provided, use a default set of services
    if [ "$#" -eq 0 ]; then
        services=("nginx" "ssh" "cron")
    else
        services=("$@")
    fi

    # Log file to store service status
    log_file="service_status.log"

    # Log the start of the check
    echo "$(date): Starting service status check..." >> "$log_file"

    # Loop through each service and check its status
    for service in "${services[@]}"; do
        # Check if the service is running
        status=$(launchctl list | grep -q "$service" && echo "running" || echo "not running")
        echo "$(date): Service '$service' is $status." >> "$log_file"

        if [ "$status" = "not running" ]; then
            echo "$(date): Service '$service' is not running. Restarting..." | tee -a "$log_file"
            # Try to load and start the service
            sudo launchctl load -w "/Library/LaunchDaemons/${service}.plist" 2>/dev/null
            sudo launchctl start "$service" 2>/dev/null

            # Check if the restart was successful
            if launchctl list | grep -q "$service"; then
                echo "$(date): Service '$service' restarted successfully." >> "$log_file"
            else
                echo "$(date): Failed to restart service '$service'." >> "$log_file"
            fi
        fi
    done

    # Log the completion of the check
    echo "$(date): Service status check complete." >> "$log_file"
}

# Call the function with all script arguments
service_status_checker "$@"
