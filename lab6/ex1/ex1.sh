#!/bin/bash

# Check if the correct number of arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_to_check> <directory_to_scan>"
    exit 1
fi

# Assign arguments to variables
file_to_check=$1
directory_to_scan=$2

# Check file permissions for the provided file
if [ -f "$file_to_check" ]; then
    current_permissions=$(stat -f "%A" "$file_to_check")
    if [ "$current_permissions" -gt 644 ]; then
        echo "The file '$file_to_check' has insecure permissions."
        chmod 644 "$file_to_check"
        echo "Permissions have been corrected to rw-r--r--."
    else
        echo "The file '$file_to_check' has secure permissions."
    fi
else
    echo "The file '$file_to_check' does not exist."
    exit 1
fi

# Scan the directory for .sh files and check their executable bit
if [ -d "$directory_to_scan" ]; then
    find "$directory_to_scan" -type f -name "*.sh" | while read -r script_file; do
        if [ ! -x "$script_file" ]; then
            echo "The script '$script_file' is not executable."
        fi
    done
else
    echo "The directory '$directory_to_scan' does not exist."
    exit 1
fi



