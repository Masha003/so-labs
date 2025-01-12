#!/bin/bash

# File to log RAM usage
LOG_FILE="ram_usage.log"

# Duration and interval
DURATION=2 # in minutes
INTERVAL=60 # in seconds

# Function to get RAM usage on macOS
get_memory_usage() {
    # Use vm_stat to calculate memory usage
    local page_size
    page_size=$(vm_stat | grep "page size of" | awk '{print $8}' | tr -d '.')
    local free_pages
    free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
    local active_pages
    active_pages=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
    local inactive_pages
    inactive_pages=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
    local speculative_pages
    speculative_pages=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | tr -d '.')

    local free_memory=$(( (free_pages + speculative_pages) * page_size / 1024 / 1024 ))
    local used_memory=$(( (active_pages + inactive_pages) * page_size / 1024 / 1024 ))
    local total_memory=$(( free_memory + used_memory ))

    echo "$total_memory $used_memory $free_memory"
}

# Initialize log file
echo "Logging RAM usage to $LOG_FILE for $DURATION minutes..." > "$LOG_FILE"

# Loop for the specified duration
for ((i=1; i<=$DURATION; i++)); do
    # Get memory usage
    memory_stats=$(get_memory_usage)
    total_memory=$(echo "$memory_stats" | awk '{print $1}')
    used_memory=$(echo "$memory_stats" | awk '{print $2}')
    free_memory=$(echo "$memory_stats" | awk '{print $3}')

    # Calculate usage percentage
    usage_percentage=$(( 100 * used_memory / total_memory ))

    # Log to file
    echo "$(date): Total: ${total_memory}MB, Used: ${used_memory}MB, Free: ${free_memory}MB, Usage: ${usage_percentage}%" >> "$LOG_FILE"

    # Alert if usage exceeds 50%
    if [ "$usage_percentage" -gt 50 ]; then
        echo "ALERT: Memory usage exceeded 50%! Current usage: ${usage_percentage}%" >> "$LOG_FILE"
        # Example alert (replace with actual mail or other alert mechanism)
        echo "Memory usage alert! Current usage: ${usage_percentage}%" | mail -s "RAM Usage Alert" your_email@example.com
    fi

    # Wait for the interval
    sleep "$INTERVAL"
done

echo "RAM usage monitoring completed." >> "$LOG_FILE"
