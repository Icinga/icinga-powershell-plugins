<#
.SYNOPSIS
    Monitors the number of paths for each MPIO driver on your system.
.DESCRIPTION
    Monitors the number of paths for each MPIO driver on your system.
.PARAMETER Warning
    This threshold is deprecated, please use NumberOfPathWarning instead.
.PARAMETER Critical
    This threshold is deprecated, please use NumberOfPathCritical instead.
.PARAMETER NumberOfPathWarning
    An array of specific Warning thresholds for the number of paths per MPIO device.
    Use the format "VolumeName=Threshold" e.g. "LUN001*=8", also supports Icinga thresholds like "LUN002*=8:"
.PARAMETER NumberOfPathCritical
    An array of specific Critical thresholds for the number of paths per MPIO device.
    Use the format "VolumeName=Threshold" e.g. "LUN001*=6", also supports Icinga thresholds like "LUN001*=6:"
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.ROLE
    ### WMI Permissions

    * Root\WMI
.EXAMPLE
    PS> Invoke-IcingaCheckMPIO -NumberOfPathWarning 'LUN002=9:','LUN003=4';

    [WARNING] Multipath-IO Package: 1 Warning [WARNING] ROOT\MPIO\0000_0 Package
    \_ [WARNING] ROOT\MPIO\0000_0 Package
        \_ [WARNING] ROOT\MPIO\0000_0 Drivers Package
            \_ [WARNING] LUN002 Number Paths: Value 8c is lower than threshold 9
            \_ [WARNING] LUN003 Number Paths: Value 8c is greater than threshold 4
    | lun002::ifw_mpio::numberofpaths=8c;9:;;; lun003::ifw_mpio::numberofpaths=8c;4;;; nolabel::ifw_mpio::numberofpaths=8c;;;; windows::ifw_mpio::numberofpaths=8c;;;; windowsos::ifw_mpio::numberofpaths=8c;;;; rootmpio0000_0::ifw_mpio::numberofdrives=6c;;;;
#>
function Invoke-IcingaCheckMPIO()
{
    param (
        $Warning                     = $null,
        $Critical                    = $null,
        [array]$NumberOfPathWarning  = @(),
        [array]$NumberOfPathCritical = @(),
        [switch]$NoPerfData          = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                   = 0
    );

    $CheckPackage            = New-IcingaCheckPackage -Name 'Multipath-IO Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $MpioData                = Get-IcingaMPIOData;
    [hashtable]$MpioPackages = @{ };

    if ($MpioData -is [array]) {
        foreach ($mpio in $MpioData) {
            [string]$MpioInstance = $mpio.InstanceName;

            # Create a new MPIO Package if it does not exist yet for each instance
            if (-Not $MpioPackages.ContainsKey($MpioInstance)) {
                $MpioPackages.Add(
                    $MpioInstance,
                    @{
                        'MpioPackage'  = New-IcingaCheckPackage -Name ([string]::Format('{0} Package', $MpioInstance)) ` -OperatorAnd -Verbose $Verbosity;
                        'DrivePackage' = New-IcingaCheckPackage -Name ([string]::Format('{0} Drivers Package', $MpioInstance)) ` -OperatorAnd -Verbose $Verbosity;
                    }
                );

                # Add instance specific checks (rquired only once, because they are identical for all drives of an instance)
                $MpioPackages[$MpioInstance]['MpioPackage'].AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0} Active', $MpioInstance)) `
                            -Value $mpio.Active `
                            -NoPerfData
                    )
                );

                $MpioPackages[$MpioInstance]['MpioPackage'].AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0} NumberDrives', $MpioInstance)) `
                            -Value $mpio.NumberDrives `
                            -Unit 'c' `
                            -MetricIndex $MpioInstance `
                            -MetricName 'numberofdrives'
                    )
                );
            }

            $MpioWarningThreshold  = $null;
            $MpioCriticalThreshold = $null;

            foreach ($entry in $NumberOfPathWarning) {
                $parts = $entry.Split('=', 2);
                if ($mpio.Volume -like $parts[0]) {
                    $MpioWarningThreshold = $parts[1];
                    break;
                }
            }

            foreach ($entry in $NumberOfPathCritical) {
                $parts = $entry.Split('=', 2);
                if ($mpio.Volume -like $parts[0]) {
                    $MpioCriticalThreshold = $parts[1];
                    break;
                }
            }

            # Add all drive specific checks from the MPIO instance
            $MpioPackages[$MpioInstance]['DrivePackage'].AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} Number Paths', $mpio.Volume)) `
                        -Value $mpio.NumberOfPaths `
                        -Unit 'c' `
                        -MetricIndex $mpio.Volume `
                        -MetricName 'numberofpaths'
                ).WarnOutOfRange(
                    $MpioWarningThreshold
                ).CritOutOfRange(
                    $MpioCriticalThreshold
                )
            );
        }

        foreach ($check in $MpioPackages.Keys) {
            $MpioCheckPackage = $MpioPackages[$check]['MpioPackage'];
            $DriverPackage    = $MpioPackages[$check]['DrivePackage'];

            if ($MpioCheckPackage.HasChecks()) {
                # Add Driver Package to MPIO Package
                $MpioCheckPackage.AddCheck($DriverPackage);
            }

            $CheckPackage.AddCheck($MpioCheckPackage);
        }
    } else {
        if ($MpioData -is [hashtable] -and $MpioData.ContainsKey('Exception')) {
            $Check = New-IcingaCheck -Name 'MultiPath-IO Check Status' -NoPerfData;
            $Check.SetCritical($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoText[[int]$MpioData.Exception], $TRUE) | Out-Null;
            # Enforce the checks to critical in case we get an exception
            $CheckPackage.AddCheck($Check);
        }
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
