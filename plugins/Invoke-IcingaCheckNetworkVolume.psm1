<#
.SYNOPSIS
    Checks the available space on cluster Shared Volumes and checks additionally availability
    and state of the targeted Cluster Shared Volume from each Cluster nodes.
.DESCRIPTION
    Checks the available space on cluster Shared Volumes and checks additionally availability
    and state of the targeted Cluster Shared Volume from each Cluster nodes. This plugin can only
    run successfully on a Windows Server 2012 or later version. I.e. if you have Windows Server 2008 or older,
    it will unfortunately not work.
.PARAMETER IncludeVolumes
    Used to Filter out which Cluster Shared Volumes you want to check, provided you have
    several SharedVolumes on your system. Example ('Cluster Disk 2')
.PARAMETER ExcludeVolumes
    Used to Filter out which Cluster Shared Volumes you don't want to check, provided you have
    several SharedVolumes on your system. Example ('Cluster Disk 2').
.PARAMETER FreeSpaceWarning
    Used to specify a Warning threshold for the SharedVolume FreeSpaces in %. Example (10)
.PARAMETER FreeSpaceCritical
    Used to specify a Critical threshold for the SharedVolume FreeSpaces in %. Example (5)
.PARAMETER NoPerfData
    You can set this to true if you want display the Performance Data as well. Default to false.
.PARAMETER Verbosity
    Make the Plugin Output verbose mode e.g 0/1/2. Default(0).
.LINK
    https://github.com/Icinga/icinga-powershell-framework
    https://github.com/Icinga/icinga-powershell-plugins
#>
function Invoke-IcingaCheckNetworkVolume()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @(),
        $FreeSpaceWarning      = $null,
        $FreeSpaceCritical     = $null,
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
