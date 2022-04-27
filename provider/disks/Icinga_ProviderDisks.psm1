function Get-IcingaDiskInformation()
{
    <# Fetches the information for other more specific Get-IcingaDisk-functions
    e.g. Get-IcingaDiskModel; Get-IcingaDiskManufacturer.
    Can be used to fetch information regarding a value of your choice. #>
    param(
        # The value to fetch from Win32_DiskDrive
        [string]$Parameter
    );
    $DiskInformation = Get-IcingaWindowsInformation Win32_DiskDrive;
    [hashtable]$DiskData = @{};

    foreach ($disk in $DiskInformation) {
        $DiskId = $disk.DeviceID.trimstart(".\PHYSICALDRVE");
        if ([string]::IsNullOrEmpty($Parameter) -eq $FALSE) {
            $DiskData.Add($DiskId, $disk.$Parameter);
        } else {
            $Properties = Get-IcingaPSObjectProperties -Object $disk -Exclude 'CimInstanceProperties', 'CimClass', 'CimSystemProperties';
            $DiskData.Add(
                $DiskId,
                @{}
            );

            foreach ($property in $Properties.Keys) {
                $DiskData[$DiskId].Add(
                    $property,
                    $Properties[$property]
                );
            }
        }
    }

    return $DiskData;
}
function Get-IcingaDiskPartitions()
{
    param(
        $Disk
    );
    <# Fetches all the most important informations regarding partitions
    e.g. physical disk; partition, size
    , also collects partition information for Get-IcingaDisks #>
    $LogicalDiskInfo = Get-IcingaWindowsInformation Win32_LogicalDiskToPartition -ForceWMI;
    [hashtable]$PartitionDiskByDriveLetter = @{};

    foreach ($item in $LogicalDiskInfo) {
        [string]$driveLetter = $item.Dependent.SubString(
            $item.Dependent.LastIndexOf('=') + 1,
            $item.Dependent.Length - $item.Dependent.LastIndexOf('=') - 1
        );
        $driveLetter = $driveLetter.Replace('"', '').trim(':');

        [string]$diskPartition = $item.Antecedent.SubString(
            $item.Antecedent.LastIndexOf('=') + 1,
            $item.Antecedent.Length - $item.Antecedent.LastIndexOf('=') - 1
        )
        $diskPartition = $diskPartition.Replace('"', '');
        $diskDisk,$diskPartition = $diskPartition.split(',');

        $diskPartition = $diskPartition.trim("Partition #");
        $diskDisk = $diskDisk.trim("Disk #");

        If ([string]::IsNullOrEmpty($Disk) -eq $FALSE) {
            If ([int]$Disk -ne [int]$diskDisk) {
                continue;
            } 
        }

        $DiskArray   = New-IcingaPerformanceCounterStructure -CounterCategory 'LogicalDisk' -PerformanceCounterHash (New-IcingaPerformanceCounterArray @('\LogicalDisk(*)\% free space'));

        $diskPartitionSize = (Get-IcingaWindowsInformation Win32_LogicalDisk -Filter "DeviceID='${DriveLetter}:'" -ForceWMI);

        $PartitionDiskByDriveLetter.Add(
            $driveLetter,
            @{
                'Disk'       = $diskDisk;
                'Partition'  = $diskPartition;
                'Size'       = $diskPartitionSize.Size;
                'Free Space' = $DiskArray.Item([string]::Format('{0}:', $driveLetter))."% free space".value;
            }
        );
    }

    return $PartitionDiskByDriveLetter;
}

