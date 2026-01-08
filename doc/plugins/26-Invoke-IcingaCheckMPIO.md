# Invoke-IcingaCheckMPIO

## Description

Monitors the number of paths for each MPIO driver on your system.

Monitors the number of paths for each MPIO driver on your system.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\WMI

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | This threshold is deprecated, please use NumberOfPathWarning instead. |
| Critical | Object | false |  | This threshold is deprecated, please use NumberOfPathCritical instead. |
| NumberOfPathWarning | Array | false | @() | An array of specific Warning thresholds for the number of paths per MPIO device.<br /> Use the format "VolumeName=Threshold" e.g. "LUN001*=8", also supports Icinga thresholds like "LUN002*=8:" |
| NumberOfPathCritical | Array | false | @() | An array of specific Critical thresholds for the number of paths per MPIO device.<br /> Use the format "VolumeName=Threshold" e.g. "LUN001*=6", also supports Icinga thresholds like "LUN001*=6:" |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMPIO -NumberOfPathWarning 'LUN002=9:','LUN003=4';
```

### Example Output 1

```powershell
[WARNING] Multipath-IO Package: 1 Warning [WARNING] ROOT\MPIO\0000_0 Package
\_ [WARNING] ROOT\MPIO\0000_0 Package
    \_ [WARNING] ROOT\MPIO\0000_0 Drivers Package
        \_ [WARNING] LUN002 Number Paths: Value 8c is lower than threshold 9
        \_ [WARNING] LUN003 Number Paths: Value 8c is greater than threshold 4
| lun002::ifw_mpio::numberofpaths=8c;9:;;; lun003::ifw_mpio::numberofpaths=8c;4;;; nolabel::ifw_mpio::numberofpaths=8c;;;; windows::ifw_mpio::numberofpaths=8c;;;; windowsos::ifw_mpio::numberofpaths=8c;;;; rootmpio0000_0::ifw_mpio::numberofdrives=6c;;;;    
```


