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
   [CRITICAL] Check package "EventLog" - [CRITICAL] EventId 642 [WARNING] EventId 1008, EventId 2002, EventId 642
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)."
      \_ [WARNING] EventId 2002: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:36] - [27.08.2020 22:57:40] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 14:50:37] - [17.08.2020 19:41:00] there occurred 391 event(s)."
      \_ [WARNING] EventId 642: Value "391" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 14:50:37] - [17.08.2020 19:41:00] there occurred 391 event(s)."
      \_ [WARNING] EventId 642: Value "391" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 15:51:00] - [17.08.2020 19:41:00] there occurred 298 event(s)."
      \_ [WARNING] EventId 642: Value "298" is greater than threshold "100"
   \_ [CRITICAL] Check package "Between: [17.08.2020 19:56:38] - [27.08.2020 09:56:35] there occurred 3539 event(s)."
      \_ [CRITICAL] EventId 642: Value "3539" is greater than threshold "1000"
   \_ [CRITICAL] Check package "Between: [17.08.2020 19:56:38] - [27.08.2020 09:56:35] there occurred 3539 event(s)."
      \_ [CRITICAL] EventId 642: Value "3539" is greater than threshold "1000"
   \_ [CRITICAL] Check package "Between: [17.08.2020 20:03:07] - [27.08.2020 09:56:35] there occurred 2757 event(s)."
      \_ [CRITICAL] EventId 642: Value "2757" is greater than threshold "1000"
.EXAMPLE
   PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000 -IncludeEventId 1008
   [WARNING] Check package "EventLog" - [WARNING] EventId 1008
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:35] - [27.08.2020 22:57:39] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   \_ [WARNING] Check package "Between: [16.08.2020 09:31:36] - [27.08.2020 22:57:40] there occurred 242 event(s)."
      \_ [WARNING] EventId 1008: Value "242" is greater than threshold "100"
   | 'eventid_1008'=726c;;
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
   Used to specify an array of entry types within the eventlog to be included.
.PARAMETER ExcludeEntryType
   Used to specify an array of entry types within the eventlog to be excluded.
.PARAMETER IncludeMessage
   Used to specify an array of messages within the eventlog to be included.
.PARAMETER ExcludeMessage
   Used to specify an array of messages within the eventlog to be excluded.
.PARAMETER IncludeSource
   Used to specify an array of message sources within the eventlog to be included.
.PARAMETER ExcludeSource
   Used to specify an array of message sources within the eventlog to be excluded.
.PARAMETER After
   Used to specify a date like dd.mm.yyyy and every eventlog entry after that date will be considered.
.PARAMETER Before
   Used to specify a date like dd.mm.yyyy and every eventlog entry before that date will be considered.
.PARAMETER DisableTimeCache
   Switch to disable the time cache on a check. If this parameter is set the time cache is disabled.
   After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended.
   This is due to the time cache, when disabled the whole eventlog is checked instead.
.PARAMETER NoPerfData
   Used to disable PerfData.
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
        [array]$IncludeEventId,
        [array]$ExcludeEventId,
        [array]$IncludeUsername,
        [array]$ExcludeUsername,
        [array]$IncludeEntryType,
        [array]$ExcludeEntryType,
        [array]$IncludeMessage,
        [array]$ExcludeMessage,
        [array]$IncludeSource,
        [array]$ExcludeSource,
        $After                    = $null,
        $Before                   = $null,
        [switch]$DisableTimeCache = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity           = 0
    );

    $EventLogPackage = New-IcingaCheckPackage -Name 'EventLog' -OperatorAnd -Verbose $Verbosity;
    $EventLogData    = Get-IcingaEventLog -LogName $LogName -IncludeEventId $IncludeEventId -ExcludeEventId $ExcludeEventId -IncludeUsername $IncludeUsername -ExcludeUsername $ExcludeUsername `
                           -IncludeEntryType $IncludeEntryType -ExcludeEntryType $ExcludeEntryType -IncludeMessage $IncludeMessage -ExcludeMessage $ExcludeMessage `
                           -IncludeSource $IncludeSource -ExcludeSource $ExcludeSource -After $After -Before $Before -DisableTimeCache $DisableTimeCache;

    [hashtable]$EventLogSource = @{};

    if ($EventLogData.eventlog.Count -ne 0) {
        foreach ($event in $EventLogData.eventlog.Keys) {
            $eventEntry = $EventLogData.eventlog[$event];

            $EventLogEntryPackage = New-IcingaCheckPackage -Name ([string]::Format('Between: [{0}] - [{1}] there occurred {2} event(s).', $eventEntry.OldestEntry, $eventEntry.NewestEntry, $eventEntry.Count)) -OperatorAnd -Verbose $Verbosity;
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('EventId {0}', $EventLogData.eventlog[$event].EventId)) -Value $eventEntry.Count -NoPerfData;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $EventLogEntryPackage.AddCheck($IcingaCheck);
            $EventMessage = New-IcingaCheck -Name ([string]::Format('Event Message: {0}', ($eventEntry.Message).Replace("`r`n", '').Replace("`n", ''))) -NoPerfData;
            $EventLogEntryPackage.AddCheck($EventMessage);

            $EventLogPackage.AddCheck($EventLogEntryPackage);
        }

        $EventLogCountPackage = New-IcingaCheckPackage -Name 'EventLog Count' -OperatorAnd -Verbose $Verbosity -Hidden;

        foreach ($event in $EventLogData.events.Keys) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('EventId {0}', $event)) -Value $EventLogData.events[$event] -Unit 'c';
            $EventLogCountPackage.AddCheck($IcingaCheck);
        }

        $EventLogPackage.AddCheck($EventLogCountPackage);
    } else {
        $IcingaCheck = New-IcingaCheck -Name 'No EventLogs found' -Value 0 -Unit 'c' -NoPerfData;
        $EventLogPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Name 'EventLog' -Check $EventLogPackage -NoPerfData $NoPerfData -Compile);
}
