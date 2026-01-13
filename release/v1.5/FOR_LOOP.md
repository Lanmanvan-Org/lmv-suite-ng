# Here we go!

---


## 1. Classic port scan on one target
for $p in 1..1024 -> nmap -p$p -sV 10.10.10.50

## 2. Most common - sweep last octet (comming soon)
for $ip in 192.168.1.1..192.168.1.254 -> ping -c1 -W1 $ip

## 3. Small subnet sweep (comming soon)
for $ip in 10.10.50.100..10.10.50.150 -> nmap -sS -T4 $ip

## 4. Username / vhost / subdomain brute
for $u in admin\|root\|test\|backup\|dev -> hydra -l $u -P pass.txt ssh://10.10.10.10

## 5. Basic charset for password generation / testing
for $c in a..z+0..9 -> echo "trying: pass$c"

## 6. Hex digits (very useful)
for $h in 0..9+A..F -> echo "hex digit: $h"

## 7. Multiple ranges combined
for $c in a..z+A..Z+0..9 -> touch "file_$c.txt"

---

# More!

# 🔄 Loop Command Guide

The CLI supports powerful for loops to automate tasks over ranges, lists, or structured data files.

## Load Data from Files

- Use $cat("file") to read from .txt, .json, or .yaml files.

### Text File
File: /tmp/urls.txt
```txt
https://site1.com
https://site2.com
```

Command:
`for url in $cat("/tmp/urls.txt") -> curl -I $url`

### YAML / JSON Objects
```txt
File: targets.yaml
- name: Web Server
  host: 192.168.1.10
  port: 80
- name: Database
  host: 192.168.1.20
  port: 1433
```

Command:
`for t in $cat("targets.yaml") -> nmap -p $(t->port) $(t->host); echo "Scanning $(t->name)"`

## 💡 Syntax Notes
- Use $var or {var}
- Use $(var->field) for object fields
- Field names must be alphanumeric + underscore
- Empty lines are skipped

## 🧪 Examples

```py
for url in $cat("~/recon/urls.txt") -> header-enum url=$url

for s in $cat("services.yaml") -> port-enum ip=$(s->ip) port=$(s->port)

for u in $cat("users.txt") -> hydra -l $u -P passwords.txt 10.0.0.5 ssh
```
## 🔒 Tip
`for ip in $cat("ips.txt") -> #proxychains nmap $ip`


