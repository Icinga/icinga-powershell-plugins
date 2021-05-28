
# Invoke-IcingaCheckUNCPath

## Description

Checks a given path / unc path and determines the size of the volume including free space

Invoke-IcingaCheckUNCPath uses a path or unc path to fetch information about the volume this
path is set to. This includes the total and free space of the share but also the total free share size.

You can monitor the share size itself by using % and byte values, while the total free share size only supports byte values.

In case you are checking very long path entries, you can short them with a display name alias.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Path Permissions

The user running this plugin requires read access to the given path. In case authentication is required, it has to be mapped to a user
who can authenticate without a prompt

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Path | String | false |  | The path to a volume or network share you want to monitor, like "\\example.com\Home" or "C:\ClusterSharedVolume\Volume1" |
| DisplayAlias | String | false |  | Modifies the plugin output to not display the value provided within the `-Path` argument but to use this string value instead of shorten the output and make it more visual appealing. |
| Warning | Object | false |  | A warning threshold for the shares free space in either % or byte units, like "20%:" or "50GB:" Please note that this value is decreasing over time, therefor you will have to use the plugin handler and add ":" at the end of your input to check for "current value < threshold" like in the previous example  Allowed units: %, B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB |
| Critical | Object | false |  | A critical threshold for the shares free space in either % or byte units, like "20%:" or "50GB:" Please note that this value is decreasing over time, therefor you will have to use the plugin handler and add ":" at the end of your input to check for "current value < threshold" like in the previous example  Allowed units: %, B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB |
| WarningTotal | Object | false |  | A warning threshold for the shares total free space in byte units, like "50GB:" Please note that this value is decreasing over time, therefor you will have to use the plugin handler and add ":" at the end of your input to check for "current value < threshold" like in the previous example  Allowed units: B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB |
| CriticalTotal | Object | false |  | A warning threshold for the shares total free space in byte units, like "50GB:" Please note that this value is decreasing over time, therefor you will have to use the plugin handler and add ":" at the end of your input to check for "current value < threshold" like in the previous example  Allowed units: B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin. Default to FALSE. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckUNCPath -Path '\\example.com\Shares\Icinga' -Critical '20TB:' }
```

### Example Output 1

```powershell
[CRITICAL] Check package "\\example.com\Shares\Icinga Share" (Match All) - [CRITICAL] Free Space\_ [CRITICAL] Free Space: Value "5105899364352B" is lower than threshold "20000000000000B"| 'share_free_bytes'=5105899364352B;;20000000000000: 'total_free_bytes'=5105899364352B;; 'share_size'=23016091746304B;; 'share_free_percent'=22.18%;;;0;100
```

### Example Command 2

```powershell
icinga { Invoke-IcingaCheckUNCPath -Path '\\example.com\Shares\Icinga' -Critical '40%:' }
```

### Example Output 2

```powershell
[CRITICAL] Check package "\\example.com\Shares\Icinga Share" - [CRITICAL] Free %\_ [CRITICAL] Free %: Value "22.18%" is lower than threshold "40%"| 'share_free_bytes'=5105899343872B;; 'total_free_bytes'=5105899343872B;; 'share_size'=23016091746304B;; 'share_free_percent'=22.18%;;40:;0;100
```

### Example Command 3

```powershell
icinga { Invoke-IcingaCheckUNCPath -Path '\\example.com\Shares\Icinga' -CriticalTotal '20TB:' }
```

### Example Output 3

```powershell
[CRITICAL] Check package "\\example.com\Shares\Icinga Share" - [CRITICAL] Total Free\_ [CRITICAL] Total Free: Value "5105899315200B" is lower than threshold "20000000000000B"| 'share_free_bytes'=5105899315200B;; 'total_free_bytes'=5105899315200B;;20000000000000: 'share_size'=23016091746304B;; 'share_free_percent'=22.18%;;;0;100
```

### Example Command 4

```powershell
icinga { Invoke-IcingaCheckUNCPath -Path '\\example.com\Shares\Icinga' -DisplayAlias 'IcingaExample' -CriticalTotal '20TB:' }
```

### Example Output 4

```powershell
[CRITICAL] Check package "IcingaExample Share" - [CRITICAL] Total Free\_ [CRITICAL] Total Free: Value "5105899069440B" is lower than threshold "20000000000000B"| 'share_free_bytes'=5105899069440B;; 'total_free_bytes'=5105899069440B;;20000000000000: 'share_size'=23016091746304B;; 'share_free_percent'=22.18%;;;0;100
```
