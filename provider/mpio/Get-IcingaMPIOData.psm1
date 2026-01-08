<#
.SYNOPSIS
    Gets the basic information of the MPIO Device if the Multipath-IO windows feature is Installed on your system.
.DESCRIPTION
    Gets the basic information of the MPIO Device if the Multipath-IO windows feature is Installed on your system.
.OUTPUTS
    System.Collections.Hashtable
#>

function Get-IcingaMPIOData()
{
    if (-Not (Test-IcingaMPIOInstalled)) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'MPIO not installed' -InputString 'The Multipath-IO feature is not installed on this system.' -Force;
    }

    # Check whether MPIO_DISK_INFO exists on the targeted system
    $TestClasses  = Test-IcingaWindowsInformation -ClassName 'MPIO_DISK_INFO' -NameSpace 'Root\WMI';
    # Check for error Ids with Binary operators
    $BitWiseCheck = Test-IcingaBinaryOperator -Value $TestClasses -Compare @($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoExceptionType.Values) -Namespace $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo;
    # Get the lasth throw exception id
    $ExceptionId  = Get-IcingaLastExceptionId;

    # We return a empty hashtable if for some reason no data from the WMI classes can be retrieved
    if ($BitWiseCheck) {
        if ($TestClasses -ne $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok) {
            return @{'Exception' = $TestClasses; };
        }
    }

    # Throw an exception when the exception ID is not OK, NotSpecified and PermissionError
    if ($TestClasses -ne $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok) {
        Exit-IcingaThrowException `
            -CustomMessage ($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoExceptionType[[int]$TestClasses]) `
            -InputString ($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoText[[int]$TestClasses]) `
            -ExceptionType Custom `
            -Force;
    }

    $VolumeData    = Get-Volume;
    $PartitionData = Get-Partition;
    $MpioData      = Get-IcingaWindowsInformation -ClassName MPIO_DISK_INFO -Namespace 'Root\WMI';
    $VolumeObject  = @();

    foreach ($vol in $VolumeData) {
        [string]$VolumeName = $vol.FileSystemLabel;

        if ([string]::IsNullOrEmpty($VolumeName)) {
            $VolumeName = 'NoLabel';
        }

        $VolumeObject += [PSCustomObject]@{
            'Volume'        = $VolumeName;
            'DriveLetter'   = $vol.DriveLetter;
            'FileSystem'    = $vol.FileSystem;
            'Health'        = $vol.HealthStatus;
            'SizeRemaining' = $vol.SizeRemaining;
            'InstanceName'  = '';
            'DiskNumber'    = -1;
            'Partition'     = -1;
            'Size'          = 0;
            'NumberOfPaths' = 0;
            'NumberDrives'  = 0;
            'Active'        = 0;
            'Type'          = '';
            'DriveType'     = $vol.DriveType;
        };

        foreach ($partition in $PartitionData) {
            if ($partition.AccessPaths -contains $vol.Path) {
                $VolumeObject[-1].DiskNumber = $partition.DiskNumber;
                $VolumeObject[-1].Partition  = $partition.PartitionNumber;
                $VolumeObject[-1].Size       = $partition.Size;
                $VolumeObject[-1].Type       = $partition.Type;
            }
        }
    }

    foreach ($obj in $VolumeObject) {
        $diskId = $obj.DiskNumber;
        foreach ($MpioInstance in $MpioData) {
            foreach ($drive in $MpioInstance.DriveInfo) {
                if ($drive.Name.replace('MPIO Disk', '') -eq $diskid) {
                    $obj.InstanceName  = $MpioInstance.InstanceName;
                    $obj.NumberDrives  = $MpioInstance.NumberDrives;
                    $obj.Active        = $MpioInstance.Active;
                    $obj.NumberOfPaths = $drive.NumberPaths;
                    break;
                }
            }
        }
    }

    return $VolumeObject;
}
