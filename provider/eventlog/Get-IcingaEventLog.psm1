function Get-IcingaEventLog()
{
    param(
        [string]$LogName,
        [array]$IncludeEventId   = @(),
        [array]$ExcludeEventId   = @(),
        [array]$IncludeUsername  = @(),
        [array]$ExcludeUsername  = @(),
        [array]$IncludeEntryType = @(),
        [array]$ExcludeEntryType = @(),
        [array]$IncludeMessage   = @(),
        [array]$ExcludeMessage   = @(),
        [array]$IncludeSource    = @(),
        [array]$ExcludeSource    = @(),
        $After,
        $Before,
        [int]$MaxEntries         = 40000,
        [bool]$DisableTimeCache
    );

    if ([string]::IsNullOrEmpty($LogName)) {
        Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.EventLog -Force;
    }

    # This will generate a unique hash for each possible configured EventLog check to store the last check time for each of these checks
    [string]$CheckHash    = (Get-StringSha1 ($LogName + $IncludeEventId + $ExcludeEventId + $IncludeUsername + $ExcludeUsername + $IncludeEntryType + $ExcludeEntryType + $IncludeMessage + $ExcludeMessage)) + '.lastcheck';
    [string]$EventsAfter  = $null;
    [string]$EventsBefore = $null;

    if ([string]::IsNullOrEmpty($After) -and $DisableTimeCache -eq $FALSE) {
        $time = Get-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash;
        Set-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash -Value ((Get-Date).ToFileTime());

        if ($null -ne $time) {
            $EventsAfter = ([datetime]::FromFileTime($time)).ToString('yyyy\/MM\/dd HH:mm:ss');
        }
    }

    # In case we are not having cached time execution and not have not overwritten the timestamp, only fetch values from 2 hours in the past
    if ([string]::IsNullOrEmpty($EventsAfter)) {
        if ([string]::IsNullOrEmpty($After)) {
            [string]$EventsAfter = ([datetime]::Now.Subtract([TimeSpan]::FromHours(2))).ToString('yyyy\/MM\/dd HH:mm:ss');
        } else {
            if ((Test-Numeric $After)) {
                $EventsAfter = ([datetime]::Now.Subtract([TimeSpan]::FromSeconds($After))).ToString('yyyy\/MM\/dd HH:mm:ss');
            } else {
                $EventsAfter = $After;
            }
        }
    }

    if ([string]::IsNullOrEmpty($Before) -eq $FALSE) {
        if ((Test-Numeric $Before)) {
            $EventsBefore = ([datetime]::Now.Subtract([TimeSpan]::FromSeconds($Before))).ToString('yyyy\/MM\/dd HH:mm:ss');
        } else {
            $EventsBefore = $Before;
        }
    } else {
        $EventsBefore = ([datetime]::FromFileTime(((Get-Date).ToFileTime()))).ToString('yyyy\/MM\/dd HH:mm:ss')
    }

    [hashtable]$UserFilter     = @{ };
    [hashtable]$SeverityFilter = @{ };
    [array]$FilteredEvents     = @();
    [bool]$MemoryCleared       = $FALSE;

    if ($null -ne $IncludeUsername -And $IncludeUsername.Count -ne 0) {
        foreach ($entry in $IncludeUsername) {
            $UserId = (Get-IcingaUserSID -User $entry);

            if ($UserFilter.ContainsKey($UserId)) {
                continue;
            }

            $UserFilter.Add(
                $UserId,
                'include'
            )
        }
    }

    if ($null -ne $ExcludeUsername -And $ExcludeUsername.Count -ne 0) {
        foreach ($entry in $ExcludeUsername) {
            $UserId = (Get-IcingaUserSID -User $entry);

            if ($UserFilter.ContainsKey($UserId)) {
                if ($UserFilter[$entry] -eq 'include') {
                    $UserFilter[$entry] = 'exclude';
                }
                continue;
            }

            $UserFilter.Add(
                $UserId,
                'exclude'
            )
        }
    }

    if ($null -ne $IncludeEntryType -And $IncludeEntryType.Count -ne 0) {
        foreach ($entry in $IncludeEntryType) {
            [string]$EntryId = $ProviderEnums.EventLogSeverity[$entry];

            if ($SeverityFilter.ContainsKey($EntryId)) {
                continue;
            }

            $SeverityFilter.Add(
                $EntryId,
                'include'
            )
        }
    }

    if ($null -ne $ExcludeEntryType -And $ExcludeEntryType.Count -ne 0) {
        foreach ($entry in $ExcludeEntryType) {
            [string]$EntryId = $ProviderEnums.EventLogSeverity[$entry];

            if ($SeverityFilter.ContainsKey($EntryId)) {
                if ($SeverityFilter[$EntryId] -eq 'include') {
                    $SeverityFilter[$EntryId] = 'exclude';
                }
                continue;
            }

            $SeverityFilter.Add(
                $EntryId,
                'exclude'
            )
        }
    }

    try {
        $events = Get-WinEvent -LogName $LogName -MaxEvents $MaxEntries -ErrorAction Stop;
    } catch {
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'ParameterArgumentValidationError' -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogNegativeEntries;
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'CannotConvertArgumentNoMessage' -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogNoMessageEntries;
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'NoMatchingLogsFound' -CustomMessage (-Join $LogName) -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogLogName;
    }

    if ($UserFilter.Count -ne 0 -Or $SeverityFilter.Count -ne 0 -Or $null -ne $IncludeEventId -Or $null -ne $ExcludeEventId -Or $null -ne $ExcludeUsername -Or $null -ne $ExcludeEntryType -Or $null -ne $ExcludeMessage -Or $null -ne $IncludeMessage -Or $null -ne $IncludeSource -Or $null -ne $ExcludeSource) {
        foreach ($event in $events) {

            if ($event.TimeCreated -lt $EventsAfter) {
                break;
            }

            if ($event.TimeCreated -gt $EventsBefore) {
                continue;
            }

            # Filter out excluded event IDs
            if ($ExcludeEventId.Count -ne 0 -And $ExcludeEventId -contains $event.Id) {
                continue;
            }

            # Filter out excluded events by username
            if ($UserFilter.Count -ne 0 -And $UserFilter.ContainsKey([string]$event.UserId.Value) -And $UserFilter[[string]$event.UserId.Value] -eq 'exclude') {
                continue;
            }

            if ($LogName.ToLower() -ne 'security') {
                # Filter out excluded events by entry type (Error, Warning, ...)
                if ($SeverityFilter.Count -ne 0 -And $SeverityFilter.ContainsKey([string]$event.Level) -And $SeverityFilter[[string]$event.Level] -eq 'exclude') {
                    continue;
                }
            } else {
                if ($SeverityFilter.Count -ne 0 -And $SeverityFilter.ContainsKey([string]$event.Keywords) -And $SeverityFilter[[string]$event.Keywords] -eq 'exclude') {
                    continue;
                }
            }

            # Filter out excluded events message source
            if ($ExcludeSource.Count -ne 0 -And $ExcludeSource -contains $event.ProviderName) {
                continue;
            }

            [bool]$skip = $FALSE;
            foreach ($exMessage in $ExcludeMessage) {
                # Filter out excluded event IDs
                if ([string]$event.Message -like [string]$exMessage) {
                    $skip = $TRUE;
                    break;
                }
            }

            if ($skip) {
                continue;
            }

            $skip = $TRUE;

            if ($IncludeMessage.Count -ne 0) {
                foreach ($inMessage in $IncludeMessage) {
                    # Filter for specific message content
                    if ([string]$event.Message -like [string]$inMessage) {
                        $skip = $FALSE;
                        break;
                    }
                }
            } else {
                $skip = $FALSE;
            }

            # We might be looking for specific event ids
            if ($IncludeEventId.Count -ne 0 -And $IncludeEventId -NotContains $event.Id) {
                $skip = $TRUE;
            }

            # We might be looking for specific event sources
            if ($IncludeSource.Count -ne 0 -And $IncludeSource -NotContains $event.ProviderName) {
                $skip = $TRUE;
            }

            # Filter out excluded events by username
            if ($UserFilter.Count -ne 0 -And $UserFilter.ContainsKey([string]$event.UserId.Value) -eq $FALSE) {
                $skip = $TRUE;
            }

            # Filter out excluded events by entry type (Error, Warning, ...)
            if ($LogName.ToLower() -ne 'security') {
                if ($SeverityFilter.Count -ne 0 -And $SeverityFilter.ContainsKey([string]$event.Level) -eq $FALSE) {
                    $skip = $TRUE;
                }
            } else {
                if ($SeverityFilter.Count -ne 0 -And $SeverityFilter.ContainsKey([string]$event.Keywords) -eq $FALSE) {
                    continue;
                }
            }

            if ($skip) {
                continue;
            }

            $FilteredEvents += $event;
        }

        if ($null -ne $events) {
            if ($null -ne ($events | Get-Member -Name 'Dispose')) {
                $events.Dispose();
            }

            $events        = $null;
            $MemoryCleared = $TRUE;
        }

        $events = $FilteredEvents;
    }

    $groupedEvents = @{
        'eventlog' = @{ };
        'events'   = @{ };
    };

    foreach ($event in $events) {
        [string]$EventIdentifier = [string]::Format('{0}-{1}',
            $event.Id,
            $event.ProviderName
        );

        [string]$EventHash = Get-StringSha1 $EventIdentifier;

        if ($groupedEvents.eventlog.ContainsKey($EventHash) -eq $FALSE) {
            [string]$EventMessage = $event.Message;
            if ([string]::IsNullOrEmpty($EventMessage)) {
                $EventMessage = '';
            }
            $groupedEvents.eventlog.Add(
                $EventHash,
                @{
                    NewestEntry = $event.TimeCreated;
                    OldestEntry = $event.TimeCreated;
                    EventId     = $event.Id;
                    Message     = $EventMessage;
                    Severity    = $ProviderEnums.EventLogSeverityName[$event.Level];
                    Source      = $event.ProviderName;
                    Count       = 1;
                }
            );
        } else {
            $groupedEvents.eventlog[$EventHash].OldestEntry = $event.TimeCreated;
            $groupedEvents.eventlog[$EventHash].Count       += 1;
        }

        if ($groupedEvents.events.ContainsKey($event.Id) -eq $FALSE) {
            $groupedEvents.events.Add($event.Id, 1);
        } else {
            $groupedEvents.events[$event.Id] += 1;
        }
    }

    if ($MemoryCleared -eq $FALSE) {
        if ($null -ne ($events | Get-Member -Name 'Dispose')) {
            $events.Dispose();
        }
    }

    $events         = $null;
    $FilteredEvents = $null;

    return $groupedEvents;
}
