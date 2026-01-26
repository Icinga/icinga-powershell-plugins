# Invoke-IcingaCheckUsedPartitionSpace

## Description

Checks how much space on a partition is used.

Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:' is at 8% usage, WARNING is set to 60%, CRITICAL is set to 80%. In this case the check will return OK.
Beside that the preset for percentage or unit measurement is now free to design, regardless of % values or GiB/TiB
and so on.

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
| Warning | Object | false |  | Used to specify a Warning threshold. This can either be a byte-value type like '10GB'<br /> or a %-value, like '10%' |
| Critical | Object | false |  | Used to specify a Critical threshold. This can either be a byte-value type like '10GB'<br /> or a %-value, like '10%' |
| Include | Array | false | @() | Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.<br /> e.g. 'C:','D:', 'D:\SysDB\'<br /> <br /> If you want to only include partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard include filter with<br /> '*`\\?*' |
| Exclude | Array | false | @() | Used to specify an array of partitions to be excluded.<br /> e.g. 'C:','D:', 'D:\SysDB\'<br /> <br /> If you want to only exclude partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard exclude filter with<br /> '*`\\?*' |
| IgnoreEmptyChecks | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example).<br /> Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| SkipUnknown | SwitchParameter | false | False | Allows to set Unknown partitions to Ok in case no metrics could be loaded. |
| CheckUsedSpace | SwitchParameter | false | False | Switches the behaviour of the plugin from checking with threshold for the free space (default) to the remaining (used) space instead |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Verbosity 3;
```

### Example Output 1

```powershell
[CRITICAL] Free Partition Space: 2 Critical 2 Ok [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\, Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\ (All must be [OK])
\_ [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: Value 287.20MiB (95.73%) is greater than threshold 240.00MiB (80%)
\_ [CRITICAL] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: Value 266.22MiB (89.94%) is greater than threshold 236.80MiB (80%)
\_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB (16.05%)
\_ [OK] Partition C: 30.23GiB (11.88%)
| volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;188741220;251654960;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;186227100;248302800;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;453611520;604815360;0;756019200 c::ifw_partitionspace::free=32461880000B;164013240000;218684320000;0;273355400000    
```

### Example Command 2

```powershell
Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Exclude '*`\\?*' -Verbosity 3;
```

### Example Output 2

```powershell
[OK] Free Partition Space: 1 Ok (All must be [OK])
\_ [OK] Partition C: 30.23GiB (11.87%)
| c::ifw_partitionspace::free=32456160000B;164013240000;218684320000;0;273355400000    
```

### Example Command 3

```powershell
Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Include 'C:' -Verbosity 3;
```

### Example Output 3

```powershell
[OK] Free Partition Space: 1 Ok (All must be [OK])
\_ [OK] Partition C: 29.22GiB (11.48%)
| c::ifw_partitionspace::free=31376350000B;164013240000;218684320000;0;273355400000    
```

### Example Command 4

```powershell
Invoke-IcingaCheckUsedPartitionSpace -Warning '1TB' -Critical '1.5TB' -Verbosity 3;
```

### Example Output 4

```powershell
[OK] Free Partition Space: 4 Ok (All must be [OK])
\_ [OK] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: 287.20MiB
\_ [OK] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: 266.22MiB
\_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB
\_ [OK] Partition C: 29.22GiB
| volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;1000000000000;1000000000000;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;1000000000000;1000000000000;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;1000000000000;1000000000000;0;756019200 c::ifw_partitionspace::free=31376350000B;1000000000000;1000000000000;0;273355400000    
```


