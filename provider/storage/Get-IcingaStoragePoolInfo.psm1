function Get-IcingaStoragePoolInfo()
{
    param(
        [array]$IncludeStoragePool = @(),
        [array]$ExcludeStoragePool = @(),
        [switch]$IncludePrimordial = $FALSE
    );

    $GetStorage             = Get-IcingaWindowsInformation -ClassName MSFT_StoragePool -Namespace 'Root/Microsoft/Windows/Storage';
    [hashtable]$StorageData = @{ };

    foreach ($Storage in $GetStorage) {
        if ($IncludeStoragePool.Count -ne 0) {
            if (($IncludeStoragePool.Contains($Storage.FriendlyName)) -eq $FALSE) {
                continue;
            }
        }

        if ($ExcludeStoragePool.Count -ne 0) {
            if (($ExcludeStoragePool.Contains($Storage.FriendlyName)) -eq $TRUE) {
                continue;
            }
        }

        if ($IncludePrimordial -eq $FALSE -And ($Storage.IsPrimordial -eq $TRUE)) {
            continue;
        }

        [hashtable]$StoragePoolDetails = @{
            'AllocatedSize'                     = $Storage.AllocatedSize;
            'ClearOnDeallocate'                 = $Storage.ClearOnDeallocate;
            'EnclosureAwareDefault'             = $Storage.EnclosureAwareDefault;
            'FaultDomainAwarenessDefault'       = $Storage.FaultDomainAwarenessDefault;
            'FriendlyName'                      = $Storage.FriendlyName;
            'HealthStatus'                      = $Storage.HealthStatus;
            'IsClustered'                       = $Storage.IsClustered;
            'IsPowerProtected'                  = $Storage.IsPowerProtected;
            'IsPrimordial'                      = $Storage.IsPrimordial;
            'IsReadOnly'                        = $Storage.IsReadOnly;
            'LogicalSectorSize'                 = $Storage.LogicalSectorSize;
            'MediaTypeDefault'                  = $Storage.MediaTypeDefault;
            'Name'                              = $Storage.Name;
            'ObjectId'                          = $Storage.ObjectId;
            'OperationalStatus'                 = $null;
            'OtherOperationalStatusDescription' = $Storage.OtherOperationalStatusDescription;
            'OtherUsageDescription'             = $Storage.OtherUsageDescription;
            'PassThroughClass'                  = $Storage.PassThroughClass;
            'PassThroughIds'                    = $Storage.PassThroughIds;
            'PassThroughNamespace'              = $Storage.PassThroughNamespace;
            'PassThroughServer'                 = $Storage.PassThroughServer;
            'PhysicalSectorSize'                = $Storage.PhysicalSectorSize;
            'ProvisioningTypeDefault'           = $Storage.ProvisioningTypeDefault;
            'PSComputerName'                    = $Storage.PSComputerName;
            'ReadOnlyReason'                    = $Storage.ReadOnlyReason;
            'RepairPolicy'                      = $Storage.RepairPolicy;
            'ResiliencySettingNameDefault'      = $Storage.ResiliencySettingNameDefault;
            'RetireMissingPhysicalDisks'        = $Storage.RetireMissingPhysicalDisks;
            'Size'                              = $Storage.Size;
            'SupportedProvisioningTypes'        = $Storage.SupportedProvisioningTypes;
            'SupportsDeduplication'             = $Storage.SupportsDeduplication;
            'ThinProvisioningAlertThresholds'   = $Storage.ThinProvisioningAlertThresholds;
            'UniqueId'                          = $Storage.UniqueId;
            'Usage'                             = $Storage.Usage;
            'Version'                           = $Storage.Version;
            'WriteCacheSizeDefault'             = $Storage.WriteCacheSizeDefault;
            'WriteCacheSizeMax'                 = $Storage.WriteCacheSizeMax;
            'WriteCacheSizeMin'                 = $Storage.WriteCacheSizeMin;
            'FreeSpace'                         = (Get-IcingaConvertToGigaByte -ByteValues ($Storage.Size - $Storage.AllocatedSize));
            'ProvisionedSpace'                  = $Storage.ProvisionedSpace;
            'Capacity'                          = (Get-IcingaConvertToGigaByte -ByteValues $Storage.Size);
            'TotalUsed'                         = ((Get-IcingaConvertToGigaByte -ByteValues $Storage.Size) - (Get-IcingaConvertToGigaByte -ByteValues ($Storage.Size - $Storage.AllocatedSize)));
        };

        if ($null -ne $Storage.OperationalStatus) {
            $OperationalStatus = @{ };
            foreach ($key in $Storage.OperationalStatus) {
                Add-IcingaHashtableItem -Hashtable $OperationalStatus -Key ([int]$key) -Value ($ProviderEnums.StorageOperationalStatus[[int]$key]) | Out-Null;
            }

            $StoragePoolDetails.OperationalStatus = $OperationalStatus;
        } else {
            $StoragePoolDetails.OperationalStatus = @{ 0 = 'Unknown'; };
        }

        $StorageData.Add($Storage.FriendlyName, $StoragePoolDetails);
    }

    if ($StorageData.Count -eq 0) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'NotFound' -InputString 'No storage pools were found on your system.' -Force;
    }

    return $StorageData;
}
