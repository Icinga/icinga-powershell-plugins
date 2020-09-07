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

    $CheckPackage    = New-IcingaCheckPackage -Name 'Cluster Services Package' -OperatorAnd -Verbose $Verbosity;
    $ServicesCheck   = New-IcingaCheckPackage -Name 'Services Package' -OperatorAnd -Verbose $Verbosity;
    $ClusterServices = Get-IcingaClusterInfo;
    $GetClusServices = Get-IcingaServices -Service @(
        'ClusSvc',
        'StarWindClusterService',
        'MSiSCSI'
    );

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

    foreach ($ClusService in $GetClusServices.Keys) {
        $ServiceObj    = $GetClusServices[$ClusService];
        $Check = New-IcingaCheck `
            -Name ([string]::Format('{0} Status', $ClusService)) `
            -Value $ServiceObj.configuration.Status.value;

        if (([string]::IsNullOrEmpty($ServiceObj.configuration.ExitCode) -eq $FALSE ) -And ($ServiceObj.configuration.ExitCode -ne 0) -And ($ServiceObj.configuration.Status.value -ne $ProviderEnums.ServiceStatusName.Running)) {
            $Check.CritIfNotMatch($ProviderEnums.ServiceStatusName.Running) | Out-Null;
        } elseif ($ClusService -eq 'MSiSCSI' -And ($ServiceObj.configuration.Status.value -ne $ProviderEnums.ServiceStatusName.Running)) {
            $Check.CritIfNotMatch($ProviderEnums.ServiceStatusName.Running) | Out-Null;
        }

        $ServicesCheck.AddCheck($Check);
    }

    if ($ServicesCheck.HasChecks()) {
        $CheckPackage.AddCheck($ServicesCheck);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}