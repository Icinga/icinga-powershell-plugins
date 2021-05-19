<#
.SYNOPSIS
    Checks availability, utilization and state of a StoragePool.
.DESCRIPTION
    Invoke-IcingaCheckStoragePool Checks the availability, utilization and state of a StoragePool. If no
    StoragePool can be found on your system then an UNKNOWN check package is thrown with the corresponding error message.
.ROLE
    ### WMI Permissions

    * Root/Microsoft/Windows/Storage
.PARAMETER IncludeStoragePool
    With this parameter you can filter out which StoragePools you want to check, provided you have several StoragePools on your system.
.PARAMETER ExcludeStoragePool
    With this parameter you can filter out which StoragePools you do not want to check, provided you have several StoragePools on your system.
.PARAMETER IncludePrimordial
    A primordial pool, also known as the 'available storage' pool is where storage capacity is drawn and returned in the
    creation and deletion of concrete storage pools. Primordial pools cannot be created or deleted. You can set this to
    true if you also want to check Primordial StoragePools. Default to false.
.PARAMETER FreeSpaceWarning
    Used to specify a Warning threshold for the StoragePool FreeSpaces in GB. This value is a decreasing metric which will require
    you to add a ':' behind the threshold, like '20GB:' to check if free space is lower compared to your threshold
.PARAMETER FreeSpaceCritical
    Used to specify a Critical threshold for the StoragePool FreeSpaces in GB. This value is a decreasing metric which will require
    you to add a ':' behind the threshold, like '20GB:' to check if free space is lower compared to your threshold
.PARAMETER TotalUsedWarning
    Used to specify TotalUsed Warning threshold in GB.
.PARAMETER TotalUsedCritical
    Used to specify TotalUsed Critical threshold in GB.
.PARAMETER IsReadOnlyCritical
    Used to specify a Critical threshold for the StoragePool IsReadOnly Attr.
.PARAMETER CapacityWarning
    Used to specify a Warning threshold for the StoragePool Capacity.
.PARAMETER CapacityCritical
    Used to specify a Critical threshold for the StoragePool Capacity.
.PARAMETER ClearOnDeallocateCritical
    Critical threshold for StoragePool ClearOnDeallocate is, if physical disks should be zeroed (cleared of all data) when
    unmapped or removed from the storage pool.
.PARAMETER SupportsDeduplicationCritical
    Critical threshold StoragePool SupportsDeduplication is, whether the storage pool supports data duplication or not.
.PARAMETER IsPowerProtectedCritical
    Critical threshold for StoragePool IsPowerProtected is, whether the disks in this pool are able to tolerate power loss without data loss.
    For example, they automatically flush volatile buffers to non-volatile media after external power is disconnected.
.PARAMETER HealthStatusWarning
    Warning threshold for Health of StoragePool is whether or not the storage pool can maintain the required redundancy levels.
.PARAMETER HealthStatusCritical
    Critical threshold for Health of StoragePool is whether or not the storage pool can maintain the required redundancy levels.
.PARAMETER RetireMissingPhysicalDisksWarning
    Warning threshold RetireMissingPhysicalDisks specifies whether the storage subsystem will automatically retire physical disks that are missing from this
    storage pool and replace them with hot spares or other physical disks that are available in the storage pool.
.PARAMETER RetireMissingPhysicalDisksCritical
    Critical threshold RetireMissingPhysicalDisks specifies whether the storage subsystem will automatically retire physical disks that are missing from this
    storage pool and replace them with hot spares or other physical disks that are available in the storage pool.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin. Default to FALSE.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> icinga { Invoke-IcingaCheckStoragePool -Verbosity 2 }
    [OK] Check package "Storage Pools Package" (Match All)
    \_ [OK] Check package "StoragePool1" (Match All)
       \_ [OK] StoragePool1: Capacity: 18.97GB
       \_ [OK] StoragePool1: Clear OnDeallocate: False
       \_ [OK] StoragePool1: FreeSpace: 18.47GB
       \_ [OK] StoragePool1: Health Status: Healthy
       \_ [OK] StoragePool1: Is PowerProtected: False
       \_ [OK] StoragePool1: Is ReadOnly: False
       \_ [OK] StoragePool1: Operational Status: OK
       \_ [OK] StoragePool1: RetireMissingPhysicalDisks: Auto
       \_ [OK] StoragePool1: Supports Deduplication: True
       \_ [OK] StoragePool1: TotalUsed: 0.5GB
       \_ [OK] StoragePool1: Usage: Other
    | 'storagepool1_totalused'=0.5GB;; 'storagepool1_capacity'=18.97GB;; 'storagepool1_freespace'=18.47GB;;
    0
.LINK
    https://github.com/Icinga/icinga-powershell-framework
    https://github.com/Icinga/icinga-powershell-plugins
