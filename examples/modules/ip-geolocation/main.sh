#!/bin/bash

##############################################################################
# IP Geolocation Module - Bash
# Get geolocation information for an IP address using the ip-api.com API
# Author: LanManVan Team
##############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get environment variables
IP="$ARG_IP"
FORMAT="${ARG_FORMAT:-text}"

# Validate inputs
if [ -z "$IP" ]; then
    echo -e "${RED}[!]${NC} Error: IP address is required"
    echo "Usage: ip=<ip_address> [format=text|json|csv]"
    exit 1
fi

# Validate IP format (basic check)
if ! [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}[!]${NC} Error: '$IP' is not a valid IP address"
    exit 1
fi

# Validate format
if [[ ! "$FORMAT" =~ ^(text|json|csv)$ ]]; then
    echo -e "${RED}[!]${NC} Error: Invalid format '$FORMAT'. Use: text, json, or csv"
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}[!]${NC} Error: curl is required but not installed"
    exit 1
fi

echo -e "${BLUE}[*]${NC} Fetching geolocation for $IP..."

# Fetch data from ip-api.com
RESPONSE=$(curl -s "http://ip-api.com/json/$IP")

# Check if the API response was successful
if echo "$RESPONSE" | grep -q '"status":"fail"'; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
    echo -e "${RED}[!]${NC} Error: $ERROR_MSG"
    exit 1
fi

# Output based on format
case "$FORMAT" in
    json)
        echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
        ;;
    csv)
        # Check if jq is available
        if command -v jq &> /dev/null; then
            echo "IP,Country,Region,City,Latitude,Longitude,ISP,Organization,AS,Timezone,Mobile,Proxy,Hosting"
            echo "$RESPONSE" | jq -r '[.query, .country, .regionName, .city, .lat, .lon, .isp, .org, .as, .timezone, .mobile, .proxy, .hosting] | @csv'
        else
            # Fallback without jq
            echo "IP,Country,Region,City,Latitude,Longitude,ISP,Organization,AS,Timezone"
            IP_ADDR=$(echo "$RESPONSE" | grep -o '"query":"[^"]*' | cut -d'"' -f4)
            COUNTRY=$(echo "$RESPONSE" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
            REGION=$(echo "$RESPONSE" | grep -o '"regionName":"[^"]*' | cut -d'"' -f4)
            CITY=$(echo "$RESPONSE" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
            LAT=$(echo "$RESPONSE" | grep -o '"lat":[0-9.]*' | cut -d':' -f2)
            LON=$(echo "$RESPONSE" | grep -o '"lon":[0-9.]*' | cut -d':' -f2)
            ISP=$(echo "$RESPONSE" | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
            ORG=$(echo "$RESPONSE" | grep -o '"org":"[^"]*' | cut -d'"' -f4)
            AS=$(echo "$RESPONSE" | grep -o '"as":"[^"]*' | cut -d'"' -f4)
            TZ=$(echo "$RESPONSE" | grep -o '"timezone":"[^"]*' | cut -d'"' -f4)
            echo "$IP_ADDR,$COUNTRY,$REGION,$CITY,$LAT,$LON,$ISP,$ORG,$AS,$TZ"
        fi
        ;;
    *)
        # Text format (default)
        echo ""
        echo -e "${BLUE}[*]${NC} IP Geolocation Information"
        echo "=================================================="
        
        if command -v jq &> /dev/null; then
            IP_ADDR=$(echo "$RESPONSE" | jq -r '.query')
            COUNTRY=$(echo "$RESPONSE" | jq -r '.country')
            CC=$(echo "$RESPONSE" | jq -r '.countryCode')
            REGION=$(echo "$RESPONSE" | jq -r '.regionName')
            CITY=$(echo "$RESPONSE" | jq -r '.city')
            LAT=$(echo "$RESPONSE" | jq -r '.lat')
            LON=$(echo "$RESPONSE" | jq -r '.lon')
            ISP=$(echo "$RESPONSE" | jq -r '.isp')
            ORG=$(echo "$RESPONSE" | jq -r '.org')
            AS=$(echo "$RESPONSE" | jq -r '.as')
            TZ=$(echo "$RESPONSE" | jq -r '.timezone')
            MOBILE=$(echo "$RESPONSE" | jq -r '.mobile')
            PROXY=$(echo "$RESPONSE" | jq -r '.proxy')
            HOSTING=$(echo "$RESPONSE" | jq -r '.hosting')
        else
            IP_ADDR=$(echo "$RESPONSE" | grep -o '"query":"[^"]*' | cut -d'"' -f4)
            COUNTRY=$(echo "$RESPONSE" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
            CC=$(echo "$RESPONSE" | grep -o '"countryCode":"[^"]*' | cut -d'"' -f4)
            REGION=$(echo "$RESPONSE" | grep -o '"regionName":"[^"]*' | cut -d'"' -f4)
            CITY=$(echo "$RESPONSE" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
            LAT=$(echo "$RESPONSE" | grep -o '"lat":[0-9.]*' | cut -d':' -f2)
            LON=$(echo "$RESPONSE" | grep -o '"lon":[0-9.]*' | cut -d':' -f2)
            ISP=$(echo "$RESPONSE" | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
            ORG=$(echo "$RESPONSE" | grep -o '"org":"[^"]*' | cut -d'"' -f4)
            AS=$(echo "$RESPONSE" | grep -o '"as":"[^"]*' | cut -d'"' -f4)
            TZ=$(echo "$RESPONSE" | grep -o '"timezone":"[^"]*' | cut -d'"' -f4)
            MOBILE=$(echo "$RESPONSE" | grep -o '"mobile":[^,}]*' | cut -d':' -f2)
            PROXY=$(echo "$RESPONSE" | grep -o '"proxy":[^,}]*' | cut -d':' -f2)
            HOSTING=$(echo "$RESPONSE" | grep -o '"hosting":[^,}]*' | cut -d':' -f2)
        fi
        
        printf "  %-25s %s\n" "IP Address:" "$IP_ADDR"
        printf "  %-25s %s\n" "Country:" "$COUNTRY"
        printf "  %-25s %s\n" "Country Code:" "$CC"
        printf "  %-25s %s\n" "Region:" "$REGION"
        printf "  %-25s %s\n" "City:" "$CITY"
        printf "  %-25s %s\n" "Latitude:" "$LAT"
        printf "  %-25s %s\n" "Longitude:" "$LON"
        printf "  %-25s %s\n" "ISP:" "$ISP"
        printf "  %-25s %s\n" "Organization:" "$ORG"
        printf "  %-25s %s\n" "AS:" "$AS"
        printf "  %-25s %s\n" "Timezone:" "$TZ"
        printf "  %-25s %s\n" "Mobile:" "$MOBILE"
        printf "  %-25s %s\n" "Proxy:" "$PROXY"
        printf "  %-25s %s\n" "Hosting:" "$HOSTING"
        
        echo "=================================================="
        echo ""
        ;;
esac
