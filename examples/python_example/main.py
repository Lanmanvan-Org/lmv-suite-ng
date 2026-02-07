#!/usr/bin/env python3
"""
Python Example Module
Educational module demonstrating LanManVan module structure
Author: LanManVan Team
"""

import os
import sys
import socket
import time

def get_env_var(name, default=None):
    """Helper to get environment variables with ARG_ prefix"""
    return os.getenv(f'ARG_{name}', default)

def main():
    # Get arguments from environment variables
    target = get_env_var('TARGET')
    port = get_env_var('PORT', '80')
    timeout = get_env_var('TIMEOUT', '5')
    
    if not target:
        print("[!] Error: TARGET is required")
        sys.exit(1)
    
    print()
    print("[*] Python Example Module")
    print(f"[*] Target: {target}")
    print(f"[*] Port: {port}")
    print(f"[*] Timeout: {timeout}s")
    print()
    
    try:
        # Validate port
        try:
            port_num = int(port)
            if not (1 <= port_num <= 65535):
                raise ValueError("Port must be between 1 and 65535")
        except ValueError as e:
            print(f"[!] Invalid port: {e}")
            sys.exit(1)
        
        # Attempt connection
        print(f"[*] Attempting connection to {target}:{port}...")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(float(timeout))
        
        result = sock.connect_ex((target, port_num))
        sock.close()
        
        if result == 0:
            print(f"[+] Connection successful on {target}:{port}")
            print(f"[+] Host is reachable")
        else:
            print(f"[-] Connection failed on {target}:{port}")
            print(f"[-] Host may not be reachable or port is closed")
        
        print()
        print("[+] Python module execution completed successfully!")
        
    except socket.gaierror:
        print(f"[!] Error: Could not resolve hostname '{target}'")
        sys.exit(1)
    except socket.timeout:
        print(f"[!] Error: Connection timeout after {timeout}s")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Error: {type(e).__name__}: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
