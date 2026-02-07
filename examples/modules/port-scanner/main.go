package main

import (
	"fmt"
	"net"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

type PortResult struct {
	Port    int
	Open    bool
	Service string
}

func getEnvVar(name, defaultVal string) string {
	if val := os.Getenv("ARG_" + strings.ToUpper(name)); val != "" {
		return val
	}
	return defaultVal
}

func isValidHost(host string) bool {
	_, err := net.LookupHost(host)
	return err == nil
}

func resolveHost(host string) (string, error) {
	addrs, err := net.LookupHost(host)
	if err != nil {
		return "", err
	}
	if len(addrs) > 0 {
		return addrs[0], nil
	}
	return "", fmt.Errorf("no addresses found")
}

func parsePorts(portSpec string) ([]int, error) {
	ports := make(map[int]bool)

	for _, part := range strings.Split(portSpec, ",") {
		part = strings.TrimSpace(part)

		if strings.Contains(part, "-") {
			// Range specification
			parts := strings.Split(part, "-")
			if len(parts) != 2 {
				return nil, fmt.Errorf("invalid port range: %s", part)
			}

			start, err1 := strconv.Atoi(strings.TrimSpace(parts[0]))
			end, err2 := strconv.Atoi(strings.TrimSpace(parts[1]))

			if err1 != nil || err2 != nil {
				return nil, fmt.Errorf("invalid port range: %s", part)
			}

			for p := start; p <= end; p++ {
				if p >= 1 && p <= 65535 {
					ports[p] = true
				}
			}
		} else {
			// Single port
			port, err := strconv.Atoi(part)
			if err != nil {
				return nil, fmt.Errorf("invalid port: %s", part)
			}
			if port >= 1 && port <= 65535 {
				ports[port] = true
			}
		}
	}

	var result []int
	for port := range ports {
		result = append(result, port)
	}
	sort.Ints(result)
	return result, nil
}

func scanPort(host string, port int, timeout time.Duration, results chan PortResult) {
	address := fmt.Sprintf("%s:%d", host, port)
	conn, err := net.DialTimeout("tcp", address, timeout)

	isOpen := err == nil
	if conn != nil {
		conn.Close()
	}

	results <- PortResult{
		Port:    port,
		Open:    isOpen,
		Service: getServiceName(port),
	}
}

func getServiceName(port int) string {
	services := map[int]string{
		21:    "FTP",
		22:    "SSH",
		23:    "Telnet",
		25:    "SMTP",
		53:    "DNS",
		80:    "HTTP",
		110:   "POP3",
		143:   "IMAP",
		443:   "HTTPS",
		445:   "SMB",
		3306:  "MySQL",
		3389:  "RDP",
		5432:  "PostgreSQL",
		5900:  "VNC",
		8080:  "HTTP-Alt",
		8443:  "HTTPS-Alt",
		27017: "MongoDB",
		6379:  "Redis",
	}

	if service, ok := services[port]; ok {
		return service
	}
	return "-"
}

func main() {
	host := getEnvVar("host", "")
	portSpec := getEnvVar("ports", "1-1000")
	timeout := time.Duration(2) * time.Second
	maxThreads := 5

	if timeoutStr := getEnvVar("timeout", ""); timeoutStr != "" {
		if t, err := strconv.ParseInt(timeoutStr, 10, 64); err == nil {
			timeout = time.Duration(t) * time.Second
		}
	}

	if threadsStr := getEnvVar("threads", ""); threadsStr != "" {
		if t, err := strconv.Atoi(threadsStr); err == nil {
			maxThreads = t
		}
	}

	if host == "" {
		fmt.Println("[!] Error: HOST is required")
		fmt.Println("Usage: host=<hostname> [ports=22,80,443] [timeout=2] [threads=5]")
		os.Exit(1)
	}

	// Resolve hostname
	ip, err := resolveHost(host)
	if err != nil {
		fmt.Printf("[!] Error: Cannot resolve hostname '%s'\n", host)
		os.Exit(1)
	}

	// Parse ports
	ports, err := parsePorts(portSpec)
	if err != nil {
		fmt.Printf("[!] Error: %v\n", err)
		os.Exit(1)
	}

	if len(ports) == 0 {
		fmt.Println("[!] Error: No valid ports specified")
		os.Exit(1)
	}

	fmt.Println()
	fmt.Printf("[*] Scanning %s (%s)\n", host, ip)
	fmt.Printf("[*] Ports: %s\n", portSpec)
	fmt.Printf("[*] Timeout: %ds | Threads: %d\n", timeout/time.Second, maxThreads)
	fmt.Println(strings.Repeat("=", 60))

	// Perform scan with concurrency control
	results := make(chan PortResult, len(ports))
	var wg sync.WaitGroup
	semaphore := make(chan struct{}, maxThreads)

	startTime := time.Now()

	for _, port := range ports {
		wg.Add(1)
		go func(p int) {
			defer wg.Done()
			semaphore <- struct{}{}        // Acquire
			defer func() { <-semaphore }() // Release

			scanPort(ip, p, timeout, results)
		}(port)
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	// Collect results
	var openPorts []PortResult
	scanned := 0

	for result := range results {
		scanned++
		if result.Open {
			openPorts.append(result)
		}

		// Progress
		if scanned%max(1, len(ports)/10) == 0 || scanned == len(ports) {
			fmt.Printf("[*] Progress: %d/%d ports scanned...\r", scanned, len(ports))
		}
	}

	elapsed := time.Since(startTime)

	fmt.Println()
	fmt.Println(strings.Repeat("=", 60))

	if len(openPorts) > 0 {
		fmt.Printf("\n[+] Found %d open port(s):\n\n", len(openPorts))

		sort.Slice(openPorts, func(i, j int) bool {
			return openPorts[i].Port < openPorts[j].Port
		})

		for _, result := range openPorts {
			fmt.Printf("  %-6d %s\n", result.Port, result.Service)
		}
	} else {
		fmt.Println("\n[!] No open ports found")
	}

	fmt.Printf("\n[*] Scan completed in %.2fs\n\n", elapsed.Seconds())
}

// Helper for max
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
