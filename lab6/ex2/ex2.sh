#!/bin/bash

# Check if the correct number of arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_to_check> <directory_to_scan>"
    exit 1
fi

# Assign arguments to variables
file_to_check=$1
directory_to_scan=$2

# Verify that the file exists
if [ ! -f "$file_to_check" ]; then
    echo "The file '$file_to_check' does not exist."
    exit 1
fi

# Verify that the directory exists
if [ ! -d "$directory_to_scan" ]; then
    echo "The directory '$directory_to_scan' does not exist."
    exit 1
fi

# Compute MD5 hash of the file to check
file_hash=$(md5sum "$file_to_check" | awk '{print $1}')

# Search for files with the same name in the specified directory
found_match=false
find "$directory_to_scan" -type f -name "$(basename "$file_to_check")" | while read -r match; do
    # Compute MD5 hash for the found file
    match_hash=$(md5sum "$match" | awk '{print $1}')

    # Compare the hashes
    if [ "$file_hash" == "$match_hash" ]; then
        echo "File integrity verified for '$match'."
        found_match=true
    fi
done

# Check if any match was found
if [ "$found_match" == false ]; then
    echo "File integrity compromised or file not found."
fi
