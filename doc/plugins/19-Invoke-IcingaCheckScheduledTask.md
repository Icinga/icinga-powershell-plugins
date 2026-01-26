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
| TaskName | Array | false | @() | A list of tasks to check for. If your tasks contain spaces, wrap them around a ' to ensure they are<br /> properly handled as string |
| TaskPath | Array | false | @() | A list of task paths to filter for. If no path is specified all paths are checked. |
| State | Array | false | @() | The state a task should currently have for the plugin to return [OK] |
| IgnoreExitCodes | Array | false | @() | A list of exit codes which will be considered as [OK]. By default every task which did not exit with 0 will be handled as critical. |
| WarningMissedRuns | Object | false |  | Defines a warning threshold for missed runs for filtered tasks.<br /> <br /> Supports Icinga default threshold syntax. |
| CriticalMissedRuns | Object | false |  | Defines a critical threshold for missed runs for filtered tasks.<br /> <br /> Supports Icinga default threshold syntax. |
| WarningLastRunTime | String | false |  | Allows to specify a time interval, on which the check will return warning based on the last run time<br /> of a task and the current time. The LastRunTime is an offset of the last time the task run to the current time, therefore increasing over time<br /> <br /> Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y |
| CriticalLastRunTime | String | false |  | Allows to specify a time interval, on which the check will return critical based on the last run time<br /> of a task and the current time. The LastRunTime is an offset of the last time the task run to the current time, therefore increasing over time<br /> <br /> Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y |
| WarningNextRunTime | String | false |  | Allows to specify a time interval, on which the check will return warning based on the next run time<br /> of a task and the current time. The NextRunTime is an offset of the next time the task will run to the current time, therefore increasing over time.<br /> Negative NextRunTime values mean the task is scheduled in the future<br /> <br /> Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y |
| CriticalNextRunTime | String | false |  | Allows to specify a time interval, on which the check will return critical based on the next run time<br /> of a task and the current time. The NextRunTime is an offset of the next time the task will run to the current time, therefore increasing over time.<br /> Negative NextRunTime values mean the task is scheduled in the future<br /> <br /> Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y |
| IgnoreLastRunTime | SwitchParameter | false | False | By default every task which did not exit with 0 will be handled as critical. If you set this flag,<br /> the exit code of the task is ignored during check execution |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Ready';
```

### Example Output 1

```powershell
[OK] Check package "Scheduled Tasks"
| 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Ready 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Ready    
```

### Example Command 2

```powershell
Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Disabled';
```

### Example Output 2

```powershell
[CRITICAL] Check package "Scheduled Tasks" - [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\), Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\)
\_ [CRITICAL] Check package "\Microsoft\Windows\WindowsBackup\"
    \_ [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"
    \_ [CRITICAL] Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"
| 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Disabled 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Disabled    
```

### Example Command 3

```powershell
Invoke-IcingaCheckScheduledTask -TaskPath '\Icinga\*' -Verbosity 3;
```

### Example Output 3

```powershell
[INFO] Scheduled Tasks (All must be [OK])
\_ [INFO] \Icinga\Icinga for Windows\ (All must be [OK])
    \_ [INFO] Renew Certificate (All must be [OK])
        \_ [INFO] Last Run Time [2026/01/26 00:27:39]: 15.81h
        \_ [INFO] Last Task Result: 0
        \_ [INFO] Missed Runs: 0
        \_ [INFO] Next Run Time [2026/01/27 00:00:00]: -7.73h
        \_ [INFO] State: Ready
    \_ [INFO] Set Process Priority (All must be [OK])
        \_ [INFO] Last Run Time [2026/01/19 16:07:58]: 7.01d
        \_ [INFO] Last Task Result: 0
        \_ [INFO] Missed Runs: 0
        \_ [INFO] Next Run Time [Never]: Never
        \_ [INFO] State: Ready
| icinga_icingaforwindows_renewcertificate::ifw_scheduledtask::lastruntime=56927s;;;; icinga_icingaforwindows_renewcertificate::ifw_scheduledtask::lasttaskresult=0;;;; icinga_icingaforwindows_renewcertificate::ifw_scheduledtask::missedruns=0;;;; icinga_icingaforwindows_renewcertificate::ifw_scheduledtask::nextruntime=-27814s;;;; icinga_icingaforwindows_renewcertificate::ifw_scheduledtask::state=3;;;; icinga_icingaforwindows_setprocesspriority::ifw_scheduledtask::lastruntime=605308s;;;; icinga_icingaforwindows_setprocesspriority::ifw_scheduledtask::lasttaskresult=0;;;; icinga_icingaforwindows_setprocesspriority::ifw_scheduledtask::missedruns=0;;;; icinga_icingaforwindows_setprocesspriority::ifw_scheduledtask::nextruntime=0s;;;; icinga_icingaforwindows_setprocesspriority::ifw_scheduledtask::state=3;;;;    
```


