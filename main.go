package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"lanmanvan/cli"
)

func main() {
	var modulesDir string
	var version bool
	var versionText string
	versionText = "2.0"

	var exec bool
	var exec_cmd string

	var show_banner bool

	var resourceFile string

	flag.StringVar(&modulesDir, "modules", "./modules", "Path to modules directory (string)")
	flag.BoolVar(&version, "version", false, "Show version (bool)")

	flag.BoolVar(&exec, "idle-exec", false, "Execute command and exit? (bool)")
	flag.StringVar(&exec_cmd, "idle-cmd", "help", "Execute command and exit (string)")

	flag.BoolVar(&show_banner, "banner", false, "Want to show the *lanmanvan* official banner? (bool)")

	flag.StringVar(&resourceFile, "r", "", "Path to resource file (string)")

	flag.Parse()

	if version {
		fmt.Println("lmv-ng %s - Advanced Modular Framework in Go", versionText)
		os.Exit(0)
	}

	// Expand home directory if needed
	if modulesDir == "~" {
		home, err := os.UserHomeDir()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: could not determine home directory: %v\n", err)
			os.Exit(1)
		}
		modulesDir = home
	}

	// Make absolute path
	absPath, err := filepath.Abs(modulesDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: invalid modules path: %v\n", err)
		os.Exit(1)
	}

	// Create CLI instance
	cliInstance := cli.NewCLI(absPath)

	bannerShown := false

	if resourceFile != "" {
		content, err := os.ReadFile(resourceFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

		lines := strings.Split(string(content), "\n")
		var commands []string
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			commands = append(commands, line)
		}

		for _, cmd := range commands {
			b := show_banner && !bannerShown
			if err := cliInstance.IdleStart(b, cmd); err != nil {
				fmt.Fprintf(os.Stderr, "Error: %v\n", err)
				os.Exit(1)
			}
			if b {
				bannerShown = true
			}
		}
	}

	if exec {
		if exec_cmd != "" {
			b := show_banner && !bannerShown
			if err := cliInstance.IdleStart(b, exec_cmd); err != nil {
				fmt.Fprintf(os.Stderr, "Error: %v\n", err)
				os.Exit(1)
			}
		}
		os.Exit(0)
	} else {
		if err := cliInstance.Start(show_banner && !bannerShown); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	}
}
