#!/bin/bash

# Backup Automation Script

# Define the backup location
backup_location="./backup"

# Check if a directory path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Get the directory path and name
directory_path="$1"
directory_name=$(basename "$directory_path")

# Create a timestamped filename for the backup
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
backup_file="${directory_name}_backup_${timestamp}.tar.gz"

# Check if the backup location exists, create if not
if [ ! -d "$backup_location" ]; then
    mkdir -p "$backup_location"
fi

# Compress the directory
echo "Compressing directory $directory_path into $backup_file..."
tar -czf "$backup_file" -C "$(dirname "$directory_path")" "$directory_name"

# Move the compressed file to the backup location
echo "Moving backup file to $backup_location..."
mv "$backup_file" "$backup_location"

# Confirm completion
echo "Backup complete. File saved to $backup_location/$backup_file"
