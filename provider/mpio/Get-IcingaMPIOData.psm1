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
    if (-not (Test-IcingaMPIOInstalled)) {
        return $null;
        # Test Data for debugging
        <#
        return [PSCustomObject]@{
            'DriveInfo'    = [PSCustomObject]@{
                'Name'        = 'MPIO Disk 0';
                'NumberPaths' = 8;
            };
            'InstanceName' = 'Test Instance';
            'NumberDrives' = 1;
            'Active'       = $true;
        }
        #>
    }

    # Check whether MPIO_DISK_INFO exists on the targeted system
    $TestClasses  = Test-IcingaWindowsInformation -ClassName 'MPIO_DISK_INFO' -NameSpace 'Root\WMI';
    # Check for error Ids with Binary operators
    $BitWiseCheck = Test-IcingaBinaryOperator -Value $TestClasses -Compare @($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoExceptionType.Values) -Namespace $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo;

    # We return a empty hashtable if for some reason no data from the WMI classes can be retrieved
    if ($BitWiseCheck) {
        if ($TestClasses -eq $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok) {
            $MPIOData = Get-IcingaWindowsInformation -ClassName MPIO_DISK_INFO -Namespace 'Root\WMI';

            return $MPIOData;
        }
    }

    return $null;
}
