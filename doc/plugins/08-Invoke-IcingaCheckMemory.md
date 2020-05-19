
# Invoke-IcingaCheckMemory

## Description

Checks on memory usage

Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g memory is currently at 60% usage, WARNING is set to 50, CRITICAL is set to 90. In this case the check will return WARNING.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Critical | String | false |  | Used to specify a Critical threshold. In this case an string value.  The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" |
| Warning | String | false |  | Used to specify a Warning threshold. In this case an string value.  The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" |
| CriticalPercent | Object | false |  | Used to specify a Critical threshold. In this case an integer value.  Like 30 for 30%. If memory usage is below 30%, the check will return CRITICAL. |
| WarningPercent | Object | false |  |  |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMemory -Verbosity 3 -Warning 60 -Critical 80
```

### Example Output 1

```powershell
[WARNING]: % Memory Check 78.74 is greater than 60
```

### Example Command 2

```powershell
Invoke-IcingaCheckMemory -WarningPercent 30 -CriticalPercent 50
```

### Example Output 2

```powershell
[WARNING] Check package "Memory Usage" - [WARNING] Memory Percent Used\_ [WARNING] Memory Percent Used: Value "48.07%" is greater than threshold "30%"| 'memory_percent_used'=48.07%;0:30;0:50;0;100 'used_bytes'=3.85GB;;;0;81
```
