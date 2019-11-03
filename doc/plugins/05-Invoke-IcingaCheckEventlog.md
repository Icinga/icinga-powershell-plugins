
# Invoke-IcingaCheckEventlog

## Description

Checks how many eventlog occurences of a given type there are.

Invoke-IcingaCheckEventlog returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g Eventlog returns 500 entrys with the specified parameters, WARNING is set to 200, CRITICAL is set to 800. Thereby the check will return WARNING.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. |
| Critical | Object | false |  | Used to specify a Critical threshold. |
| LogName | String | false |  | Used to specify a certain log. |
| IncludeEventId | Array | false |  | Used to specify an array of events identified by their id to be included. |
| ExcludeEventId | Array | false |  | Used to specify an array of events identified by their id to be excluded. |
| IncludeUsername | Array | false |  | Used to specify an array of usernames within the eventlog to be included. |
| ExcludeUsername | Array | false |  | Used to specify an array of usernames within the eventlog to be excluded. |
| IncludeEntryType | Array | false |  | Used to specify an array of entry types within the eventlog to be included. |
| ExcludeEntryType | Array | false |  | Used to specify an array of entry types within the eventlog to be excluded. |
| IncludeMessage | Array | false |  | Used to specify an array of messages within the eventlog to be included. |
| ExcludeMessage | Array | false |  | Used to specify an array of messages within the eventlog to be excluded. |
| After | Object | false |  | Used to specify a date like dd.mm.yyyy and every eventlog entry after that date will be considered. |
| Before | Object | false |  | Used to specify a date like dd.mm.yyyy and every eventlog entry before that date will be considered. |
| DisableTimeCache | SwitchParameter | false | False | Switch to disable the time cache on a check. If this parameter is set the time cache is disabled. After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended. This is due to the time cache, when disabled the whole eventlog is checked instead. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
```

### Example Output 1

```powershell
[WARNING]: Check package "EventLog" is [WARNING]| 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000[OK]: Check package "EventLog" is [OK]|
```

### Example Command 2

```powershell
Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
```

### Example Output 2

```powershell
[WARNING]: Check package "EventLog" is [WARNING]| 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000 -DisableTimeCache[WARNING]: Check package "EventLog" is [WARNING]| 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;
```
