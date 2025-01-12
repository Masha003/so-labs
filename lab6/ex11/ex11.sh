open_ports_scanner() {
    # List of expected ports
    expected_ports=(22 80 443)

    # File to track processed ports
    processed_ports_file=$(mktemp)

    # Use netstat to scan open ports
    netstat -an | grep LISTEN | awk '{print $4}' | while read -r address_info; do
        # Extract the port number from the address
        port="${address_info##*.}"

        # Check if the port has already been processed
        if grep -q "^$port$" "$processed_ports_file"; then
            continue
        fi

        # Mark port as processed
        echo "$port" >> "$processed_ports_file"

        # Check if the port is expected or unexpected
        if [[ " ${expected_ports[@]} " =~ " ${port} " ]]; then
            # Retrieve service information (protocol and address)
            service_name=$(netstat -an | grep LISTEN | grep "\.$port " | awk '{print $1, $4}')
            echo "Port $port is open and expected. Service: $service_name" >> open_ports.log
        else
            # Log and display a warning for unexpected ports
            echo "Warning: Port $port is open and unexpected." >> open_ports.log
            echo "Warning: Port $port is open and unexpected."
        fi
    done

    # Cleanup temporary file
    rm -f "$processed_ports_file"
}

# Usage:
open_ports_scanner
