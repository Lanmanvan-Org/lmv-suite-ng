<code>
# LanManVan — Module Context Guide (`use`, `set`, `run`)

This guide explains how to use module context, scoped variables, and smart execution in **LanManVan CLI v2.0+**.

---

## Core Concepts

**Global Variables**
- Set with `VAR=value`
- Available everywhere

**Module Context**
- Activated with `use &lt;module&gt;`

**Module Variables**
- Set with `set key value`
- Exist only while the module is active

**Smart Expansion**
- Use `$var` or `@var` to reference values

**Variable Resolution Rules**
- Inside a module: `@var` = module variable
- Outside a module: `@var` = global variable

---

## Basic Workflow

### 1. Select a module
`use ip-geolocation`

### 2. Set module-specific options
`set ip 8.8.8.8`

### 3. Run it
`run`

---

## `use` — Activate a Module

**Command** | **Description**
--- | ---
use nmap-scan | Switch to nmap-scan module
use | Show currently selected module
use xss-test | Switch to xss-test module

`OK` Prompt changes to:

`[xss-test] user@host❯`

---

## `set` — Configure Module Variables

Set options that persist for the current module session.

### Examples
```sh
use ip-geolocation  
set ip 142.250.185.206  
set timeout 10  
```

```sh
use http-enum  
set url https://example.com  
set threads 5  
set wordlist /path/to/words.txt  
```
---

### List Current Module Variables

set

- Shows all `key=value` pairs for the active module.

---

### Expand Global Variables in `set`
```sh
ip=192.168.1.10   # set global variable

use nmap-scan  
set target $ip    # module.target = 192.168.1.10  
set host @ip      # same as above
```
`OK` Both `$ip` and `@ip` resolve to **global variables** when used in `set`.

---

## `run` — Execute the Current Module

Runs the active module with all configured options.

### Examples
```sh
use ip-geolocation  
set ip 8.8.8.8  
run
```

```sh
use http-enum  
set url https://test.com  
run threads=10
```

```sh
use nmap-scan  
run target=10.0.0.5 ports=22,80,443
```
---

### Argument Priority

1. CLI args (`run x=y`)  

2. Module vars (`set x y`)  
  
3. Global vars (`x=value`)

---

## Global vs Module Variables

### Set & Inspect Global Variables
```sh
ip=154.32.32.32  
ip=?  
@ip
```
---

### Inside a Module
```sh
use ip-geolocation  
set ip 122.122.32.23  

ip=?     # shows GLOBAL ip  
@ip      # shows MODULE ip  

ip=@ip   # promote module value to global scope `OK`
```
---

## Chaining Modules (Real-World Example)

### Step 1: Resolve domain to IP
```sh
use dns-resolve  
set domain google.com  
run  
```
Output:
```
IP = 142.250.185.206
```
### Step 2: Promote result to global
```sh
ip=@ip
```
### Step 3: Reuse in another module
```sh
use ip-geolocation  
run
```
---

### Faster Chain
```sh
use dns-resolve  
set domain github.com  
run  
```

```sh
use ip-geolocation  
set ip @ip  
run
```
---

## Special Flags (set or run)

**Flag** | **Effect**
--- | ---
threads=N | Parallel execution
save=true | Save output to log file
timeout=30 | Execution timeout

### Example
```sh
use port-scan  
set target 192.168.1.1  
run threads=20 save=true
```
---

## Quick Info Commands

**Command** | **Inside Module** | **Outside Module**
--- | --- | ---
info | Show module info | Error
! | Quick module info | Error

---

## Pro Tips

- Reuse results with `@output` (module-dependent)
- `run url=x` does NOT overwrite `set url`
- Switch modules to reset context
- Pre-set globals via shell:
  `$ ip=1.2.3.4 lmv`

---

## Goal

Do more with fewer keystrokes.  
No repetition. No friction.

**Happy hacking! 💥**  
— hmza

