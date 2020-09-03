function Get-IcingaNetworkVolumeData()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @()
    );

    if (-Not (Get-Command Get-ClusterSharedVolume -ErrorAction SilentlyContinue)) {
        Exit-IcingaThrowException `
            -CustomMessage 'Null-Command: Class "Get-ClusterSharedVolume": Error "InvalidCmdlet"' `
            -InputString ([string]::Format(
                'The already mentioned class could not be found on your system. {0}{1}',
                (New-IcingaNewLine),
                '"Get-ClusterSharedVolume" is only available on Windows Server 2012 and later.'
            ));
    }

    $GetSharedVolume = Get-ClusterSharedVolume;
    $ClusterDetails  = @{ };

    foreach ($volume in $GetSharedVolume) {
        $SharedVolumeState         = Get-ClusterSharedVolume -Name $volume.Name | Get-ClusterSharedVolumeState;
        $VolumeInfo                = $volume | Select-Object -Expand SharedVolumeInfo;
        $details                   = @{
            'OwnerNode'        = @{};
            'SharedVolumeInfo' = @{
                'Partition' = @{
                    'MountPoints' = @{ };
                };
            };
        };

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

        $details.Add('Id', $volume.Caption);
        $details.Add('State', $volume.State);
        $details.Add('Name', $volume.Name);

        foreach ($node in $SharedVolumeState) {
            $details.OwnerNode.Add(
                $node.Node, @{
                    'Node'                         = $node.Node;
                    'Name'                         = $node.Name;
                    'BlockRedirectedIOReason'      = $node.BlockRedirectedIOReason;
                    'FileSystemRedirectedIOReason' = $node.FileSystemRedirectedIOReason;
                    'StateInfo'                    = $node.StateInfo;
                    'VolumeFriendlyName'           = $node.VolumeFriendlyName;
                    'VolumeName'                   = $node.VolumeName;
                }
            );
        }

        foreach ($item in $VolumeInfo) {
            $details.SharedVolumeInfo.Add('FaultState', $item.FaultState);
            $details.SharedVolumeInfo.Add('FriendlyVolumeName', $item.FriendlyVolumeName);
            $details.SharedVolumeInfo.Add('MaintenanceMode', $item.MaintenanceMode);
            $details.SharedVolumeInfo.Add('PartitionNumber', $item.PartitionNumber);
            $details.SharedVolumeInfo.Add('RedirectedAccess', $item.RedirectedAccess);
            $details.SharedVolumeInfo.Add('VolumeOffset', $item.VolumeOffset);

            $details.SharedVolumeInfo.Partition.Add('DriveLetter', $item.Partition.DriveLetter);
            $details.SharedVolumeInfo.Partition.Add('DriveLetterMask', $item.Partition.DriveLetterMask);
            $details.SharedVolumeInfo.Partition.Add('FileSystem', $item.Partition.FileSystem);
            $details.SharedVolumeInfo.Partition.Add('FreeSpace', $item.Partition.FreeSpace);
            $details.SharedVolumeInfo.Partition.Add('HasDriveLetter', $item.Partition.HasDriveLetter);
            $details.SharedVolumeInfo.Partition.Add('IsCompressed', $item.Partition.IsCompressed);
            $details.SharedVolumeInfo.Partition.Add('IsDirty', $item.Partition.IsDirty);
            $details.SharedVolumeInfo.Partition.Add('IsFormatted', $item.Partition.IsFormatted);
            $details.SharedVolumeInfo.Partition.Add('IsNtfs', $item.Partition.IsNtfs);
            $details.SharedVolumeInfo.Partition.Add('IsPartitionNumberValid', $item.Partition.IsPartitionNumberValid);
            $details.SharedVolumeInfo.Partition.Add('Name', $item.Partition.Name);
            $details.SharedVolumeInfo.Partition.Add('PartitionNumber', $item.Partition.PartitionNumber);
            $details.SharedVolumeInfo.Partition.Add('PercentFree', ([Math]::Round($item.Partition.PercentFree, 2)));
            $details.SharedVolumeInfo.Partition.Add('Size', $item.Partition.Size);
            $details.SharedVolumeInfo.Partition.Add('UsedSpace', $item.Partition.UsedSpace);
            $details.SharedVolumeInfo.Partition.MountPoints = $item.Partition.MountPoints;
        }

        $ClusterDetails.Add($volume.Name, $details);
    }

    return $ClusterDetails;
}
