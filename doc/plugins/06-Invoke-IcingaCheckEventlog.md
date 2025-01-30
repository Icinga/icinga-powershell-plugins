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
| IncludeEntryType | Array | false | @() | Used to specify an array of entry types within the eventlog to be included. Please note that<br /> `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog. |
| ExcludeEntryType | Array | false | @() | Used to specify an array of entry types within the eventlog to be excluded. Please note that<br /> `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog. |
| IncludeMessage | Array | false | @() | Used to specify an array of messages within the eventlog to be included. |
| ExcludeMessage | Array | false | @() | Used to specify an array of messages within the eventlog to be excluded. |
| IncludeSource | Array | false | @() | Used to specify an array of message sources within the eventlog to be included. |
| ExcludeSource | Array | false | @() | Used to specify an array of message sources within the eventlog to be excluded. |
| ProblemId | Array | false | @() | Used to specify an array of event IDs that should be marked as problems. These event IDs will be compared to the provided AcknowledgeIds.<br /> If no event ID for an AcknowledgeId is found after the corresponding problem event ID has occurred, it will be marked as a problem.<br /> If you provide multiple ProblemIds, you must specify the same number of AcknowledgeIds. If you have multiple ProblemIds but only one AcknowledgeId,<br /> you need to add the AcknowledgeId multiple times to the AcknowledgeIds array. |
| AcknowledgeId | Array | false | @() | Used to specify an array of event IDs that should be marked as acknowledged. These event IDs will be compared to the provided ProblemIds.<br /> If no event ID for a ProblemId is found it will be marked as a problem. If you provide multiple ProblemIds, you must specify the same number of AcknowledgeIds.<br /> If you have multiple ProblemIds but only one AcknowledgeId, you need to add the AcknowledgeId multiple times to this array. |
| After | Object | false |  | Defines the starting point on which timeframe the plugin will start to read event log information.<br /> Using 4h as argument as example, will provide all entries from the time the plugin was executed to the past 4 hours.<br /> For thresholds you can be very specific by providing the time in a time format or by using simple time metrics by their units. Examples:<br /> <br /> "2024/01/01 12:00:00": Will start reading eventlogs after the 1st January 2024 12:00 CET<br /> "2024/01/15": Will start reading eventlogs after the 15th January 2024 00:00 CET<br /> "4h": Will read the past 4 hours<br /> "1d": Will read the past day (24 hours)<br /> <br /> Allowed units for time metrics: ms, s, m, h, d, w, M, y<br /> <br /> Example<br /> <pre> Start of EventLog       Plugin Execution<br /> v                After 4h              v<br /> &#124;--------------------&#124;-----------------&#124;<br /> 10:00              12:00           16:00<br /> &#124; Not fetched        &#124; Fetched         &#124;</pre> |
| Before | Object | false |  | Defines the end point on which timeframe the plugin will stop to read event log information.<br /> Using 2h as argument as example, will ignore all events of the past 2 hours from the time the plugin was executed. This should be<br /> used in combination with the "-After" argument. As example, you could provide "-After 6h" to start reading all eventlogs from the past<br /> 6 hours, and use "-Before 2h" to skip the last 2 hours. In this scenario, would receive 4 hours of eventlogs, while the last 2 hours<br /> have been ignored.<br /> For thresholds you can be very specific by providing the time in a time format or by using simple time metrics by their units. Examples:<br /> <br /> "2024/01/01 12:00:00": Will stop reading eventlogs after the 1st January 2024 12:00 CET<br /> "2024/01/15": Will stop reading eventlogs after the 15th January 2024 00:00 CET<br /> "4h": Will ignore eventlogs of the past 4 hours<br /> "1d": Will ignore eventlogs of the past day (24 hours)<br /> <br /> Allowed units for time metrics: ms, s, m, h, d, w, M, y<br /> <br /> Example<br /> <pre> Start of EventLog        Plugin Execution<br /> v         After 6h           Before 2h  v<br /> &#124;-------------&#124;------------------&#124;------&#124;<br /> 8:00        10:00              14:00    16:00<br /> &#124; Not fetched &#124; Fetched          &#124; Not fetched</pre> |
| MaxEntries | Int32 | false | 40000 | Allows to limit the amount of log entries fetched by Get-WinEvent, to increase performance and reduce system load impact<br /> Should match the average amount of log files written for the intended time range filtered |
| DisableTimeCache | SwitchParameter | false | False | Switch to disable the time cache on a check. If this parameter is set the time cache is disabled.<br /> After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended.<br /> This is due to the time cache, when disabled the whole eventlog is checked instead. |
| NoPerfData | SwitchParameter | false | False | Used to disable PerfData. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
```

### Example Output 1

```powershell
[WARNING] Eventlog Application: 1 Warning 2 Ok [WARNING] Event source Icinga 2
\_ [WARNING] Event source Icinga 2
    \_ [WARNING] Found 123 event(s) for event id 1 in timeframe [03/12/2024 16:37:54] - [03/14/2024 11:07:37]
        \_ [WARNING] Number of events found for Id 1: 123 is greater than threshold 100
