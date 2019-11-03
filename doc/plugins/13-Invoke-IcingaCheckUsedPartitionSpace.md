
# Invoke-IcingaCheckUsedPartitionSpace

## Description

Checks how much space on a partition is used.

Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:' is at 8% usage, WARNING is set to 60, CRITICAL is set to 80. In this case the check will return OK.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| Include | Array | false | @() | Used to specify an array of partitions to be included. e.g. 'C:\','D:\' |
| Exclude | Array | false | @() | Used to specify an array of partitions to be excluded. e.g. 'C:\','D:\' |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

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
