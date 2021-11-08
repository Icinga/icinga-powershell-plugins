
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
| Warning | Object | false |  | Used to specify a Warning threshold for the number of path defined. Use for example 8: for alerting for less than 8 MPIO paths available |
| Critical | Object | false |  | Used to specify a Critical threshold for the number of path defined. Use for example 6: for alerting for less than 6 MPIO paths available |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckMPIO -Verbosity 3 }
```

### Example Output 1

```powershell
[OK] Check package "Multipath-IO Package" (Match All)\_ [OK] Check package "HostName Package" (Match All) \_ [OK] HostName Active: True \_ [OK] Check package "HostName Drivers Package" (Match All)\_ [OK] MPIO DISK0 Number Paths: 8c\_ [OK] MPIO DISK1 Number Paths: 8c\_ [OK] MPIO DISK2 Number Paths: 8c\_ [OK] MPIO DISK3 Number Paths: 8c\_ [OK] MPIO DISK4 Number Paths: 8c \_ [OK] HostName NumberDrives: 5c| 'hostname_numberdrives'=5c;; 'mpio_disk0_number_paths'=8c;; 'mpio_disk3_number_paths'=8c;; 'mpio_disk4_number_paths'=8c;; 'mpio_disk2_number_paths'=8c;; 'mpio_disk1_number_paths'=8c;;0
```
