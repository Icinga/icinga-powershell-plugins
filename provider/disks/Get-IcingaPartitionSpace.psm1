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

        # Now loop through all our partitions for the partition with our drive letter and
        # get the actual size from there, ignoring possible user quotas
        foreach ($partition in $Partitions) {
            if ([string]::IsNullOrEmpty($partition.DriveLetter) -or [string]::IsNullOrEmpty($disk.DriveLetter)) {
                continue;
            }

            if ($partition.DriveLetter -ne $disk.DriveLetter.Replace(':', '').Replace('\', '')) {
                continue;
            }

            $DiskSize = [decimal]$partition.Size;
            break;
        }

        $DiskData.Add(
            $disk.Name,
            @{
                'Size'        = $DiskSize;
                'FreeSpace'   = $disk.FreeSpace;
                'UsedSpace'   = ($DiskSize - $disk.FreeSpace);
                'DriveLetter' = $disk.DriveLetter;
                'DriveName'   = $disk.Name;
                'HasLetter'   = -not [string]::IsNullOrEmpty($disk.DriveLetter);
            }
        );
    }

    return $DiskData;
}
