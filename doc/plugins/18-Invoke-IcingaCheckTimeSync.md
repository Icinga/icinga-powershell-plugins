
# Invoke-IcingaCheckTimeSync

## Description

Gets Network Time Protocol time(SNTP/NTP) from a specified server

Invoke-IcingaCheckTimeSync connects to an NTP server on UDP default port 123 and retrieves the current NTP time.
Selected components of the returned time information are decoded and returned in a hashtable.

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Server | String | false |  | The NTP Server you want to connect to. |
| TimeOffset | Object | false | 0 | The maximum acceptable offset between the local clock and the NTP Server, in seconds e.g. if you allow up to 0.5s timeoffset you can also enter 500ms. Invoke-IcingaCheckTimeSync will return OK, if there is no difference between them, WARNING, if the time difference exceeds the Warning threshold, CRITICAL, if the time difference exceeds the Critical threshold. |
| Warning | Object | false |  | Used to specify a offset Warning threshold e.g 10ms or 0.01s |
| Critical | Object | false |  | Used to specify a offset Critical threshold e.g 20ms or 0.02s. |
| Timeout | Int32 | false | 10 | Seconds before connection times out (default: 10) |
| IPV4 | SwitchParameter | false | False | Use IPV4 connection. Default $FALSE |
| Port | Int32 | false | 123 | Port number (default: 123) |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckTimeSync -Server '0.pool.ntp.org' -TimeOffset 10ms -Warning 10ms -Critical 20ms -Verbosity 2
```

### Example Output 1

```powershell
\_ [OK] Check package "Time Package" (Match All)\_ [OK] Sync Status: NoLeapWarning\_ [WARNING] Time Offset: Value "0.02s" is greater than threshold "0.01s"\_ [OK] Time Service: Running| 'time_offset'=0.02s;0.01;0.02 'time_service'=4;;4 0
```

### Example Command 2

```powershell
Invoke-IcingaCheckTimeSync -Server 'time.versatel.de' -TimeOffset 50ms -Warning 10ms -Critical 20ms -Verbosity 2
```

### Example Output 2

```powershell
\_ [OK] Sync Status: NoLeapWarning\_ [OK] Time Offset: 0s\_ [OK] Time Service: Running| 'time_offset'=0s;0.01;0.02 'time_service'=4;;4 1
```
