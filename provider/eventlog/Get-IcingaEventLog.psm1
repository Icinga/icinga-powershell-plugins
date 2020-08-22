Import-IcingaLib icinga\exception;

function Get-IcingaEventLog()
{
    param(
        [string]$LogName,
        [array]$IncludeEventId,
        [array]$ExcludeEventId,
        [array]$IncludeUsername,
        [array]$ExcludeUsername,
        [array]$IncludeEntryType,
        [array]$ExcludeEntryType,
        [array]$IncludeMessage,
        [array]$ExcludeMessage,
        $After,
        $Before,
        [bool]$DisableTimeCache
    );

    if ([string]::IsNullOrEmpty($LogName)) {
        Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.EventLog -Force;
    }

    [hashtable]$EventLogArguments = @{
        LogName = $LogName;
    };

    # This will generate a unique hash for each possible configured EventLog check to store the last check time for each of these checks
    [string]$CheckHash = (Get-StringSha1 ($LogName + $IncludeEventId + $ExcludeEventId + $IncludeUsername + $ExcludeUsername + $IncludeEntryType + $ExcludeEntryType + $IncludeMessage + $ExcludeMessage)) + '.lastcheck';

    if ($null -eq $After -and $DisableTimeCache -eq $FALSE) {
        $time = Get-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash;
        Set-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash -Value ((Get-Date).ToFileTime());

        if ($null -ne $time) {
            $After = [datetime]::FromFileTime($time);
        }
    }

    if ($null -ne $IncludeEventId) {
        $EventLogArguments.Add('InstanceID', $IncludeEventId);
    }
    if ($null -ne $IncludeUsername) {
        $EventLogArguments.Add('UserName', $IncludeUsername);
    }
    if ($null -ne $IncludeEntryType) {
        $EventLogArguments.Add('EntryType', $IncludeEntryType);
    }
    if ($null -ne $After) {
        $EventLogArguments.Add('After', $After);
    }
    if ($null -ne $Before) {
        $EventLogArguments.Add('Before', $Before);
    }

    try {
        $events = Get-EventLog @EventLogArguments -ErrorAction Stop;
    } catch {
        Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'ParameterBindingValidationException' -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.EventLog;
        Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'System.InvalidOperationException' -CustomMessage (-Join $LogName) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.EventLogLogName;
    }

    if ($null -ne $ExcludeEventId -Or $null -ne $ExcludeUsername -Or $null -ne $ExcludeEntryType -Or $null -ne $ExcludeMessage -Or $null -ne $IncludeMessage) {
        $filteredEvents = @();
        foreach ($event in $events) {
            # Filter out excluded event IDs
            if ($ExcludeEventId.Count -ne 0 -And $ExcludeEventId -contains $event.EventId) {
                continue;
            }

            # Filter out excluded event IDs
            if ($ExcludeUsername.Count -ne 0 -And $ExcludeUsername -contains $event.UserName) {
                continue;
            }

            # Filter out excluded event IDs
            if ($ExcludeEntryType.Count -ne 0 -And $ExcludeEntryType -contains $event.EntryType) {
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

            if ($IncludeMessage.Count -ne 0) {
                $skip = $TRUE;

                foreach ($inMessage in $IncludeMessage) {
                    # Filter for specific message content
                    if ([string]$event.Message -like [string]$inMessage) {
                        $skip = $FALSE;
                        break;
                    }
                }

                if ($skip) {
                    continue;
                }
            }

            $filteredEvents += $event;
        }

        $events = $filteredEvents;
    }

    $groupedEvents = @{
        'eventlog' = @{};
        'events'   = @{};
    };

    foreach ($event in $events) {
        [string]$EventIdentifier = [string]::Format('{0}-{1}',
            $event.EventId,
            $event.Message
        );

        [string]$EventHash = Get-StringSha1 $EventIdentifier;

        if ($groupedEvents.eventlog.ContainsKey($EventHash) -eq $FALSE) {
            $groupedEvents.eventlog.Add(
                $EventHash,
                @{
                    NewestEntry = $event.TimeGenerated;
                    OldestEntry = $event.TimeGenerated;
                    EventId     = $event.EventId;
                    Message     = $event.Message;
                    Severity    = $event.EntryType;
                    Count       = 1;
                }
            );
        } else {
            $groupedEvents.eventlog[$EventHash].OldestEntry = $event.TimeGenerated;
            $groupedEvents.eventlog[$EventHash].Count       += 1;
        }

        if ($groupedEvents.events.ContainsKey($event.EventId) -eq $FALSE) {
            $groupedEvents.events.Add($event.EventId, 1);
        } else {
            $groupedEvents.events[$event.EventId] += 1;
        }
    }

    return $groupedEvents;
}
