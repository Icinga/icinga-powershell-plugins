function Get-IcingaPartitionSpace()
{
    param (
        [int]$DriveType = 3
    );

    [array]$Volumes = Get-IcingaWindowsInformation Win32_Volume -Filter ([string]::Format('DriveType = "{0}"', $DriveType));
    [hashtable]$DiskData = @{ };

    foreach ($disk in $Volumes) {
        if ($DiskData.ContainsKey($disk.DeviceID)) {
            continue;
        }

        $DiskData.Add(
            $disk.DeviceID,
            @{
                'Size'        = $disk.Capacity;
                'FreeSpace'   = $disk.FreeSpace;
                'UsedSpace'   = ($disk.Capacity - $disk.FreeSpace);
                'DriveLetter' = $disk.DeviceID;
            }
        );
    }

    return $DiskData;
}
