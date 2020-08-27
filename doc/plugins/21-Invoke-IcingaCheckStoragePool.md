
# Invoke-IcingaCheckStoragePool

## Description

Checks availability, utilization and state of a StoragePool.

Invoke-IcingaCheckStoragePool Checks the availability, utilization and state of a StoragePool. If no
StoragePool can be found on your system then an UNKNOWN check package is thrown with the corresponding error message.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root/Microsoft/Windows/Storage

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeStoragePool | Array | false | @() | With this parameter you can filter out which StoragePools you want to check, provided you have several StoragePools on your system. |
| ExcludeStoragePool | Array | false | @() | With this parameter you can filter out which StoragePools you do not want to check, provided you have several StoragePools on your system. |
| FreeSpaceWarning | Object | false |  | Used to specify a Warning threshold for the StoragePool FreeSpaces in GB. This value is a decreasing metric which will require you to add a ':' behind the threshold, like '20GB:' to check if free space is lower compared to your threshold |
| FreeSpaceCritical | Object | false |  | Used to specify a Critical threshold for the StoragePool FreeSpaces in GB. This value is a decreasing metric which will require you to add a ':' behind the threshold, like '20GB:' to check if free space is lower compared to your threshold |
| TotalUsedWarning | Object | false |  | Used to specify TotalUsed Warning threshold in GB. |
| TotalUsedCritical | Object | false |  | Used to specify TotalUsed Critical threshold in GB. |
| IsReadOnlyCritical | Object | false |  | Used to specify a Critical threshold for the StoragePool IsReadOnly Attr. |
| CapacityWarning | Object | false |  | Used to specify a Warning threshold for the StoragePool Capacity. |
| CapacityCritical | Object | false |  | Used to specify a Critical threshold for the StoragePool Capacity. |
| ClearOnDeallocateCritical | Object | false |  | Critical threshold for StoragePool ClearOnDeallocate is, if physical disks should be zeroed (cleared of all data) when unmapped or removed from the storage pool. |
| SupportsDeduplicationCritical | Object | false |  | Critical threshold StoragePool SupportsDeduplication is, whether the storage pool supports data duplication or not. |
| IsPowerProtectedCritical | Object | false |  | Critical threshold for StoragePool IsPowerProtected is, whether the disks in this pool are able to tolerate power loss without data loss. For example, they automatically flush volatile buffers to non-volatile media after external power is disconnected. |
| HealthStatusWarning | Object | false |  | Warning threshold for Health of StoragePool is whether or not the storage pool can maintain the required redundancy levels. |
| HealthStatusCritical | Object | false |  | Critical threshold for Health of StoragePool is whether or not the storage pool can maintain the required redundancy levels. |
| RetireMissingPhysicalDisksWarning | Object | false |  | Warning threshold RetireMissingPhysicalDisks specifies whether the storage subsystem will automatically retire physical disks that are missing from this storage pool and replace them with hot spares or other physical disks that are available in the storage pool. |
| RetireMissingPhysicalDisksCritical | Object | false |  | Critical threshold RetireMissingPhysicalDisks specifies whether the storage subsystem will automatically retire physical disks that are missing from this storage pool and replace them with hot spares or other physical disks that are available in the storage pool. |
| IncludePrimordial | SwitchParameter | false | False | A primordial pool, also known as the 'available storage' pool is where storage capacity is drawn and returned in the creation and deletion of concrete storage pools. Primordial pools cannot be created or deleted. You can set this to true if you also want to check Primordial StoragePools. Default to false. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin. Default to FALSE. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckStoragePool -Verbosity 2 }
```

### Example Output 1

```powershell
[OK] Check package "Storage Pools Package" (Match All)\_ [OK] Check package "StoragePool1" (Match All) \_ [OK] StoragePool1: Capacity: 18.97GB \_ [OK] StoragePool1: Clear OnDeallocate: False \_ [OK] StoragePool1: FreeSpace: 18.47GB \_ [OK] StoragePool1: Health Status: Healthy \_ [OK] StoragePool1: Is PowerProtected: False \_ [OK] StoragePool1: Is ReadOnly: False \_ [OK] StoragePool1: Operational Status: OK \_ [OK] StoragePool1: RetireMissingPhysicalDisks: Auto \_ [OK] StoragePool1: Supports Deduplication: True \_ [OK] StoragePool1: TotalUsed: 0.5GB \_ [OK] StoragePool1: Usage: Other| 'storagepool1_totalused'=0.5GB;; 'storagepool1_capacity'=18.97GB;; 'storagepool1_freespace'=18.47GB;;0
```
