function Get-IcingaPartitionSpace()
{
    param (
        [int]$DriveType = 3
    );

    [array]$LogicalDisks = Get-IcingaWindowsInformation Win32_LogicalDisk -Filter ([string]::Format('DriveType = "{0}"', $DriveType));
    [hashtable]$DiskData = @{ };

    foreach ($disk in $LogicalDisks) {
        if ($DiskData.ContainsKey($disk.DeviceID)) {
            continue;
        }

        $DiskData.Add(
            $disk.DeviceID,
            @{
                'Size'        = $disk.Size;
                'FreeSpace'   = $disk.FreeSpace;
                'UsedSpace'   = ($disk.Size - $disk.FreeSpace);
                'DriveLetter' = $disk.DeviceID;
            }
        );
    }

    return $DiskData;
}
