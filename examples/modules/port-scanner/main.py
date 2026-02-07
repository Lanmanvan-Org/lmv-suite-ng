#!/usr/bin/env python3
"""
Port Scanner Module - Python
Scan ports on a host to find open services
Author: LanManVan Team
"""

import os
import sys
import socket
import threading
import queue
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

def get_env_var(name, default=None):
    """Get environment variable with ARG_ prefix"""
    return os.getenv(f'ARG_{name}', default)

def is_valid_host(host):
    """Validate hostname or IP address"""
    try:
        socket.gethostbyname(host)
        return True
    except socket.gaierror:
        return False

def parse_ports(port_spec):
    """Parse port specification (e.g., '22,80,443' or '1-1000')"""
    ports = []
    
    for part in port_spec.split(','):
        part = part.strip()
        
        if '-' in part:
            # Range specification
            try:
                start, end = map(int, part.split('-'))
                ports.extend(range(start, end + 1))
            except ValueError:
                print(f"[!] Invalid port range: {part}")
                sys.exit(1)
        else:
            # Single port
            try:
                port = int(part)
                if 1 <= port <= 65535:
                    ports.append(port)
                else:
                    print(f"[!] Port out of range: {port}")
                    sys.exit(1)
            except ValueError:
                print(f"[!] Invalid port: {part}")
                sys.exit(1)
    
    return sorted(list(set(ports)))  # Remove duplicates and sort

def scan_port(host, port, timeout):
    """Attempt to connect to a single port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((host, port))
        sock.close()
        return port, result == 0
    except socket.timeout:
        return port, False
    except Exception:
        return port, False

def get_service_name(port):
    """Get common service name for a port"""
    common_services = {
        21: "FTP",
        22: "SSH",
        23: "Telnet",
        25: "SMTP",
        53: "DNS",
        80: "HTTP",
        110: "POP3",
        143: "IMAP",
        443: "HTTPS",
        445: "SMB",
        3306: "MySQL",
        3389: "RDP",
        5432: "PostgreSQL",
        5900: "VNC",
        8080: "HTTP-Alt",
        8443: "HTTPS-Alt",
        27017: "MongoDB",
        6379: "Redis",
    }
    return common_services.get(port, "-")

def main():
    host = get_env_var('HOST')
    port_spec = get_env_var('PORTS', '1-1000')
    timeout = float(get_env_var('TIMEOUT', '2'))
    max_threads = int(get_env_var('THREADS', '5'))
    
    if not host:
        print("[!] Error: HOST is required")
        print("Usage: host=<hostname> [ports=22,80,443] [timeout=2] [threads=5]")
        sys.exit(1)
    
    if not is_valid_host(host):
        print(f"[!] Error: Cannot resolve hostname '{host}'")
        sys.exit(1)
    
    # Get resolved IP
    try:
        ip = socket.gethostbyname(host)
    except socket.gaierror:
        print(f"[!] Error: Cannot resolve hostname '{host}'")
        sys.exit(1)
    
    print()
    print(f"[*] Scanning {host} ({ip})")
    print(f"[*] Ports: {port_spec}")
    print(f"[*] Timeout: {timeout}s | Threads: {max_threads}")
    print("=" * 60)
    
    ports = parse_ports(port_spec)
    
    if not ports:
        print("[!] No valid ports specified")
        sys.exit(1)
    
    open_ports = []
    start_time = time.time()
    
    # Scan ports with thread pool
    with ThreadPoolExecutor(max_workers=max_threads) as executor:
        futures = {
            executor.submit(scan_port, ip, port, timeout): port
            for port in ports
        }
        
        completed = 0
        for future in as_completed(futures):
            port, is_open = future.result()
            completed += 1
            
            # Show progress
            if (completed % max(1, len(ports) // 10)) == 0 or completed == len(ports):
                print(f"[*] Progress: {completed}/{len(ports)} ports scanned...", end='\r')
            
            if is_open:
                service = get_service_name(port)
                open_ports.append((port, service))
    
    elapsed = time.time() - start_time
    
    print()
    print("=" * 60)
    
    if open_ports:
        print(f"\n[+] Found {len(open_ports)} open port(s):\n")
        for port, service in sorted(open_ports):
            print(f"  {port:<6} {service}")
    else:
        print("\n[!] No open ports found")
    
    print(f"\n[*] Scan completed in {elapsed:.2f}s\n")

if __name__ == "__main__":
    main()
