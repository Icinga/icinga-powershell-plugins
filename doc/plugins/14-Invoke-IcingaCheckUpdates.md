
# Invoke-IcingaCheckUpdates

## Description

Checks how many updates are to be applied

Invoke-IcingaCheckUpdates returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' 10 updates are pending, WARNING is set to 20, CRITICAL is set to 50. In this case the check will return OK.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### COM-Objects

* Microsoft.Update.Session

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| UpdateFilter | Array | false | @() | Allows to filter for names of updates being included in the total update count, allowing a specific monitoring and filtering of certain updates beyond the provided categories |
| Warning | Object | false |  | The warning threshold for the total pending update count on the Windows machine |
| Critical | Object | false |  | The critical threshold for the total pending update count on the Windows machine |
| WarningSecurity | Object | false |  | The warning threshold for the security update count on the Windows machine |
| CriticalSecurity | Object | false |  | The critical threshold for the security update count on the Windows machine |
| WarningRollups | Object | false |  | The warning threshold for the rollup update count on the Windows machine |
| CriticalRollups | Object | false |  | The critical threshold for the rollup update count on the Windows machine |
| WarningDefender | Object | false |  | The warning threshold for the Microsoft Defender update count on the Windows machine |
| CriticalDefender | Object | false |  | The critical threshold for the Microsoft Defender update count on the Windows machine |
| WarningOther | Object | false |  | The warning threshold for all other updates on the Windows machine |
| CriticalOther | Object | false |  | The critical threshold for all other updates on the Windows machine |
| WarnOnReboot | SwitchParameter | false | False | Checks if there is a pending reboot on the system to finalize Windows Updates and returns warning if one is pending |
| CritOnReboot | SwitchParameter | false | False | Checks if there is a pending reboot on the system to finalize Windows Updates and returns critical if one is pending |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUpdates -Verbosity 1 -WarningDefender 0;
```

### Example Output 1

```powershell
[WARNING] Windows Updates: 1 Warning 4 Ok [WARNING] Microsoft Defender
\_ [WARNING] Microsoft Defender
    \_ [OK] Security Intelligence-Update für Microsoft Defender Antivirus - KB2267602 (Version 1.355.2366.0) [23.01.2022 00:00:00]: 0
    \_ [WARNING] Update Count: 1c is greater than threshold 0c
\_ [OK] Total Pending Updates: 1c
| 'total_pending_updates'=1c;; 'security_update_count'=0c;; 'rollups_update_count'=0c;; 'other_update_count'=0c;; 'defender_update_count'=1c;0;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckUpdates -Verbosity 1 -Warning 0 -UpdateFilter '*Intelligence-Update*';
```

### Example Output 2

```powershell
[WARNING] Windows Updates: 1 Warning 4 Ok [WARNING] Total Pending Updates (1c)
\_ [WARNING] Total Pending Updates: 1c is greater than threshold 0c
| 'total_pending_updates'=1c;0; 'security_update_count'=0c;; 'rollups_update_count'=0c;; 'other_update_count'=0c;; 'defender_update_count'=1c;;    
```
