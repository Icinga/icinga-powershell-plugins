function Invoke-IcingaCheckNetworkVolume()
{
    param(
        $Critical           = $null,
        $Warning            = $null,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity          = 0
    );

    $CheckPackage = New-IcingaCheckPackage -Name 'Network Volumes Package' -OperatorAnd -Verbose $Verbosity;

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
