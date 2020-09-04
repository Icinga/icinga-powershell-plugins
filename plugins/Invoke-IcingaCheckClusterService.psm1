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

    $ClusterService = Get-IcingaClusterInfo;
    $CheckPackage   = New-IcingaCheckPackage -Name ([string]::Format('{0} Package', $ClusterService.Name)) -OperatorAnd -Verbose $Verbosity;

    $CheckPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name ([string]::Format('{0} Status', $ClusterService.Name)) `
                -Value $ClusterService.Status
        )
    );
}