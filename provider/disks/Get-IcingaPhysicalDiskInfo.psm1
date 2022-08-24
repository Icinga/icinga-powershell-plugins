<#
.SYNOPSIS
   Reads all available partition information and stores them inside a hashtable
   to assign drive leters properly to a disk and even to a a certain partition
.DESCRIPTION
   Reads all available partition information and stores them inside a hashtable
   to assign drive leters properly to a disk and even to a a certain partition
.FUNCTIONALITY
   Reads all available partition information and stores them inside a hashtable
   to assign drive leters properly to a disk and even to a a certain partition
.EXAMPLE
   PS>Get-IcingaDiskPartitionAssignment
.EXAMPLE
   PS>Get-IcingaDiskPartitionAssignment -DiskIds 0, 1
.PARAMETER DiskIds
   Allows to filter for certain disk ids. Siply provide the id itself like 0, 1
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Global:Get-IcingaPhysicalDiskInfo()
{
    param (
        [array]$DiskIds = @()
    );

    # Fetch all physical disks to work with
    $PhysicalDisks        = Get-IcingaWindowsInformation Win32_DiskDrive;

    # Fetch our disk info only for local disks and do not include network drives
    # Filter additional details for disks
    $MSFT_Disks           = Get-IcingaWindowsInformation MSFT_PhysicalDisk -Namespace 'root\Microsoft\Windows\Storage';
    # Load additional logical disk information
    $LogicalDisk          = Get-IcingaWindowsInformation Win32_LogicalDisk -Filter 'DriveType = 3';
    $PartitionInformation = Get-IcingaDiskPartitionAssignment;
    $PhysicalDiskData     = @{ };

    foreach ($disk in $MSFT_Disks) {
        [int]$MSFTDiskId = [int]$disk.DeviceId;
        if ($DiskIds.Count -ne 0) {
            if (-Not ($DiskIds -Contains $MSFTDiskId)) {
                continue;
            }
        }

        $DiskData = Get-IcingaDiskAttributes -DiskId $MSFTDiskId;

        [hashtable]$DiskInfo = @{ };

        foreach ($physical_disk in $PhysicalDisks) {
            [string]$DiskId = $physical_disk.DeviceID.ToString().Replace('\\.\PHYSICALDRIVE', '');

            if ($MSFTDiskId -ne [int]$DiskId) {
                continue;
            }

            $DiskInfo = @{
                'PartitionStyle'              = ''; # Set later on partition check
                'PartitionLayout'             = @{ }; # Set later on partition check
                'DriveReference'              = @{ };
                'IsBoot'                      = $FALSE; # Always false here because we set the boot option later based on our partition config
                'MaxBlockSize'                = 0; # 0 because we later count the block size based on the amount of partitions
                'ErrorCleared'                = $physical_disk.ErrorCleared;
                'FirmwareRevision'            = $physical_disk.FirmwareRevision;
                'Description'                 = $physical_disk.Description;
                'Caption'                     = $physical_disk.Caption;
                'IsSystem'                    = $physical_disk.IsSystem;
                'TotalHeads'                  = $physical_disk.TotalHeads;
                'MaxMediaSize'                = $physical_disk.MaxMediaSize;
                'ConfigManagerUserConfig'     = $physical_disk.ConfigManagerUserConfig;
                'Model'                       = $physical_disk.Model;
                'PowerManagementCapabilities' = $physical_disk.PowerManagementCapabilities;
                'TracksPerCylinder'           = $physical_disk.TracksPerCylinder;
                'IsHighlyAvailable'           = $physical_disk.IsHighlyAvailable;
                'DeviceID'                    = $physical_disk.DeviceID;
                'NeedsCleaning'               = $physical_disk.NeedsCleaning;
                'Index'                       = $physical_disk.Index;
                'MediaLoaded'                 = $physical_disk.MediaLoaded;
                'LastErrorCode'               = $physical_disk.LastErrorCode;
                'Size'                        = $physical_disk.Size;
                'MinBlockSize'                = $physical_disk.MinBlockSize;
                'IsScaleOut'                  = $physical_disk.IsScaleOut;
                'InterfaceType'               = $physical_disk.InterfaceType;
                'Capabilities'                = $physical_disk.Capabilities;
                'PNPDeviceID'                 = $physical_disk.PNPDeviceID;
                'Partitions'                  = $physical_disk.Partitions;
                'PowerManagementSupported'    = $physical_disk.PowerManagementSupported;
                'ErrorMethodology'            = $physical_disk.ErrorMethodology;
                'StatusInfo'                  = $physical_disk.StatusInfo;
                'NumberOfMediaSupported'      = $physical_disk.NumberOfMediaSupported;
                'InstallDate'                 = $physical_disk.InstallDate;
                'DefaultBlockSize'            = $physical_disk.DefaultBlockSize;
                'SystemCreationClassName'     = $physical_disk.SystemCreationClassName;
                'SCSITargetId'                = $physical_disk.SCSITargetId;
                'Availability'                = $physical_disk.Availability;
                'BytesPerSector'              = $physical_disk.BytesPerSector;
                'Status'                      = $physical_disk.Status;
                'SCSILogicalUnit'             = $physical_disk.SCSILogicalUnit;
                'CapabilityDescriptions'      = $physical_disk.CapabilityDescriptions;
                'SCSIPort'                    = $physical_disk.SCSIPort;
                'TotalTracks'                 = $physical_disk.TotalTracks;
                'CreationClassName'           = $physical_disk.CreationClassName;
                'TotalCylinders'              = $physical_disk.TotalCylinders;
                'SCSIBus'                     = $physical_disk.SCSIBus;
                'Signature'                   = $physical_disk.Signature;
                'CompressionMethod'           = $physical_disk.CompressionMethod;
                'TotalSectors'                = $physical_disk.TotalSectors;
                'SystemName'                  = $physical_disk.SystemName;
                'ErrorDescription'            = $physical_disk.ErrorDescription;
                'Manufacturer'                = $physical_disk.Manufacturer;
                'Name'                        = $physical_disk.Name;
                'IsClustered'                 = $physical_disk.IsClustered;
                'ConfigManagerErrorCode'      = $physical_disk.ConfigManagerErrorCode;
                'SectorsPerTrack'             = $physical_disk.SectorsPerTrack;
            };

            $Partitions = Get-CimAssociatedInstance -InputObject $physical_disk -ResultClass Win32_DiskPartition;

            $MaxBlocks = 0;

            foreach ($partition in $Partitions) {
                $DriveLetter            = $null;
                [string]$PartitionIndex = $partition.Index;

                if ($PartitionInformation.ContainsKey($DiskId) -And $PartitionInformation[$DiskId].Partitions.ContainsKey($PartitionIndex)) {
                    $DriveLetter = $PartitionInformation[$DiskId].Partitions[$PartitionIndex];

                    $DiskInfo.DriveReference.Add(
                        $DriveLetter, $partition.Index
                    );
                }

                $DiskInfo.PartitionLayout.Add(
                    $PartitionIndex,
                    @{
                        'NumberOfBlocks'   = $Partition.NumberOfBlocks;
                        'BootPartition'    = $Partition.BootPartition;
                        'PrimaryPartition' = $Partition.PrimaryPartition;
                        'Size'             = $Partition.Size;
                        'Index'            = $Partition.Index;
                        'DiskIndex'        = $Partition.DiskIndex;
                        'DriveLetter'      = $DriveLetter;
                        'Bootable'         = $Partition.Bootable;
                        'Name'             = [string]::Format('Disk #{0}, Partition #{1}', $MSFTDiskId, $PartitionIndex);
                        'StartingOffset'   = $Partition.StartingOffset;
                        'Status'           = $Partition.Status;
                        'StatusInfo'       = $Partition.StatusInfo;
                        'Type'             = $Partition.Type;
                    }
                )

                foreach ($logical_disk in $LogicalDisk) {
                    if ($logical_disk.DeviceId -eq $DriveLetter) {
                        if ($null -ne $LogicalDisk) {
                            $UsedSpace = 0;

                            if ([string]::IsNullOrEmpty($DiskInfo.PartitionLayout[$PartitionIndex].Size) -eq $FALSE -And [string]::IsNullOrEmpty($logical_disk.FreeSpace) -eq $FALSE) {
                                $UsedSpace = $DiskInfo.PartitionLayout[$PartitionIndex].Size - $logical_disk.FreeSpace;
                            }

                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'FreeSpace', $logical_disk.FreeSpace
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'UsedSpace', $UsedSpace
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'VolumeName', $logical_disk.VolumeName
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'FileSystem', $logical_disk.FileSystem
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'VolumeSerialNumber', $logical_disk.VolumeSerialNumber
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'Description', $logical_disk.Description
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'Access', $logical_disk.Access
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'SupportsFileBasedCompression', $logical_disk.SupportsFileBasedCompression
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'SupportsDiskQuotas', $logical_disk.SupportsDiskQuotas
                            );
                            $DiskInfo.PartitionLayout[$PartitionIndex].Add(
                                'Compressed', $logical_disk.Compressed
                            );
                        }

                        break;
                    }
                }

                $MaxBlocks += $Partition.NumberOfBlocks;

                if ($Partition.Bootable) {
                    $DiskInfo.IsBoot = $Partition.Bootable;
                }
                $DiskInfo.MaxBlockSize = $MaxBlocks;

                if ($Partition.Type -Like '*GPT*') {
                    $DiskInfo.PartitionStyle = 'GPT';
                } else {
                    $DiskInfo.PartitionStyle = 'MBR';
                }
            }

            break;
        }

        $DiskInfo.Add('IsOffline', $DiskData.Offline);
        $DiskInfo.Add('IsReadOnly', $DiskData.ReadOnly);
        $DiskInfo.Add('OperationalStatus', @{ }); # Set later on MSFT
        $DiskInfo.Add(
            'BusType',
            @{
                'value' = $disk.BusType;
                'name'  = $ProviderEnums.DiskBusType[[int]$disk.BusType];
            }
        )
        $DiskInfo.Add('HealthStatus', $disk.HealthStatus);
        if ($null -ne $disk.OperationalStatus) {
            $OperationalStatus = @{ };

            foreach ($entry in $disk.OperationalStatus) {
                if (Test-Numeric $entry) {
                    Add-IcingaHashtableItem -Hashtable $OperationalStatus -Key ([int]$entry) -Value ($ProviderEnums.DiskOperationalStatus[[int]$entry]) | Out-Null;
                } else {
                    if ($ProviderEnums.DiskOperationalStatus.Values -Contains $entry) {
                        foreach ($opStatus in $ProviderEnums.DiskOperationalStatus.Keys) {
                            $opStatusValue = $ProviderEnums.DiskOperationalStatus[$opStatus];
                            if ($opStatusValue.ToLower() -eq ([string]$entry).ToLower()) {
                                Add-IcingaHashtableItem -Hashtable $OperationalStatus -Key ([int]$opStatus) -Value $entry | Out-Null;
                                break;
                            }
                        }
                    }
                }
            }

            $DiskInfo.OperationalStatus = $OperationalStatus;
        } else {
            $DiskInfo.OperationalStatus = @{ 0 = 'Unknown'; };
        }
        $DiskInfo.Add(
            'SpindleSpeed', $disk.SpindleSpeed
        );
        $DiskInfo.Add(
            'PhysicalLocation', $disk.PhysicalLocation
        );
        $DiskInfo.Add(
            'AdapterSerialNumber', $disk.AdapterSerialNumber
        );
        $DiskInfo.Add(
            'PhysicalSectorSize', $disk.PhysicalSectorSize
        );
        $DiskInfo.Add(
            'CanPool', $disk.CanPool
        );
        $DiskInfo.Add(
            'CannotPoolReason', $disk.CannotPoolReason
        );
        $DiskInfo.Add(
            'IsPartial', $disk.IsPartial
        );
        $DiskInfo.Add(
            'UniqueId', $disk.UniqueId
        );
        $DiskInfo.Add(
            'FriendlyName', $disk.FriendlyName
        );
        $DiskInfo.Add(
            'SerialNumber', [string]$disk.SerialNumber
        );
        $DiskInfo.Add(
            'MediaType',
            @{
                'Value' = $disk.MediaType
                'Name'  = ($ProviderEnums.DiskMediaType[[int]$disk.MediaType])
            }
        );

        $PhysicalDiskData.Add($MSFTDiskId, $DiskInfo);
    }

    return $PhysicalDiskData;
}
