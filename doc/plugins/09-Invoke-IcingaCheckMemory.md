
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
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an string value. The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" This is using the default Icinga threshold handling. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an string value. The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB" This is using the default Icinga threshold handling. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| PageFileWarning | Object | false |  | Allows to check the used page file and compare it against a size value, like "200MB" This is using the default Icinga threshold handling.  It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| PageFileCritical | Object | false |  | Allows to check the used page file and compare it against a size value, like "200MB" This is using the default Icinga threshold handling. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. |
| IncludePageFile | Array | false | @() | Allows to filter for page files being included for the check |
| ExcludePageFile | Array | false | @() | Allows to filter for page files being excluded for the check |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMemory -Verbosity 3 -Warning '60%' -Critical '80%'
```

### Example Output 1

```powershell
[OK] Memory Usage (All must be [OK])\_ [OK] PageFile Usage (All must be [OK])\_ [OK] C:\pagefile.sys: 278MB\_ [OK] Used Memory: 36.13% (23.10GiB)| 'used_memory'=24800540000B;41181786000;54909048000;0;68636310000 'pagefile_cpagefilesys'=278000000B;;;0;17408000000
```

### Example Command 2

```powershell
Invoke-IcingaCheckMemory -Verbosity 3 -Warning '50GB' -Critical '60GB'
```

### Example Output 2

```powershell
[OK] Memory Usage (All must be [OK])\_ [OK] PageFile Usage (All must be [OK])\_ [OK] C:\pagefile.sys: 278MB\_ [OK] Used Memory: 22.92GiB| 'used_memory'=24605630000B;50000000000;60000000000;0;68636310000 'pagefile_cpagefilesys'=278000000B;;;0;17408000000
```
