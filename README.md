# LanManVan Framework v1.5

A lightweight, Metasploit-inspired modular framework written in Go.  
Supports modules written in **Python 3** and **Bash**.

## Main Features

- Simple module creation (Python 3 / Bash)
- Interactive command-line interface
- Dynamic module loading
- Flexible argument passing
- YAML-based module metadata
- Built-in environment variable support for arguments
- Real-time execution with clear output

## Installation

```sh
gh repo clone Lanmanvan-Org/lmv-suite-ng
cd lmv-suite-ng
./setup.sh
```

### Or from source
```sh
go mod tidy
go build -o lmv main.go
```

Alternative (one-liner setup):

```sh
chmod +x ./setup.sh && ./setup.sh
```

## Basic Usage

```sh
lmv -banner  # to show banner
```

### Or

```sh
./lanmanvan
```

or with custom modules path:

```sh
./lanmanvan -modules ./custom_modules
```

## Available Commands
