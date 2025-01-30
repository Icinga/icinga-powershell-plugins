<#
.SYNOPSIS
    Checks how many eventlog occurrences of a given type there are.
.DESCRIPTION
    Invoke-IcingaCheckEventlog returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g Eventlog returns 500 entries with the specified parameters, WARNING is set to 200, CRITICAL is set to 800. Thereby the check will return WARNING.

    By default if no time frame is selected with `-After` for example, the plugin will fetch EventLog information from the last two hours.
    In case your are not using `-DisableTimeCache`, the plugin will after the first execution only collect the delta between the last
    execution time and the current execution time.

    More Information on https://github.com/Icinga/icinga-powershell-plugins
    .FUNCTIONALITY
    This Module is intended to be used to check how many eventlog occurrences of a given type there are.
    Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### Required User Groups

    * Event Log Reader
.EXAMPLE
    PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
    [WARNING] Eventlog Application: 1 Warning 2 Ok [WARNING] Event source Icinga 2
    \_ [WARNING] Event source Icinga 2
        \_ [WARNING] Found 123 event(s) for event id 1 in timeframe [03/12/2024 16:37:54] - [03/14/2024 11:07:37]
            \_ [WARNING] Number of events found for Id 1: 123 is greater than threshold 100
    | '1::ifw_eventlog::count'=123c;; '1008::ifw_eventlog::count'=11c;; '10010::ifw_eventlog::count'=11c;;
.EXAMPLE
    PS> Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2 -After 4h -Before 2h
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
.EXAMPLE
    PS> Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2 -After '2024/03/14 10:00'
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
.EXAMPLE
    PS> Invoke-IcingaCheckEventlog -LogName Application -Verbosity 2
    [OK] Eventlog Application: 1 Ok
    \_ [OK] Event source Icinga 2
        \_ [OK] Found 2 event(s) for event id 1 in timeframe [03/14/2024 11:09:37] - [03/14/2024 11:09:47]
            \_ [OK] Event Message: information/RemoteCheckQueue: items: 0, rate: 0/s (36/min 180/5min 540/15min);
            \_ [OK] Number of events found for Id 1: 2
    | '1::ifw_eventlog::count'=2c;;
.PARAMETER Warning
    Used to specify a Warning threshold.
.PARAMETER Critical
    Used to specify a Critical threshold.
.PARAMETER LogName
    Used to specify a certain log.
.PARAMETER IncludeEventId
    Used to specify an array of events identified by their id to be included.
.PARAMETER ExcludeEventId
    Used to specify an array of events identified by their id to be excluded.
.PARAMETER IncludeUsername
    Used to specify an array of usernames within the eventlog to be included.
.PARAMETER ExcludeUsername
    Used to specify an array of usernames within the eventlog to be excluded.
