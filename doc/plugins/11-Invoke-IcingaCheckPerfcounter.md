# Invoke-IcingaCheckPerfCounter

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
| Warning | Object | false |  | Used to specify a Warning threshold. |
| Critical | Object | false |  | Used to specify a Critical threshold. |
| IncludeCounter | Array | false | @() | An [array] of strings to filter for, only including the provided counters. Allows<br /> wildcard "*" usage |
| ExcludeCounter | Array | false | @() | An [array] of strings to filter for, excluding the provided counters. Allows<br /> wildcard "*" usage |
| IgnoreEmptyChecks | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no check element was found and<br /> prevent the plugin from exiting UNKNOWN and returns OK instead |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckPerfCounter -PerfCounter '\processor(*)\% processor time' -Warning 60 -Critical 90
```

### Example Output 1

```powershell
[WARNING]: Check package "Performance Counter" is [WARNING]
| 'processor1_processor_time'=68.95;60;90 'processor3_processor_time'=4.21;60;90 'processor5_processor_time'=9.5;60;90 'processor_Total_processor_time'=20.6;60;90 'processor0_processor_time'=5.57;60;90 'processor2_processor_time'=0;60;90 'processor4_processor_time'=6.66;60;90    
```