#>
function Invoke-IcingaCheckStoragePool()
{
    param(
        [array]$IncludeStoragePool          = @(),
        [array]$ExcludeStoragePool          = @(),
        $FreeSpaceWarning                   = $null,
        $FreeSpaceCritical                  = $null,
        $TotalUsedWarning                   = $null,
        $TotalUsedCritical                  = $null,
        $IsReadOnlyCritical                 = $null,
        $CapacityWarning                    = $null,
        $CapacityCritical                   = $null,
        $ClearOnDeallocateCritical          = $null,
        $SupportsDeduplicationCritical      = $null,
        $IsPowerProtectedCritical           = $null,
        [ValidateSet('Healthy', 'Warning', 'Unhealthy', 'Unknown')]
        $HealthStatusWarning                = $null,
        [ValidateSet('Healthy', 'Warning', 'Unhealthy', 'Unknown')]
        $HealthStatusCritical               = $null,
        [ValidateSet('Auto', 'Always', 'Never')]
        $RetireMissingPhysicalDisksWarning  = $null,
        [ValidateSet('Auto', 'Always', 'Never')]
        $RetireMissingPhysicalDisksCritical = $null,
        [switch]$IncludePrimordial          = $FALSE,
        [switch]$NoPerfData                 = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                          = 0
    );

    # Get all StoragePool informations from the provider
    $GetStoragePools   = Get-IcingaStoragePoolInfo `
        -IncludeStoragePool $IncludeStoragePool `
        -ExcludeStoragePool $ExcludeStoragePool `
        -IncludePrimordial:$IncludePrimordial;
    $CheckPackage      = New-IcingaCheckPackage -Name 'Storage Pools Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    # We iterate through all StoragePools and build CheckPackage
    foreach ($Storage in $GetStoragePools.keys) {
        $StoragePool = $GetStoragePools[$Storage];
        $StorageCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('{0}', $Storage)) -OperatorAnd -Verbose $Verbosity;

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Health Status', $Storage)) `
                    -Value $StoragePool.HealthStatus `
                    -Translation $ProviderEnums.StorageHealthStatus `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.StorageHealthStatusName[[string]$HealthStatusWarning]
            ).CritIfMatch(
                $ProviderEnums.StorageHealthStatusName[[string]$HealthStatusCritical]
            )
        );

        $OperationalStatus = $StoragePool.OperationalStatus;
        $OperCount         = $OperationalStatus.Count;

        # Check whether Operational Status has more than one value
        if (($OperCount -eq 1) -And ($OperationalStatus.ContainsKey($ProviderEnums.StorageOperationalStatusName.OK) -or $OperationalStatus.ContainsKey($ProviderEnums.StorageOperationalStatusName.Other))) {
            $StorageCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Operational Status', $Storage)) `
                        -Value 'OK' `
                        -NoPerfData
                )
            );
        } else {
            $StorageCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Operational Status', $Storage)) `
                        -Value ([string]::Join(',', $OperationalStatus.Values)) `
                        -NoPerfData
                ).SetCritical()
            );
        }

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Capacity', $Storage)) `
                    -Value $StoragePool.Capacity `
                    -Unit 'GB'
            ).WarnOutOfRange(
                $CapacityWarning
            ).CritOutOfRange(
                $CapacityCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: FreeSpace', $Storage)) `
                    -Value $StoragePool.FreeSpace `
                    -Unit 'GB'
            ).WarnOutOfRange(
                $FreeSpaceWarning
            ).CritOutOfRange(
                $FreeSpaceCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: TotalUsed', $Storage)) `
                    -Value $StoragePool.TotalUsed `
                    -Unit 'GB'
            ).WarnOutOfRange(
                $TotalUsedWarning
            ).CritOutOfRange(
                $TotalUsedCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Clear OnDeallocate', $Storage)) `
                    -Value $StoragePool.ClearOnDeallocate `
                    -NoPerfData
            ).CritIfMatch(
                $ClearOnDeallocateCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Is ReadOnly', $Storage)) `
                    -Value $StoragePool.IsReadOnly `
                    -NoPerfData
            ).CritIfMatch(
                $IsReadOnlyCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Usage', $Storage)) `
                    -Value $StoragePool.Usage `
                    -Translation $ProviderEnums.StoragePoolUsage `
                    -NoPerfData
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Supports Deduplication', $Storage)) `
                    -Value $StoragePool.SupportsDeduplication `
                    -NoPerfData
            ).CritIfMatch(
                $SupportsDeduplicationCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Is PowerProtected', $Storage)) `
                    -Value $StoragePool.IsPowerProtected `
                    -NoPerfData
            ).CritIfMatch(
                $IsPowerProtectedCritical
            )
        );

        $StorageCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: RetireMissingPhysicalDisks', $Storage)) `
                    -Value $StoragePool.RetireMissingPhysicalDisks `
                    -Translation $ProviderEnums.RetireMissingPhysicalDisks `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.RetireMissingPhysicalDisksName[[string]$RetireMissingPhysicalDisksWarning]
            ).CritIfMatch(
                $ProviderEnums.RetireMissingPhysicalDisksName[[string]$RetireMissingPhysicalDisksCritical]
            )
        );

        $CheckPackage.AddCheck($StorageCheckPackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
