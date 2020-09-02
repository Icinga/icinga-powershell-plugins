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

    foreach ($volume in $GetVolumes.Keys) {
        $VolumeObj = $GetVolumes[$volume];
        $VolumeCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('SharedVolume {0} (Node: {1})', $volume, $volume.OwnerNode)) -OperatorAnd -Verbose $Verbosity;

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('vol_ {0} State', $volume)) `
                    -Value $PartObject.State `
                    -NoPerfData
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('vol_ {0} FreeSpace', $volume)) `
                    -Value $PartObject.SharedVolumeInfo.Partition.PercentFree `
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
                    -Name ([string]::Format('vol_ {0} Capacity', $volume)) `
                    -Value ($PartObject.SharedVolumeInfo.Partition.Size / 1GB) `
                    -Unit 'GB'
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('vol_ {0} TotalUsed', $volume)) `
                    -Value ($PartObject.SharedVolumeInfo.Partition.UsedSpace / 1GB) `
                    -Unit 'GB'
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('vol_ {0} Fault State', $volume)) `
                    -Value $PartObject.SharedVolumeInfo.FaultState `
                    -NoPerfData
            )
        );

        $VolumeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('vol_ {0} RedirectedAccess', $volume)) `
                    -Value $PartObject.SharedVolumeInfo.RedirectedAccess `
                    -NoPerfData
            )
        );

        $CheckPackage.AddCheck($VolumeCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
