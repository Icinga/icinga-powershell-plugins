
# Invoke-IcingaCheckEventlog

## Description

Checks how many eventlog occurrences of a given type there are.

Invoke-IcingaCheckEventlog returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g Eventlog returns 500 entries with the specified parameters, WARNING is set to 200, CRITICAL is set to 800. Thereby the check will return WARNING.

By default if no time frame is selected with `-After` for example, the plugin will fetch EventLog information from the last two hours.
In case your are not using `-DisableTimeCache`, the plugin will after the first execution only collect the delta between the last
execution time and the current execution time.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Required User Groups

* Event Log Reader

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. |
| Critical | Object | false |  | Used to specify a Critical threshold. |
| LogName | String | false |  | Used to specify a certain log. |
| IncludeEventId | Array | false | @() | Used to specify an array of events identified by their id to be included. |
| ExcludeEventId | Array | false | @() | Used to specify an array of events identified by their id to be excluded. |
| IncludeUsername | Array | false | @() | Used to specify an array of usernames within the eventlog to be included. |
| ExcludeUsername | Array | false | @() | Used to specify an array of usernames within the eventlog to be excluded. |
| IncludeEntryType | Array | false | @() | Used to specify an array of entry types within the eventlog to be included. Please note that `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog. |
| ExcludeEntryType | Array | false | @() | Used to specify an array of entry types within the eventlog to be excluded. Please note that `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog. |
| IncludeMessage | Array | false | @() | Used to specify an array of messages within the eventlog to be included. |
| ExcludeMessage | Array | false | @() | Used to specify an array of messages within the eventlog to be excluded. |
| IncludeSource | Array | false | @() | Used to specify an array of message sources within the eventlog to be included. |
| ExcludeSource | Array | false | @() | Used to specify an array of message sources within the eventlog to be excluded. |
| After | Object | false |  | Used to specify time data of which point the plugin should start to read event logs from. You can either use a fixed date and time like "2021/01/30 12:00:00", a fixed day "2021/01/30" or use more dynamic approaches like "1d", "10h" and so on.  Allowed units: ms, s, m, h, d, w, M, y |
| Before | Object | false |  | Used to specify time data of which point the plugin should stop considering event logs. You can either use a fixed date and time like "2021/01/30 12:00:00", a fixed day "2021/01/30" or use more dynamic approaches like "1d", "10h" and so on.  By using "2h" for example, log files of the last 2 hours will be ignored. Please ensure to manually set the `-After` argument and ensure you go back further in time with the `-After` argument than the `-Before` argument.  Allowed units: ms, s, m, h, d, w, M, y |
| MaxEntries | Int32 | false | 40000 | Allows to limit the amount of log entries fetched by Get-WinEvent, to increase performance and reduce system load impact Should match the average amount of log files written for the intended time range filtered |
| DisableTimeCache | SwitchParameter | false | False | Switch to disable the time cache on a check. If this parameter is set the time cache is disabled. After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended. This is due to the time cache, when disabled the whole eventlog is checked instead. |
| NoPerfData | SwitchParameter | false | False | Used to disable PerfData. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
```

### Example Output 1

```powershell
[CRITICAL] Check package "EventLog" - [CRITICAL] EventId 642 [WARNING] EventId 1008, EventId 2002, EventId 642\_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)." \_ [WARNING] EventId 2002: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 09:31:36] - [27.08.2020 22:57:40] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 14:50:37] - [17.08.2020 19:41:00] there occurred 391 event(s)." \_ [WARNING] EventId 642: Value "391" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 14:50:37] - [17.08.2020 19:41:00] there occurred 391 event(s)." \_ [WARNING] EventId 642: Value "391" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 15:51:00] - [17.08.2020 19:41:00] there occurred 298 event(s)." \_ [WARNING] EventId 642: Value "298" is greater than threshold "100"\_ [CRITICAL] Check package "Between: [17.08.2020 19:56:38] - [27.08.2020 09:56:35] there occurred 3539 event(s)." \_ [CRITICAL] EventId 642: Value "3539" is greater than threshold "1000"\_ [CRITICAL] Check package "Between: [17.08.2020 19:56:38] - [27.08.2020 09:56:35] there occurred 3539 event(s)." \_ [CRITICAL] EventId 642: Value "3539" is greater than threshold "1000"\_ [CRITICAL] Check package "Between: [17.08.2020 20:03:07] - [27.08.2020 09:56:35] there occurred 2757 event(s)." \_ [CRITICAL] EventId 642: Value "2757" is greater than threshold "1000"
```

### Example Command 2

```powershell
Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000 -IncludeEventId 1008
```

### Example Output 2

```powershell
[WARNING] Check package "EventLog" - [WARNING] EventId 1008\_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"\_ [WARNING] Check package "Between: [16.08.2020 09:31:36] - [27.08.2020 22:57:40] there occurred 242 event(s)." \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"| 'eventid_1008'=726c;;
```
