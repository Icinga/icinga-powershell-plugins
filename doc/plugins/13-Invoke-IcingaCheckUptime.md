
# Invoke-IcingaCheckUptime

## Description

Checks how long a Windows system has been up for.

InvokeIcingaCheckUptime returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' the system has been running for 10 days, WARNING is set to 15d, CRITICAL is set to 30d. In this case the check will return OK.
More Information on https://github.com/Icinga/icinga-powershell-plugins

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
