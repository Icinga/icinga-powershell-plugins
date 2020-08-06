
# Invoke-IcingaCheckScheduledTask

## Description

Checks the current state for a list of specified tasks based on their name and prints the result

Check for a list of tasks by their name and compare their current state with a plugin argument
to determine the plugin output. States of tasks not matching the plugin argument will return
[CRITICAL], while all other tasks will return [OK]. For not found tasks we will return [UNKNOWN]
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| TaskName | Array | false |  | A list of tasks to check for. If your tasks contain spaces, wrap them around a ' to ensure they are properly handled as string |
| State | String | false |  | The state a task should currently have for the plugin to return [OK] Force the usage of IPv6 addresses for ICMP calls by using a hostname |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Increase the printed output message by adding additional details or print all data regardless of their status |

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
