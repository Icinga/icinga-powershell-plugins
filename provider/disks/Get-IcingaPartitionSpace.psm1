function Get-IcingaPartitionSpace()
{
    param (
        [int]$DriveType = 3
    );

    [array]$Volumes      = Get-IcingaWindowsInformation Win32_Volume -Filter ([string]::Format('DriveType = "{0}"', $DriveType));
    # Lets store all partition data, required to get actual partition sizes ignoring user quotas
    [array]$Partitions   = Get-Partition;
    [hashtable]$DiskData = @{ };

    foreach ($disk in $Volumes) {
        if ([string]::IsNullOrEmpty($disk.Name)) {
            continue;
        }

        if ($DiskData.ContainsKey($disk.Name)) {
            continue;
        }

        # Create a fallback value - shouldn't apply anyway
        [decimal]$DiskSize = $disk.Capacity;

        # Now loop through all our partitions and check if the disk device id
        # is mapped to one of the partitions access paths
        foreach ($partition in $Partitions) {
            if ($partition.AccessPaths -notcontains $disk.DeviceID) {
                continue;
            }

            $DiskSize = [decimal]$partition.Size;
            break;
        }

        $UsedSpace = $null;

        if ($null -ne $disk.FreeSpace) {
            $UsedSpace = $DiskSize - [decimal]$disk.FreeSpace;
        }

        $DiskData.Add(
            $disk.Name,
            @{
                'Size'        = $DiskSize;
                'FreeSpace'   = $disk.FreeSpace;
                'UsedSpace'   = $UsedSpace;
                'DriveLetter' = $disk.DriveLetter;
                'DriveName'   = $disk.Name;
                'HasLetter'   = -not [string]::IsNullOrEmpty($disk.DriveLetter);
            }
        );
    }

    return $DiskData;
}
