
# Invoke-IcingaCheckUsedPartitionSpace

## Description

Checks how much space on a partition is used.

Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:' is at 8% usage, WARNING is set to 60, CRITICAL is set to 80. In this case the check will return OK.

The plugin will return `UNKNOWN` in case partition data (size and free space) can not be fetched. This is
normally happening in case the user the plugin is running with does not have permissions to fetch this
specific partition data.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Cimv2

### Performance Counter

* LogicalDisk(*)\% free space

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. This can either be a byte-value type like '10GB' or a %-value, like '10%' |
| Critical | Object | false |  | Used to specify a Critical threshold. This can either be a byte-value type like '10GB' or a %-value, like '10%' |
| Include | Array | false | @() | Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked. e.g. 'C:\','D:\' |
| Exclude | Array | false | @() | Used to specify an array of partitions to be excluded. e.g. 'C:\','D:\' |
| IgnoreEmptyChecks | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example). Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| SkipUnknown | SwitchParameter | false | False | Allows to set Unknown partitions to Ok in case no metrics could be loaded. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80
```

### Example Output 1

```powershell
[OK]: Check package "Used Partition Space" is [OK]| 'Partition C'=8,06204986572266%;60;;0;100 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
```

### Example Command 2

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Exclude "C:\"
```

### Example Output 2

```powershell
[OK]: Check package "Used Partition Space" is [OK]| 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
```

### Example Command 3

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Include "C:\"
```

### Example Output 3

```powershell
[OK]: Check package "Used Partition Space" is [OK]| 'Partition C'=8,06204986572266%;60;;0;100
```
