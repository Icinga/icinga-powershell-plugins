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

    $MpioDatas   = Get-IcingaWindowsInformation -ClassName MPIO_DISK_INFO -Namespace 'Root\WMI';
    $MpioDrivers = @{ };

    foreach ($instance in $MpioDatas) {
        if ($MpioDrivers.ContainsKey($instance.InstanceName)) {
            continue;
        }

        $MpioDrivers.Add(
            $instance.InstanceName, @{
                'Active'       = $instance.Active;
                'InstanceName' = $instance.InstanceName;
                'NumberDrives' = $instance.NumberDrives;
                'DriveInfo'    = @{ }
            }
        );

        foreach ($driver in $instance.DriveInfo) {
            if ($MpioDrivers[$instance.InstanceName].DriveInfo.ContainsKey($driver.Name)) {
                continue;
            }

            $MpioDrivers[$instance.InstanceName].DriveInfo.Add(
                $driver.Name, @{
                    'DsmName'        = $driver.DsnName;
                    'Name'           = $driver.Name;
                    'NumberPaths'    = $driver.NumberPaths;
                    'SerialNumber'   = $driver.SerialNumber;
                    'PSComputerName' = $driver.PSComputerName
                }
            );
        }
    }

    return $MpioDrivers;
}
