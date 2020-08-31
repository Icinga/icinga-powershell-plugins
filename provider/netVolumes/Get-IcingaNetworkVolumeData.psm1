function Get-IcingaNetworkVolumeData()
{
    param(
        [array]$IncludeVolumes = @(),
        [array]$ExcludeVolumes = @()
    );

    $GetSharedVolume = Get-IcingaWindowsInformation -ClassName Win32_MappedLogicalDisk;
    $ClusterDetails  = @{ };

    foreach ($volume in $GetSharedVolume) {
        $details = @{};

        if ($IncludeVolumes.Count -ne 0) {
            if ($IncludeVolumes.Contains($volume.DeviceID) -eq $FALSE) {
                continue;
            }
        }

        if ($ExcludeVolumes.Count -ne 0) {
            if ($ExcludeVolumes.Contains($volume.DeviceID) -eq $TRUE) {
                continue;
            }
        }

        $details.Add('Caption', $volume.Caption);
        $details.Add('Description', $volume.Description);
        $details.Add('InstallDate', $volume.InstallDate);
        $details.Add('Name', $volume.Name);
        $details.Add('Status', $volume.Stus);
        $details.Add('Availability', $volume.Availability);
        $details.Add('ConfigManagerErrorCode', $volume.ConfigManagerErrorCode);
        $details.Add('ConfigManagerUserConfig', $volume.ConfigManagerUserConfig);
        $details.Add('CreationClassName', $volume.CreationClassName);
        $details.Add('DeviceID', $volume.DeviceID);
        $details.Add('ErrorCleared', $volume.ErrorCleared);
        $details.Add('ErrorDescription', $volume.ErrorDescription);
        $details.Add('LastErrorCode', $volume.LastErrorCode);
        $details.Add('PNPDeviceID', $volume.PNPDeviceID);
        $details.Add('PowerManagementCapabilities', $volume.PowerManagementCapabilities);
        $details.Add('PowerManagementSupported', $volume.PowerManagementSupported);
        $details.Add('StatusInfo', $volume.StatusInfo);
        $details.Add('SystemCreationClassName', $volume.SystemCreationClassName);
        $details.Add('SystemName', $volume.SystemName);
        $details.Add('Access', $volume.Access);
        $details.Add('BlockSize', $volume.BlockSize);
        $details.Add('ErrorMethodology', $volume.ErrorMethodology);
        $details.Add('NumberOfBlocks', $volume.NumberOfBlocks);
        $details.Add('Purpose', $volume.Purpose);
        $details.Add('FreeSpace', $volume.FreeSpace);
        $details.Add('Size', $volume.Size);
        $details.Add('Compressed', $volume.Compressed);
        $details.Add('FileSystem', $volume.FileSystem);
        $details.Add('MaximumComponentLength', $volume.MaximumComponentLength);
        $details.Add('ProviderName', $volume.ProviderName);
        $details.Add('QuotasDisabled', $volume.QuotasDisabled);
        $details.Add('QuotasIncomplete', $volume.QuotasIncomplete);
        $details.Add('QuotasRebuilding', $volume.QuotasRebuilding);
        $details.Add('SessionID', $volume.SessionID);
        $details.Add('SupportsDiskQuotas', $volume.SupportsDiskQuotas);
        $details.Add('SupportsFileBasedCompression', $volume.SupportsFileBasedCompression);
        $details.Add('VolumeName', $volume.VolumeName);
        $details.Add('VolumeSerialNumber', $volume.VolumeSerialNumber);
        $details.Add('PSComputerName', $volume.PSComputerName);

        $ClusterDetails.Add($volume.DeviceID, $details);
    }

    return $ClusterDetails;
}
