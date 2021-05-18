
# Invoke-IcingaCheckMemory

## Description

Checks on memory usage

Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g memory is currently at 60% usage, WARNING is set to 50, CRITICAL is set to 90. In this case the check will return WARNING.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Performance Counter

* \Memory\% committed bytes in use
* \Memory\Available Bytes
* \Paging File(_Total)\% usage

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Critical | String | false |  | Used to specify a Critical threshold. In this case an string value. The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" This is using the default Icinga threshold handling. |
| Warning | String | false |  | Used to specify a Warning threshold. In this case an string value. The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" This is using the default Icinga threshold handling. |
| CriticalPercent | Object | false |  | Used to specify a Critical threshold for the memory usage in percent, like 30 for 30%. This is using the default Icinga threshold handling. |
| WarningPercent | Object | false |  | Used to specify a Warning threshold for the memory usage in percent, like 30 for 30%. This is using the default Icinga threshold handling. |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

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
