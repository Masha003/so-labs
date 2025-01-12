#!/bin/bash

# File to log directory sizes
LOG_FILE="dir_size_audit.log"

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

TARGET_DIR="$1"

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

# Log the analysis start
echo "Analyzing directory sizes in: $TARGET_DIR" > "$LOG_FILE"

# Analyze sizes of all subdirectories and find the top 5 largest
du -sh "$TARGET_DIR"/* 2>/dev/null | sort -rh | head -n 5 | while read -r size dir; do
    # Extract the directory name using basename
    dir_name=$(basename "$dir")
    echo "Directory: $dir_name, Size: $size" >> "$LOG_FILE"
done

# Notify the user
echo "Directory size analysis completed. Results logged in $LOG_FILE."
