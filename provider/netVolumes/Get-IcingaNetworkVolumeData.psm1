function Get-IcingaNetworkVolumeData()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @()
    );

    $GetSharedVolume = Get-IcingaWindowsInformation -ClassName MSCluster_ClusterSharedVolume -Namespace 'Root\MSCluster';
    $ClusterDetails  = @{ };

    foreach ($volume in $GetSharedVolume) {
        $details    = @{'Disk' = @{}; };
        $VolumeInfo = $volume | Select-Object -ExpandProperty 'SharedVolumeInfo';

        if ($IncludeVolumes.Count -ne 0) {
            if ($IncludeVolumes.Contains($volume.Name) -eq $FALSE) {
                continue;
            }
        }

        if ($ExcludeVolumes.Count -ne 0) {
            if ($ExcludeVolumes.Contains($volume.Name) -eq $TRUE) {
                continue;
            }
        }

        $details.Add('Caption', $volume.Caption);
        $details.Add('Description', $volume.Description);
        $details.Add('InstallDate', $volume.InstallDate);
        $details.Add('Name', $volume.Name);
        $details.Add('Status', $volume.Stus);
        $details.Add('Flags', $volume.Flags);
        $details.Add('Characteristics', $volume.Characteristics);
        $details.Add('VolumeName', $volume.VolumeName);
        $details.Add('FaultState', $volume.FaultState);
        $details.Add('VolumeOffset', $volume.VolumeOffset);
        $details.Add('BackupState', $volume.BackupState);
        $details.Add('PSComputerName', $volume.PSComputerName);

        foreach ($item in $VolumeInfo) {
            $details.Disk.Add(
                $item.Name, @{
                    'Name'        = $item.Name;
                    'Path'        = $item.FriendlyVolumeName;
                    'Size'        = $item.Partition.Size;
                    'FreeSpace'   = $item.Partition.FreeSpace;
                    'UsedSpace'   = $item.Partition.UsedSpace;
                    'PercentFree' = $item.Partition.PercentFree;
                }
            );
        }

        $ClusterDetails.Add($volume.Name, $details);
    }

    return $ClusterDetails;
}
