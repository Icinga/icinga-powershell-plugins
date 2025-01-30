# Invoke-IcingaCheckICMP

## Description

Checks via ICMP requests to a target destination for response time and availability

Invoke-IcingaCheckICMP returns 'OK', 'WARNING' or 'CRITICAL' depending on response times
for packet transmition and possible packet loss

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false | 100 | Threshold on which the plugin will return 'WARNING' for the response time in ms |
| Critical | Object | false | 200 | Threshold on which the plugin will return 'CRITICAL' for the response time in ms |
| WarningPl | Object | false | 20 | Threshold on which the plugin will return 'WARNING' for possible packet loss in % |
| CriticalPl | Object | false | 50 | Threshold on which the plugin will return 'CRITICAL' for possible packet loss in % |
| Hostname | String | false |  | The target hosts IP or FQDN to send ICMP requests too |
| PacketCount | Int32 | false | 5 | The amount of packets send to the target host |
| PacketSize | Int32 | false | 64 | The size of each packet send to the target host |
| IPv4 | SwitchParameter | false | False | Force the usage of IPv4 addresses for ICMP calls by using a hostname |
| IPv6 | SwitchParameter | false | False | Force the usage of IPv6 addresses for ICMP calls by using a hostname |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckICMP -Hostname 'example.com';
```

### Example Output 1

```powershell
[OK] Check package "ICMP Check for example.com"
| 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113ms;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv4;
```

### Example Output 2

```powershell
[OK] Check package "ICMP Check for example.com"
| 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113ms;;    
```

### Example Command 3

```powershell
Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv6;
```

### Example Output 3

```powershell
[OK] Check package "ICMP Check for example.com"
| 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113.5ms;;    
```

### Example Command 4

```powershell
Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv4 -Warning 80 -Critical 100 -WarningPl 50 -CriticalPl 75;
```

### Example Output 4

```powershell
[CRITICAL] Check package "ICMP Check for example.com" - [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes
\_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "114ms" is greater than threshold "100ms"
\_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
\_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
\_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
| 'packet_loss'=0%;50;75;0;100 'packet_count'=4c;; 'response_time'=113.25ms;80;100    
```