.PARAMETER IncludeEntryType
    Used to specify an array of entry types within the eventlog to be included. Please note that
    `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog.
.PARAMETER ExcludeEntryType
    Used to specify an array of entry types within the eventlog to be excluded. Please note that
    `SuccessAudit` and `FailureAudit` only apply to the `Security` EventLog.
.PARAMETER IncludeMessage
    Used to specify an array of messages within the eventlog to be included.
.PARAMETER ExcludeMessage
    Used to specify an array of messages within the eventlog to be excluded.
.PARAMETER IncludeSource
    Used to specify an array of message sources within the eventlog to be included.
.PARAMETER ExcludeSource
    Used to specify an array of message sources within the eventlog to be excluded.
.PARAMETER ProblemId
    Used to specify an array of event IDs that should be marked as problems. These event IDs will be compared to the provided AcknowledgeIds.
    If no event ID for an AcknowledgeId is found after the corresponding problem event ID has occurred, it will be marked as a problem.
    If you provide multiple ProblemIds, you must specify the same number of AcknowledgeIds. If you have multiple ProblemIds but only one AcknowledgeId,
    you need to add the AcknowledgeId multiple times to the AcknowledgeIds array.
.PARAMETER AcknowledgeId
    Used to specify an array of event IDs that should be marked as acknowledged. These event IDs will be compared to the provided ProblemIds.
    If no event ID for a ProblemId is found it will be marked as a problem. If you provide multiple ProblemIds, you must specify the same number of AcknowledgeIds.
    If you have multiple ProblemIds but only one AcknowledgeId, you need to add the AcknowledgeId multiple times to this array.
.PARAMETER After
    Defines the starting point on which timeframe the plugin will start to read event log information.
    Using 4h as argument as example, will provide all entries from the time the plugin was executed to the past 4 hours.
    For thresholds you can be very specific by providing the time in a time format or by using simple time metrics by their units. Examples:

    "2024/01/01 12:00:00": Will start reading eventlogs after the 1st January 2024 12:00 CET
    "2024/01/15": Will start reading eventlogs after the 15th January 2024 00:00 CET
    "4h": Will read the past 4 hours
    "1d": Will read the past day (24 hours)

    Allowed units for time metrics: ms, s, m, h, d, w, M, y

    Example
    <pre> Start of EventLog       Plugin Execution
    v                After 4h              v
    |--------------------|-----------------|
    10:00              12:00           16:00
    | Not fetched        | Fetched         |</pre>
.PARAMETER Before
    Defines the end point on which timeframe the plugin will stop to read event log information.
    Using 2h as argument as example, will ignore all events of the past 2 hours from the time the plugin was executed. This should be
    used in combination with the "-After" argument. As example, you could provide "-After 6h" to start reading all eventlogs from the past
    6 hours, and use "-Before 2h" to skip the last 2 hours. In this scenario, would receive 4 hours of eventlogs, while the last 2 hours
    have been ignored.
    For thresholds you can be very specific by providing the time in a time format or by using simple time metrics by their units. Examples:

    "2024/01/01 12:00:00": Will stop reading eventlogs after the 1st January 2024 12:00 CET
    "2024/01/15": Will stop reading eventlogs after the 15th January 2024 00:00 CET
    "4h": Will ignore eventlogs of the past 4 hours
    "1d": Will ignore eventlogs of the past day (24 hours)

    Allowed units for time metrics: ms, s, m, h, d, w, M, y

    Example
    <pre> Start of EventLog        Plugin Execution
    v         After 6h           Before 2h  v
    |-------------|------------------|------|
    8:00        10:00              14:00    16:00
    | Not fetched | Fetched          | Not fetched</pre>
.PARAMETER MaxEntries
    Allows to limit the amount of log entries fetched by Get-WinEvent, to increase performance and reduce system load impact
    Should match the average amount of log files written for the intended time range filtered
.PARAMETER DisableTimeCache
    Switch to disable the time cache on a check. If this parameter is set the time cache is disabled.
    After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended.
    This is due to the time cache, when disabled the whole eventlog is checked instead.
.PARAMETER NoPerfData
    Used to disable PerfData.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckEventlog()
{
    param(
        $Warning                  = $null,
        $Critical                 = $null,
        [string]$LogName,
        [array]$IncludeEventId    = @(),
        [array]$ExcludeEventId    = @(),
        [array]$IncludeUsername   = @(),
        [array]$ExcludeUsername   = @(),
        [ValidateSet('Information', 'Warning', 'Error', 'SuccessAudit', 'FailureAudit')]
        [array]$IncludeEntryType  = @(),
        [ValidateSet('Information', 'Warning', 'Error', 'SuccessAudit', 'FailureAudit')]
        [array]$ExcludeEntryType  = @(),
        [array]$IncludeMessage    = @(),
        [array]$ExcludeMessage    = @(),
        [array]$IncludeSource     = @(),
        [array]$ExcludeSource     = @(),
        [array]$ProblemId         = @(),
        [array]$AcknowledgeId     = @(),
        $After                    = $null,
        $Before                   = $null,
        [int]$MaxEntries          = 40000,
        [switch]$DisableTimeCache = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity           = 0
    );

    [hashtable]$SourceCache = @{ };
    $EventLogPackage        = New-IcingaCheckPackage -Name ([string]::Format('Eventlog {0}', $LogName)) -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $EventLogProblems       = New-IcingaCheckPackage -Name 'Not acknowledged problems' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;
    $EventLogData           = Get-IcingaProviderDataValuesEventlog -ProviderFilter @{
        'Eventlog' = @{
            'LogName'          = $LogName;
            'IncludeEventId'   = $IncludeEventId;
            'ExcludeEventId'   = $ExcludeEventId;
            'IncludeUsername'  = $IncludeUsername;
            'ExcludeUsername'  = $ExcludeUsername;
            'IncludeEntryType' = $IncludeEntryType;
            'ExcludeEntryType' = $ExcludeEntryType;
            'IncludeMessage'   = $IncludeMessage;
            'ExcludeMessage'   = $ExcludeMessage;
            'IncludeSource'    = $IncludeSource;
            'ExcludeSource'    = $ExcludeSource;
            'ProblemId'        = $ProblemId;
            'AcknowledgeId'    = $AcknowledgeId;
            'EventsAfter'      = $After;
            'EventsBefore'     = $Before;
            'MaxEntries'       = $MaxEntries;
            'DisableTimeCache' = $DisableTimeCache;
        }
    };

    if ($EventLogData.Metrics.HasEvents) {
        foreach ($event in (Get-IcingaProviderElement $EventLogData.Metrics.List)) {

            $EventLogSourcePackage = $null;
            $eventEntry            = $event.Value;

            if ($SourceCache.ContainsKey($eventEntry.Source) -eq $FALSE) {
                $EventLogSourcePackage = New-IcingaCheckPackage -Name ([string]::Format('Event source {0}', $eventEntry.Source)) -OperatorAnd -Verbose $Verbosity;
                $SourceCache.Add($eventEntry.Source, $EventLogSourcePackage);
            } else {
                $EventLogSourcePackage = $SourceCache[$eventEntry.Source];
            }

            $EventLogEntryPackage  = New-IcingaCheckPackage -Name (
                [string]::Format('Found {0} event(s) for event id {1} in timeframe [{2}] - [{3}]',
                    $eventEntry.Count,
                    $eventEntry.EventId,
                    $eventEntry.OldestEntry,
                    $eventEntry.NewestEntry
                )
            ) -OperatorAnd -Verbose $Verbosity;

            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Number of events found for Id {0}', $eventEntry.EventId)) -Value $eventEntry.Count -NoPerfData;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $EventLogEntryPackage.AddCheck($IcingaCheck);
            $EventMessage = New-IcingaCheck -Name 'Event Message' -NoPerfData -NoHeaderReport;
            $EventMessage.SetOk(([string]::Format('{0}', ($eventEntry.Message).Replace("`r`n", '').Replace("`n", ''))), $TRUE) | Out-Null;
            $EventLogEntryPackage.AddCheck($EventMessage);

            $EventLogSourcePackage.AddCheck($EventLogEntryPackage);
        }

        foreach ($event in (Get-IcingaProviderElement $EventLogData.Metrics.Problems)) {
            $eventEntry   = $event.Value;
            $EventProblem = New-IcingaCheckPackage -Name ([string]::Format('Event Id {0}', $eventEntry.EventId)) -OperatorAnd -Verbose $Verbosity;
            $EventCount   = New-IcingaCheck -Name 'Not acknowledged Events' -Value $eventEntry.Count -Unit 'c' -NoPerfData;
            $EventCount.SetCritical($eventEntry.Count, $TRUE) | Out-Null;
            $EventMessage = New-IcingaCheck -Name 'Message' -Value $eventEntry.Message -NoPerfData;

            $EventProblem.AddCheck($EventCount);
            $EventProblem.AddCheck($EventMessage);

            $EventLogProblems.AddCheck($EventProblem);
        }

        foreach ($entry in $SourceCache.Keys) {
            $EventLogPackage.AddCheck($SourceCache[$entry]);
        }

        $EventLogCountPackage = New-IcingaCheckPackage -Name 'EventLog Count' -OperatorAnd -Verbose $Verbosity -Hidden;

        foreach ($event in (Get-IcingaProviderElement $EventLogData.Metrics.Events)) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('EventId {0}', $event.Name)) -Value $event.Value -Unit 'c' -MetricIndex $event.Name -MetricName 'count';
            $EventLogCountPackage.AddCheck($IcingaCheck);
        }

        $EventLogPackage.AddCheck($EventLogCountPackage);
        $EventLogPackage.AddCheck($EventLogProblems);
    } else {
        $IcingaCheck = New-IcingaCheck -Name 'Events found matching the filter' -Value 0 -Unit 'c' -NoPerfData;
        $EventLogPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Name 'EventLog' -Check $EventLogPackage -NoPerfData $NoPerfData -Compile);
}
