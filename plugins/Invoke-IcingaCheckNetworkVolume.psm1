function Invoke-IcingaCheckNetworkVolume()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @(),
        $FreeSpaceWarning      = '20',
        $FreeSpaceCritical     = '15',
        [switch]$NoPerfData    = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity             = 0
    );

    $CheckPackage = New-IcingaCheckPackage -Name 'Network Volumes Package' -OperatorAnd -Verbose $Verbosity;
    $GetVolumes   = Get-IcingaNetworkVolumeData -IncludeVolumes $IncludeVolumes -ExcludeVolumes $ExcludeVolumes;

    foreach ($volume in $GetVolumes.keys) {
        $VolumeObj = $GetVolumes[$volume];
        $VolumeCheckPackage = New-IcingaCheckPackage -Name $volume -OperatorAnd -Verbose $Verbosity;

        foreach ($partition in $VolumeObj.Disk.Keys) {
            $PartObject = $VolumeObj.Disk[$partition];
            $VolumeCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('vol_ {0} {1} FreeSpace', $volume, $partition)) `
                        -Value $PartObject.PercentFree `
                        -Unit '%'
                ).WarnIfLowerEqualThan(
                    $FreeSpaceWarning
                ).CritIfLowerEqualThan(
                    $FreeSpaceCritical
                )
            );
        }

        $CheckPackage.AddCheck($VolumeCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
