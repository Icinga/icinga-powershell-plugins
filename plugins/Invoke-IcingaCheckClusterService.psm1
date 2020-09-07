<#
.SYNOPSIS

.DESCRIPTION
#>
function Invoke-IcingaCheckClusterService()
{
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity          = 0
    );

    $ClusterServices = Get-IcingaClusterInfo;
    $CheckPackage    = New-IcingaCheckPackage -Name 'Cluster Services Package' -OperatorAnd -Verbose $Verbosity;

    foreach ($service in $ClusterServices.Keys) {
        $ClusterService      = $ClusterServices[$service];
        $ServiceCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('{0} Package', $service)) -OperatorAnd -Verbose $Verbosity;

        $ServiceCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Status', $service)) `
                    -Value $ClusterService.Status
            )
        );

        $ServiceCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Started', $service)) `
                    -Value $ClusterService.Started
            )
        );

        $ServiceCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Start Mode', $service)) `
                    -Value $ClusterService.StartMode
            )
        );

        $ServiceCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} State', $service)) `
                    -Value $ClusterService.State
            )
        );

        $CheckPackage.AddCheck($ServiceCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}