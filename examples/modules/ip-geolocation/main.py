#!/usr/bin/env python3
"""
IP Geolocation Module - Python
Get geolocation information for an IP address using the ip-api.com API
Author: LanManVan Team
"""

import os
import sys
import json
import urllib.request
import urllib.error
import socket
import ipaddress

def get_env_var(name, default=None):
    """Get environment variable with ARG_ prefix"""
    return os.getenv(f'ARG_{name}', default)

def is_valid_ip(ip):
    """Validate IP address"""
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False

def get_geolocation(ip):
    """Fetch geolocation data from ip-api.com"""
    try:
        # Using free tier endpoint (limited to 45 requests per minute)
        url = f"http://ip-api.com/json/{ip}"
        
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data
    except urllib.error.URLError as e:
        print(f"[!] Network error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Error fetching geolocation: {e}")
        sys.exit(1)

def print_text_format(data):
    """Print geolocation data in text format"""
    print()
    print("[*] IP Geolocation Information")
    print("=" * 50)
    
    if data.get('status') == 'fail':
        print(f"[!] Error: {data.get('message', 'Unknown error')}")
        return
    
    fields = {
        'IP Address': 'query',
        'Country': 'country',
        'Country Code': 'countryCode',
        'Region': 'regionName',
        'City': 'city',
        'Latitude': 'lat',
        'Longitude': 'lon',
        'ISP': 'isp',
        'Organization': 'org',
        'AS': 'as',
        'Timezone': 'timezone',
        'Mobile': 'mobile',
        'Proxy': 'proxy',
        'Hosting': 'hosting'
    }
    
    for label, key in fields.items():
        value = data.get(key, 'N/A')
        print(f"  {label:.<20} {value}")
    
    print("=" * 50)
    print()

def print_json_format(data):
    """Print geolocation data in JSON format"""
    print(json.dumps(data, indent=2))

def print_csv_format(data):
    """Print geolocation data in CSV format"""
    if data.get('status') == 'fail':
        print(f"Error: {data.get('message', 'Unknown error')}")
        return
    
    csv_fields = [
        'query', 'country', 'countryCode', 'regionName', 'city',
        'lat', 'lon', 'isp', 'org', 'as', 'timezone', 'mobile', 'proxy', 'hosting'
    ]
    
    # Header
    print(",".join(csv_fields))
    
    # Data
    values = [str(data.get(field, '')) for field in csv_fields]
    print(",".join(values))

def main():
    ip = get_env_var('IP')
    output_format = get_env_var('FORMAT', 'text').lower()
    
    if not ip:
        print("[!] Error: IP address is required")
        print("Usage: ip=<ip_address> [format=text|json|csv]")
        sys.exit(1)
    
    if not is_valid_ip(ip):
        print(f"[!] Error: '{ip}' is not a valid IP address")
        sys.exit(1)
    
    if output_format not in ['text', 'json', 'csv']:
        print(f"[!] Error: Invalid format '{output_format}'. Use: text, json, or csv")
        sys.exit(1)
    
    print(f"[*] Fetching geolocation for {ip}...")
    data = get_geolocation(ip)
    
    if output_format == 'json':
        print_json_format(data)
    elif output_format == 'csv':
        print_csv_format(data)
    else:
        print_text_format(data)

if __name__ == "__main__":
    main()