function Join-IcingaPhysicalDiskDataPerfCounter()
{
    param (
        [array]$DiskCounter,
        [array]$IncludeDisk      = @(),
        [array]$ExcludeDisk      = @(),
        [array]$IncludePartition = @(),
        [array]$ExcludePartition = @()
    );

    [hashtable]$PhysicalDiskData = @{};
    $GetDisk                     = Get-IcingaPhysicalDiskInfo;
    $Counters                    = New-IcingaPerformanceCounterArray $DiskCounter; 
    $SortedDisks                 = New-IcingaPerformanceCounterStructure -CounterCategory 'PhysicalDisk' -PerformanceCounterHash $Counters;

    foreach ($disk in $SortedDisks.Keys) {
        $CounterObjects = $SortedDisks[$disk];
        $DiskId         = $disk.Split(' ')[0];
        $DriveLetter    = $disk.Split(' ')[1];
        $DiskData       = $null;

        if ($IncludeDisk.Count -ne 0 -Or $IncludePartition.Count -ne 0) {
            if (($IncludeDisk -Contains $DiskId) -eq $FALSE -And ($IncludePartition -Contains $DriveLetter) -eq $FALSE) {
                continue;
            }
        }

        if ($ExcludeDisk.Count -ne 0 -Or $ExcludePartition.Count -ne 0) {
            if (($ExcludeDisk -Contains $DiskId) -Or ($ExcludePartition -Contains $DriveLetter)) {
                continue;
            }
        }

        if ($GetDisk.ContainsKey($DiskId)) {
            $DiskData = $GetDisk[$DiskId];
        }

        $PhysicalDiskData.Add(
            $DiskId,
            @{
                'PerfCounter' = $CounterObjects;
                'Data'        = $DiskData;
            }
        );
    }

    return $PhysicalDiskData;
}

function Get-IcingaDiskCapabilities 
{
    $DiskInformation = Get-IcingaWindowsInformation Win32_DiskDrive;
    [hashtable]$DiskCapabilities = @{};

    foreach ($capabilities in $DiskInformation.Capabilities) {
        $DiskCapabilities.Add([int]$capabilities, $ProviderEnums.DiskCapabilities.([int]$capabilities));
    }
        return @{'value' = $DiskCapabilities; 'name' = 'Capabilities'};

}
function Get-IcingaDiskSize
{
    $DiskSize = Get-IcingaDiskInformation -Parameter Size;

    return @{'value' = $DiskSize; 'name' = 'Size'};
}

function Get-IcingaDiskCaption
{
    $DiskCaption = Get-IcingaDiskInformation -Parameter Caption;

    return @{'value' = $DiskCaption; 'name' = 'Caption'};
}

function Get-IcingaDiskModel
{
    $DiskModel = Get-IcingaDiskInformation -Parameter Model;
    return @{'value' = $DiskModel; 'name' = 'Model'};
}

function Get-IcingaDiskManufacturer
{
    $DiskManufacturer = Get-IcingaDiskInformation -Parameter Manufacturer;
    return @{'value' = $DiskManufacturer; 'name' = 'Manufacturer'};
}

function Get-IcingaDiskTotalCylinders
{
    $DiskTotalCylinders = Get-IcingaDiskInformation -Parameter TotalCylinders;
    return @{'value' = $DiskTotalCylinders; 'name' = 'TotalCylinders'};
}

function Get-IcingaDiskTotalSectors
{
    $DiskTotalSectors = Get-IcingaDiskInformation -Parameter TotalSectors;
    return @{'value' = $DiskTotalSectors; 'name' = 'TotalSectors'};
}

function Get-IcingaDisks {
    <# Collects all the most important Disk-Informations,
    e.g. size, model, sectors, cylinders
    Is dependent on Get-IcingaDiskPartitions#>
    $DiskInformation = Get-IcingaWindowsInformation Win32_DiskDrive;
    [hashtable]$DiskData = @{};

    foreach ($disk in $DiskInformation) {
        $diskID = $disk.DeviceID.trimstart(".\PHYSICALDRVE");
        $DiskData.Add(
            $diskID, @{
                'metadata' = @{
                    'Size' = $disk.Size;
                    'Model' = $disk.Model;
                    'Name' = $disk.Name.trim('.\');
                    'Manufacturer' = $disk.Manufacturer;
                    'Cylinder' = $disk.TotalCylinders;
                    'Sectors' = $disk.TotalSectors
                };
                'partitions' = (Get-IcingaDiskPartitions -Disk $diskID);
            }
        );    
    }

    return $DiskData;
}
