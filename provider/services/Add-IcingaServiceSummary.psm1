<#
.SYNOPSIS
   Compares the provided state of a service and adds the result to an internal hashtable
   to get to know the amount of services within a specific state, including amount of services.

   Use the returned hashtable of this function as hashtable object for the -ServiceData argument
   to add multiple service data on top of each other within a loop for example.
.DESCRIPTION
   Compares the provided state of a service and adds the result to an internal hashtable
   to get to know the amount of services within a specific state, including amount of services.

   Use the returned hashtable of this function as hashtable object for the -ServiceData argument
   to add multiple service data on top of each other within a loop for example.
.FUNCTIONALITY
   Returns a hashtable with counts for states services are set to. Use this hashtable within a
   loop as argument of -ServiceData to continually increases the count for different service states
.EXAMPLE
   PS> Add-IcingaServiceSummary -ServiceStatus 4 -ServiceData $null;
.EXAMPLE
   PS> Add-IcingaServiceSummary -ServiceStatus 4 -ServiceData $MyHashtable;
.PARAMETER ServiceStatus
   The current status of the service as integer
.PARAMETER ServiceData
   A hashtable object in which the status counts are stored in. If no object is given or the
   hashtable is empty, as new hashtable will be initialized
.INPUTS
   System.Hashtable
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Add-IcingaServiceSummary()
{
    param (
        [int]$ServiceStatus     = 0,
        [hashtable]$ServiceData = $null
    );

    if ($null -eq $ServiceData -Or $ServiceData.Count -eq 0) {
        $ServiceData = @{
            'StoppedCount'         = 0;
            'StartPendingCount'    = 0;
            'StopPendingCount'     = 0;
            'RunningCount'         = 0;
            'ContinuePendingCount' = 0;
            'PausePendingCount'    = 0;
            'PausedCount'          = 0;
            'ServicesCounted'      = 0;
        }
    }

    switch($ServiceStatus) {
        $ProviderEnums.ServiceStatus.Stopped {
            $ServiceData.StoppedCount += 1;
        };
        $ProviderEnums.ServiceStatus.StartPending {
            $ServiceData.StartPendingCount += 1;
        };
        $ProviderEnums.ServiceStatus.StopPending {
            $ServiceData.StopPendingCount += 1;
        };
        $ProviderEnums.ServiceStatus.Running {
            $ServiceData.RunningCount += 1;
        };
        $ProviderEnums.ServiceStatus.ContinuePending {
            $ServiceData.ContinuePendingCount += 1;
        };
        $ProviderEnums.ServiceStatus.PausePending {
            $ServiceData.PausePendingCount += 1;
        };
        $ProviderEnums.ServiceStatus.Paused {
            $ServiceData.PausedCount += 1;
        };
    }

    $ServiceData.ServicesCounted += 1;

    return $ServiceData;
}
