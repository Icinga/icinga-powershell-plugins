
# Invoke-IcingaCheckPartitionSpace

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
| Include | Array | false | @() | Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked. e.g. 'C:','D:' |
| Exclude | Array | false | @() | Used to specify an array of partitions to be excluded. e.g. 'C:','D:' |
| IgnoreEmptyChecks | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example). Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| SkipUnknown | SwitchParameter | false | False | Allows to set Unknown partitions to Ok in case no metrics could be loaded. |
| CheckUsedSpace | SwitchParameter | false | False | Switches the behaviour of the plugin from checking with threshold for the free space (default) to the remaining (used) space instead |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning '60%' -Critical '80%' -CheckUsedSpace
```

### Example Output 1

```powershell
[CRITICAL] Used Partition Space: 2 Critical 1 Ok [CRITICAL] Partition C: (85.43% (795.22GiB)), Partition G: (87.50% (1.59TiB))\_ [CRITICAL] Partition C: 85.43% (795.22GiB) is greater than threshold 80% (744.71GiB)\_ [CRITICAL] Partition G: 87.50% (1.59TiB) is greater than threshold 80% (1.46TiB)| 'used_space_partition_r'=326052500000B;2400460800000;3200614400000;0;4000768000000 'used_space_partition_g'=1750369000000B;1200228600000;1600304800000;0;2000381000000 'used_space_partition_c'=853859000000B;599716680000;799622240000;0;999527800000
```

### Example Command 2

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning '740GB' -Critical '800GB' -CheckUsedSpace
```

### Example Output 2

```powershell
[CRITICAL] Used Partition Space: 2 Critical 1 Ok [CRITICAL] Partition C: (795.23GiB), Partition G: (1.59TiB)\_ [CRITICAL] Partition C: 795.23GiB is greater than threshold 745.06GiB\_ [CRITICAL] Partition G: 1.59TiB is greater than threshold 745.06GiB| 'used_space_partition_r'=326052500000B;740000000000;800000000000;0;4000768000000 'used_space_partition_g'=1750369000000B;740000000000;800000000000;0;2000381000000 'used_space_partition_c'=853874000000B;740000000000;800000000000;0;999527800000
```

### Example Command 3

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning '300GB:' -Critical '200GB:'
```

### Example Output 3

```powershell
[CRITICAL] Free Partition Space: 1 Critical 1 Warning 1 Ok [CRITICAL] Partition C: (135.65GiB) [WARNING] Partition G: (232.84GiB)\_ [CRITICAL] Partition C: 135.65GiB is lower than threshold 186.26GiB\_ [WARNING] Partition G: 232.84GiB is lower than threshold 279.40GiB| 'free_space_partition_g'=250012600000B;300000000000:;200000000000:;0;2000381000000 'free_space_partition_r'=3674716000000B;300000000000:;200000000000:;0;4000768000000 'free_space_partition_c'=145653700000B;300000000000:;200000000000:;0;999527800000
```

### Example Command 4

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning '20%:' -Critical '10%:'
```

### Example Output 4

```powershell
[WARNING] Free Partition Space: 2 Warning 1 Ok [WARNING] Partition C: (14.57% (135.65GiB)), Partition G: (12.50% (232.84GiB))\_ [WARNING] Partition C: 14.57% (135.65GiB) is lower than threshold 20% (186.18GiB)\_ [WARNING] Partition G: 12.50% (232.84GiB) is lower than threshold 20% (372.60GiB)| 'free_space_partition_g'=250012600000B;400076200000:;200038100000:;0;2000381000000 'free_space_partition_r'=3674716000000B;800153600000:;400076800000:;0;4000768000000 'free_space_partition_c'=145656400000B;199905560000:;99952780000:;0;999527800000
```
