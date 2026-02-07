#!/bin/bash
# Bash Example Module
# Educational module demonstrating shell scripting capabilities
# Author: LanManVan Team

set -e  # Exit on error

# Get arguments from environment variables
HOSTS="${ARG_HOSTS:-}"
COUNT="${ARG_COUNT:-3}"
VERBOSE="${ARG_VERBOSE:-false}"

# Validate inputs
if [[ -z "$HOSTS" ]]; then
    echo "[!] Error: HOSTS is required"
    exit 1
fi

echo ""
echo "[*] Bash Example Module"
echo "[*] Hosts: $HOSTS"
echo "[*] Ping Count: $COUNT"
echo "[*] Verbose: $VERBOSE"
echo ""

# Convert comma-separated hosts to array
IFS=',' read -ra HOST_ARRAY <<< "$HOSTS"

SUCCESS_COUNT=0
TOTAL_COUNT=0

# Process each host
for host in "${HOST_ARRAY[@]}"; do
    # Trim whitespace
    host=$(echo "$host" | xargs)
    
    if [[ -z "$host" ]]; then
        continue
    fi
    
    ((TOTAL_COUNT++))
    
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[*] Pinging $host..."
    fi
    
    # Ping the host (suppress output)
    if ping -c "$COUNT" "$host" > /dev/null 2>&1; then
        echo "[+] $host - REACHABLE"
        ((SUCCESS_COUNT++))
    else
        echo "[-] $host - UNREACHABLE"
    fi
done

echo ""
echo "[*] Results: $SUCCESS_COUNT/$TOTAL_COUNT hosts are reachable"
echo "[+] Bash module execution completed successfully!"
echo ""

exit 0