| '1::ifw_eventlog::count'=123c;; '1008::ifw_eventlog::count'=11c;; '10010::ifw_eventlog::count'=11c;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2 -After 4h -Before 2h
```

### Example Output 2

```powershell
[OK] Eventlog Application: 3 Ok
\_ [OK] Event source Icinga 2
    \_ [OK] Found 379 event(s) for event id 1 in timeframe [03/14/2024 07:42:57] - [03/14/2024 09:38:06]
        \_ [OK] Event Message: information/RemoteCheckQueue: items: 0, rate: 0/s (6/min 30/5min 90/15min);
        \_ [OK] Number of events found for Id 1: 379
\_ [OK] Event source Microsoft-Windows-Security-SPP
    \_ [OK] Found 1 event(s) for event id 16384 in timeframe [03/14/2024 09:09:18] - [03/14/2024 09:09:18]
        \_ [OK] Event Message: Successfully scheduled Software Protection service for re-start at 2024-03-15T08:07:18Z. Reason: RulesEngine.
        \_ [OK] Number of events found for Id 16384: 1
    \_ [OK] Found 1 event(s) for event id 16394 in timeframe [03/14/2024 09:08:00] - [03/14/2024 09:08:00]
        \_ [OK] Event Message: Offline downlevel migration succeeded.
        \_ [OK] Number of events found for Id 16394: 1
    \_ [OK] Found 1 event(s) for event id 8198 in timeframe [03/14/2024 09:08:04] - [03/14/2024 09:08:04]
        \_ [OK] Event Message: License Activation (slui.exe) failed with the following error code:
        \_ [OK] Number of events found for Id 8198: 1
    \_ [OK] Found 2 event(s) for event id 1003 in timeframe [03/14/2024 09:08:04] - [03/14/2024 09:08:04]
        \_ [OK] Event Message: The Software Protection service has completed licensing status check.
        \_ [OK] Number of events found for Id 1003: 2
\_ [OK] Event source SceCli
    \_ [OK] Found 1 event(s) for event id 1704 in timeframe [03/14/2024 09:09:32] - [03/14/2024 09:09:32]
        \_ [OK] Event Message: Security policy in the Group policy objects has been applied successfully.
        \_ [OK] Number of events found for Id 1704: 1
| '1::ifw_eventlog::count'=379c;; '1003::ifw_eventlog::count'=2c;; '1704::ifw_eventlog::count'=1c;; '8198::ifw_eventlog::count'=1c;; '16384::ifw_eventlog::count'=1c;; '16394::ifw_eventlog::count'=1c;;    
```

### Example Command 3

```powershell
Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2 -After '2024/03/14 10:00'
```

### Example Output 3

```powershell
[OK] Eventlog Application: 2 Ok
\_ [OK] Event source Icinga 2
    \_ [OK] Found 637 event(s) for event id 1 in timeframe [03/14/2024 10:00:04] - [03/14/2024 11:40:11]
        \_ [OK] Event Message: information/RemoteCheckQueue: items: 0, rate: 0/s (12/min 60/5min 180/15min);
        \_ [OK] Number of events found for Id 1: 637
\_ [OK] Event source Microsoft-Windows-Security-SPP
    \_ [OK] Found 2 event(s) for event id 16384 in timeframe [03/14/2024 10:22:07] - [03/14/2024 11:27:26]
        \_ [OK] Event Message: Successfully scheduled Software Protection service for re-start at 2024-03-15T08:07:26Z. Reason: RulesEngine.
        \_ [OK] Number of events found for Id 16384: 2
    \_ [OK] Found 2 event(s) for event id 16394 in timeframe [03/14/2024 10:21:36] - [03/14/2024 11:26:56]
        \_ [OK] Event Message: Offline downlevel migration succeeded.
        \_ [OK] Number of events found for Id 16394: 2
| '1::ifw_eventlog::count'=637c;; '16384::ifw_eventlog::count'=2c;; '16394::ifw_eventlog::count'=2c;;    
```

### Example Command 4

```powershell
Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2
```

### Example Output 4

```powershell
[OK] Eventlog Application: 1 Ok
\_ [OK] Event source Icinga 2
    \_ [OK] Found 2 event(s) for event id 1 in timeframe [03/14/2024 11:09:37] - [03/14/2024 11:09:47]
        \_ [OK] Event Message: information/RemoteCheckQueue: items: 0, rate: 0/s (36/min 180/5min 540/15min);
        \_ [OK] Number of events found for Id 1: 2
| '1::ifw_eventlog::count'=2c;;    
```


