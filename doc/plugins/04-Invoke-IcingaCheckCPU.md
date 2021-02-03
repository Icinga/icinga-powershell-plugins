
# Invoke-IcingaCheckCPU

## Description

Checks cpu usage of cores.

Invoke-IcingaCheckCPU returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g A system has 4 cores, each running at 60% usage, WARNING is set to 50%, CRITICAL is set to 75%. In this case the check will return WARNING.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Performance Counter

* Processor(*)\% processor time

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| Core | String | false | * | Used to specify a single core to check for. For the average load across all cores use `_Total` |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckCPU -Warning 50 -Critical 75
```

### Example Output 1

```powershell
[OK]: Check package "CPU Load" is [OK]| 'Core #0'=4,59%;50;75;0;100 'Core #1'=0,94%;50;75;0;100 'Core #2'=11,53%;50;75;0;100 'Core #3'=4,07%;50;75;0;100
```

### Example Command 2

```powershell
Invoke-IcingaCheckCPU -Warning 50 -Critical 75 -Core 1
```

### Example Output 2

```powershell
[OK]: Check package "CPU Load" is [OK]| 'Core #1'=2,61%;50;75;0;100
```
