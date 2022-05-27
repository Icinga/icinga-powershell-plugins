<#
.SYNOPSIS
   Uses a service object fetched by Get-IcingaServices and compares it to an
   provided status to return a New-IcingaCheck object for generic usage.
.DESCRIPTION
   Uses a service object fetched by Get-IcingaServices and compares it to an
   provided status to return a New-IcingaCheck object for generic usage.
.FUNCTIONALITY
   Uses a service object fetched by Get-IcingaServices and compares it to an
   provided status to return a New-IcingaCheck object for generic usage.
.PARAMETER Service
   Service object fetched by Get-IcingaServices (single service entry only)
.PARAMETER Status
   The status of the service to compare it with
.PARAMETER NoPerfData
   Disables the performance data output of this plugin
.INPUTS
   System.Object
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function New-IcingaWindowsServiceCheckObject()
{
    param (
        $Service,
        [ValidateSet('Stopped', 'StartPending', 'StopPending', 'Running', 'ContinuePending', 'PausePending', 'Paused')]
        $Status,
        [switch]$NoPerfData
    );

    $ServiceName     = Get-IcingaServiceCheckName -ServiceInput $Service.metadata.DisplayName -Service $Service;
    $ConvertedStatus = ConvertTo-ServiceStatusCode -Status $Status;
    $StatusRaw       = $Service.configuration.Status.raw;

    $IcingaCheck     = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $Service -Translation $ProviderEnums.ServiceStatusName -MetricIndex $Service.metadata.ServiceName -MetricName 'state' -NoPerfData:$NoPerfData;
    $IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;

    return $IcingaCheck;
}
