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
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://docs.microsoft.com/de-de/windows/win32/api/winioctl/ni-winioctl-ioctl_disk_get_disk_attributes
   https://docs.microsoft.com/de-de/windows/win32/api/winioctl/ns-winioctl-get_disk_attributes
#>

function Get-IcingaDiskPartitionAssignment()
{
    # Get Partition info and disk association
    $LogicalDiskToPartition = Get-IcingaWindowsInformation Win32_LogicalDiskToPartition;
    $PartitionInformation   = @{};

    foreach ($partition in $LogicalDiskToPartition) {
        [string]$DiskReference      = $partition.Antecedent.ToString();
        $DiskReference              = $DiskReference.SubString(
            $DiskReference.LastIndexOf('=') + 3,
            $DiskReference.Length - $DiskReference.LastIndexOf('=') - 5
        );
        [string]$PartitionReference = $partition.Dependent.ToString();
        $PartitionReference         = $PartitionReference.SubString(
            $PartitionReference.LastIndexOf('=') + 3,
            $PartitionReference.Length - $PartitionReference.LastIndexOf('=') - 5
        );

        $DiskId              = $DiskReference.Split(',')[0].Replace('Disk #', '');
        [string]$PartitionId = $DiskReference.Split(',')[1].Replace(' Partition #', '');

        if ($PartitionInformation.ContainsKey($DiskId) -eq $FALSE) {
            $PartitionInformation.Add(
                [string]$DiskId,
                @{
                    'DriveLetters' = @();
                    'Partitions'   = @{};
                }
            );
        }

        $PartitionInformation[$DiskId].DriveLetters += $PartitionReference;

        if ($PartitionInformation[$DiskId].Partitions.ContainsKey($PartitionId)) {
            continue;
        }

        $PartitionInformation[$DiskId].Partitions.Add(
            $PartitionId, $PartitionReference
        );
    }

    return $PartitionInformation;
}
