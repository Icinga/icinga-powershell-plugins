function Invoke-IcingaCheckNetworkVolume()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @(),
        $FreeSpaceWarning      = 20,
        $FreeSpaceCritical     = 15,
        [switch]$NoPerfData    = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity             = 0
    );

    $CheckPackage = New-IcingaCheckPackage -Name 'Network Volumes Package' -OperatorAnd -Verbose $Verbosity;
    $GetVolumes   = Get-IcingaNetworkVolumeData -IncludeVolumes $IncludeVolumes -ExcludeVolumes $ExcludeVolumes;

    foreach ($volume in $GetVolumes.Keys) {
        $VolumeObj          = $GetVolumes[$volume];
        $VolumeCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('SharedVolume {0} (Node: {1})', $volume, $VolumeObj.OwnerNode)) -OperatorAnd -Verbose $Verbosity;

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} State', $volume)) `
                    -Value $VolumeObj.State `
                    -NoPerfData
            ).CritIfMatch(
                $ProviderEnums.SharedVolumeState.Offline
            ).CritIfMatch(
                $ProviderEnums.SharedVolumeState.Failed
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Block RedirectedIOReason', $volume)) `
                    -Value $VolumeObj.BlockRedirectedIOReason `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.BlockRedirectedIOReason.StorageSpaceNotAttached
            ).CritIfMatch(
                $ProviderEnums.BlockRedirectedIOReason.NoDiskConnectivity
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} StateInfo', $volume)) `
                    -Value $VolumeObj.StateInfo `
                    -NoPerfData
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} FileSystem RedirectedIOReason', $volume)) `
                    -Value $VolumeObj.FileSystemRedirectedIOReason `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.FileSystemRedirectedIOReason.IncompatibleFileSystemFilter
            ).CritIfMatch(
                $ProviderEnums.FileSystemRedirectedIOReason.IncompatibleVolumeFilter
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} FreeSpace', $volume)) `
                    -Value $VolumeObj.SharedVolumeInfo.Partition.PercentFree `
                    -Unit '%'
            ).WarnIfLowerEqualThan(
                $FreeSpaceWarning
            ).CritIfLowerEqualThan(
                $FreeSpaceCritical
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Fault State', $volume)) `
                    -Value $VolumeObj.SharedVolumeInfo.FaultState `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.SharedVolumeFaultState.InMaintenance
            ).CritIfMatch(
                $ProviderEnums.SharedVolumeFaultState.NoAccess
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} RedirectedAccess', $volume)) `
                    -Value $VolumeObj.SharedVolumeInfo.RedirectedAccess `
                    -NoPerfData
            )
        );

        $CheckPackage.AddCheck($VolumeCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
