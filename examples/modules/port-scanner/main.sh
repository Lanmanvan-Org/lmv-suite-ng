#!/bin/bash

##############################################################################
# Port Scanner Module - Bash
# Scan ports on a host to find open services
# Author: LanManVan Team
##############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get environment variables
HOST="$ARG_HOST"
PORTS="${ARG_PORTS:-1-1000}"
TIMEOUT="${ARG_TIMEOUT:-2}"
THREADS="${ARG_THREADS:-5}"

# Validate inputs
if [ -z "$HOST" ]; then
    echo -e "${RED}[!]${NC} Error: HOST is required"
    echo "Usage: host=<hostname> [ports=22,80,443] [timeout=2] [threads=5]"
    exit 1
fi

# Validate host (basic check)
if ! ping -c 1 "$HOST" &> /dev/null; then
    # Try DNS resolution if ping fails
    if ! host "$HOST" &> /dev/null && ! nslookup "$HOST" &> /dev/null; then
        # Skip validation - host might be reachable but don't respond to ping
        :
    fi
fi

# Get resolved IP
IP=$(getent hosts "$HOST" 2>/dev/null | awk '{print $1}')
if [ -z "$IP" ]; then
    IP=$(dig +short "$HOST" @8.8.8.8 2>/dev/null | head -1)
fi
if [ -z "$IP" ]; then
    IP="$HOST"
fi

echo ""
echo -e "${BLUE}[*]${NC} Scanning $HOST ($IP)"
echo -e "${BLUE}[*]${NC} Ports: $PORTS"
echo -e "${BLUE}[*]${NC} Timeout: ${TIMEOUT}s | Threads: $THREADS"
echo "============================================================"

# Function to check if port is open
check_port() {
    local host=$1
    local port=$2
    local timeout=$3
    
    if command -v nc &> /dev/null; then
        # Using netcat
        nc -z -w "$timeout" "$host" "$port" 2>/dev/null && echo "open" || echo "closed"
    elif command -v timeout &> /dev/null; then
        # Using bash with timeout
        (echo > /dev/tcp/"$host"/"$port") &>/dev/null && echo "open" || echo "closed"
    else
        # Fallback: simple bash TCP check
        (echo > /dev/tcp/"$host"/"$port") &>/dev/null && echo "open" || echo "closed"
    fi
}

export -f check_port

# Parse port specification
parse_ports() {
    local port_spec="$1"
    local ports=()
    
    IFS=',' read -ra parts <<< "$port_spec"
    for part in "${parts[@]}"; do
        part=$(echo "$part" | xargs)  # trim whitespace
        
        if [[ $part == *"-"* ]]; then
            # Range
            start=$(echo "$part" | cut -d'-' -f1)
            end=$(echo "$part" | cut -d'-' -f2)
            for ((p=start; p<=end; p++)); do
                ports+=("$p")
            done
        else
            # Single port
            ports+=("$part")
        fi
    done
    
    printf '%s\n' "${ports[@]}"
}

# Function to get service name
get_service_name() {
    local port=$1
    case $port in
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        110) echo "POP3" ;;
        143) echo "IMAP" ;;
        443) echo "HTTPS" ;;
        445) echo "SMB" ;;
        3306) echo "MySQL" ;;
        3389) echo "RDP" ;;
        5432) echo "PostgreSQL" ;;
        5900) echo "VNC" ;;
        8080) echo "HTTP-Alt" ;;
        8443) echo "HTTPS-Alt" ;;
        27017) echo "MongoDB" ;;
        6379) echo "Redis" ;;
        *) echo "-" ;;
    esac
}

# Main scanning logic
declare -a open_ports

# Get all ports to scan
all_ports=($(parse_ports "$PORTS"))

if [ ${#all_ports[@]} -eq 0 ]; then
    echo -e "${RED}[!]${NC} No valid ports specified"
    exit 1
fi

total_ports=${#all_ports[@]}
scanned=0

echo ""

# Scan ports (with parallel processing)
for port in "${all_ports[@]}"; do
    {
        status=$(check_port "$IP" "$port" "$TIMEOUT")
        if [ "$status" = "open" ]; then
            service=$(get_service_name "$port")
            echo "$port|$service"
        fi
    } &
    
    # Limit concurrent processes
    if (( ++scanned % THREADS == 0 )); then
        wait
    fi
    
    # Show progress
    if (( scanned % 50 == 0 )); then
        echo -e "${BLUE}[*]${NC} Progress: $scanned/$total_ports ports scanned..." >&2
    fi
done

# Wait for remaining processes
wait

echo -e "${BLUE}[*]${NC} Progress: $total_ports/$total_ports ports scanned..."

echo "============================================================"
echo ""
echo -e "${GREEN}[+]${NC} Scan results:"
echo ""

# Sort and display results by port number
found=0
while IFS='|' read -r port service; do
    printf "  %-6s %s\n" "$port" "$service"
    ((found++))
done < <(echo "$open_ports" | sort -n)

if [ $found -eq 0 ]; then
    echo -e "  ${YELLOW}No open ports found${NC}"
else
    echo -e "  ${GREEN}Total: $found open port(s)${NC}"
fi

echo ""
