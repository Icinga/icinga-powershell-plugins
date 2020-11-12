
# Invoke-IcingaCheckUptime

## Description

Checks how long a Windows system has been up for.

InvokeIcingaCheckUptime returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' the system has been running for 10 days, WARNING is set to 15d, CRITICAL is set to 30d. In this case the check will return OK.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Cimv2

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | String | false |  | Used to specify a Warning threshold. In this case a string. Allowed units include: ms, s, m, h, d, w, M, y |
| Critical | String | false |  | Used to specify a Critical threshold. In this case a string. Allowed units include: ms, s, m, h, d, w, M, y |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUptime -Warning 18d -Critical 20d
```

### Example Output 1

```powershell
[WARNING]: Check package "Windows Uptime: Days: 19 Hours: 13 Minutes: 48 Seconds: 29" is [WARNING]| 'Windows Uptime'=1691309,539176s;1555200;1728000
```

### Example Command 2

```powershell
Invoke-IcingaCheckUptime -Warning 25d:
```

### Example Output 2

```powershell
[WARNING] Check package "System Uptime: 22d 16h 42m 35s" - [WARNING] System Uptime\_ [WARNING] System Uptime: Value "1960955.28s" is lower than threshold "2160000s"| 'system_uptime'=1960955.28s;2160000:;1
```
