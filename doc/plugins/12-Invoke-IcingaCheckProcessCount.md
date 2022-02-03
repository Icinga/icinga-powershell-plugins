
# Invoke-IcingaCheckProcessCount

## Description

Checks how many processes of a process exist.

Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g there are three conhost processes running, WARNING is set to 3, CRITICAL is set to 4. In this case the check will return WARNING.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* root\cimv2

### Performance Counter

* Processor(*)\% processor time

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| Process | Array | false | @() | Used to specify an array of processes to count and match against. e.g. conhost,wininit |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckProcessCount -Process conhost -Warning 5 -Critical 10
```

### Example Output 1

```powershell
[OK]: Check package "Process Check" is [OK]| 'Process Count "conhost"'=3;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckProcessCount -Process conhost,wininit -Warning 5 -Critical 10 -Verbosity 3
```

### Example Output 2

```powershell
[OK]: Check package "Process Check" is [OK] (Match All)\_ [OK]: Process Count "conhost" is 3\_ [OK]: Process Count "wininit" is 1| 'Process Count "conhost"'=3;5;10 'Process Count "wininit"'=1;5;10
```
