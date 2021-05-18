
# Invoke-IcingaCheckPerfcounter

## Description

Performs checks on various performance counter

Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
Use "Show-IcingaPerformanceCounterCategories" to see all performance counter categories available.
To gain insight on an specific performance counter use "Show-IcingaPerformanceCounters <performance counter category>"
e.g '

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| PerfCounter | Array | false |  | Used to specify an array of performance counter to check against. |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an ??? value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an ??? value. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckPerfCounter -PerfCounter '\processor(*)\% processor time' -Warning 60 -Critical 90
```

### Example Output 1

```powershell
[WARNING]: Check package "Performance Counter" is [WARNING]| 'processor1_processor_time'=68.95;60;90 'processor3_processor_time'=4.21;60;90 'processor5_processor_time'=9.5;60;90 'processor_Total_processor_time'=20.6;60;90 'processor0_processor_time'=5.57;60;90 'processor2_processor_time'=0;60;90 'processor4_processor_time'=6.66;60;90
```
