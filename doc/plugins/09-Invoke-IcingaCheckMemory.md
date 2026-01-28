# Invoke-IcingaCheckMemory

## Description

Checks on memory usage

Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g memory is currently at 60% usage, WARNING is set to 50%, CRITICAL is set to 90%. In this case the check will return WARNING.

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
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an string value.<br /> The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"<br /> This is using the default Icinga threshold handling.<br /> It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an string value.<br /> The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"<br /> This is using the default Icinga threshold handling.<br /> It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| PageFileWarning | Object | false |  | Allows to check the used page file and compare it against a size value, like "200MB"<br /> This is using the default Icinga threshold handling.<br />  It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| PageFileCritical | Object | false |  | Allows to check the used page file and compare it against a size value, like "200MB"<br /> This is using the default Icinga threshold handling.<br /> It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| MemoryPagesSecWarning | Object | false |  | Allows to set a Warning threshold for the Memory Pages/sec performance counter.<br /> This is using the default Icinga threshold handling. |
| MemoryPagesSecCritical | Object | false |  | Allows to set a Critical threshold for the Memory Pages/sec performance counter.<br /> This is using the default Icinga threshold handling. |
| IncludePageFile | Array | false | @() | Allows to filter for page files being included for the check |
| ExcludePageFile | Array | false | @() | Allows to filter for page files being excluded for the check |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMemory -Warning '2GiB' -Critical '4GiB';;
```

### Example Output 1

```powershell
[CRITICAL] Memory Usage [CRITICAL] Used Memory
\_ [CRITICAL] Used Memory: Value 5.84GiB is greater than threshold 4.00GiB
| cpagefilesys::ifw_pagefile::used=625999900B;;;0;34359740000 memory::ifw_memory::used=6265967000B;2147484000;4294967000;0;8583315000    
```

### Example Command 2

```powershell
Invoke-IcingaCheckMemory -Warning 25% -Critical 50%;
```

### Example Output 2

```powershell
[CRITICAL] Memory Usage [CRITICAL] Used Memory
\_ [CRITICAL] Used Memory: Value 5.56GiB (69.52%) is greater than threshold 4.00GiB (50%)
| cpagefilesys::ifw_pagefile::used=629145600B;;;0;34359740000 memory::ifw_memory::used=5966939000B;2145828750;4291657500;0;8583315000    
```


