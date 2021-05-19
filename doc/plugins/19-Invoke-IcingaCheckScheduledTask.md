
# Invoke-IcingaCheckScheduledTask

## Description

Checks the current state for a list of specified tasks based on their name and prints the result

Check for a list of tasks by their name and compare their current state with a plugin argument
to determine the plugin output. States of tasks not matching the plugin argument will return
[CRITICAL], while all other tasks will return [OK]. For not found tasks we will return [UNKNOWN]
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| TaskName | Array | false |  | A list of tasks to check for. If your tasks contain spaces, wrap them around a ' to ensure they are properly handled as string |
| State | Array | false | @() | The state a task should currently have for the plugin to return [OK] |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Ready';
```

### Example Output 1

```powershell
[OK] Check package "Scheduled Tasks"| 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Ready 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Ready
```

### Example Command 2

```powershell
Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Disabled';
```

### Example Output 2

```powershell
[CRITICAL] Check package "Scheduled Tasks" - [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\), Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\)\_ [CRITICAL] Check package "\Microsoft\Windows\WindowsBackup\"\_ [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"\_ [CRITICAL] Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"| 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Disabled 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Disabled
```
