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
| Warning | String | false |  | Used to specify a Warning threshold. In this case a string.<br /> Allowed units include: ms, s, m, h, d, w, M, y |
| Critical | String | false |  | Used to specify a Critical threshold. In this case a string.<br /> Allowed units include: ms, s, m, h, d, w, M, y |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUptime -Warning 18d -Critical 20d
```

### Example Output 1

```powershell
[WARNING]: Check package "Windows Uptime: Days: 19 Hours: 13 Minutes: 48 Seconds: 29" is [WARNING]
| 'Windows Uptime'=1691309,539176s;1555200;1728000    
```

### Example Command 2

```powershell
Invoke-IcingaCheckUptime -Warning 25d:
```

### Example Output 2

```powershell
[WARNING] Check package "System Uptime: 22d 16h 42m 35s" - [WARNING] System Uptime
\_ [WARNING] System Uptime: Value "1960955.28s" is lower than threshold "2160000s"
| 'system_uptime'=1960955.28s;2160000:;
1    
```


