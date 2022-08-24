<#
.SYNOPSIS
    Monitors the number of paths for each MPIO driver on your system.
.DESCRIPTION
    Monitors the number of paths for each MPIO driver on your system.
.PARAMETER Warning
    Used to specify a Warning threshold for the number of path defined.
    Use for example 8: for alerting for less than 8 MPIO paths available
.PARAMETER Critical
    Used to specify a Critical threshold for the number of path defined.
    Use for example 6: for alerting for less than 6 MPIO paths available
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
    PS> icinga { Invoke-IcingaCheckMPIO -Verbosity 3 }
    [OK] Check package "Multipath-IO Package" (Match All)
    \_ [OK] Check package "HostName Package" (Match All)
       \_ [OK] HostName Active: True
       \_ [OK] Check package "HostName Drivers Package" (Match All)
          \_ [OK] MPIO DISK0 Number Paths: 8c
          \_ [OK] MPIO DISK1 Number Paths: 8c
          \_ [OK] MPIO DISK2 Number Paths: 8c
          \_ [OK] MPIO DISK3 Number Paths: 8c
          \_ [OK] MPIO DISK4 Number Paths: 8c
       \_ [OK] HostName NumberDrives: 5c
    | 'hostname_numberdrives'=5c;; 'mpio_disk0_number_paths'=8c;; 'mpio_disk3_number_paths'=8c;; 'mpio_disk4_number_paths'=8c;; 'mpio_disk2_number_paths'=8c;; 'mpio_disk1_number_paths'=8c;;
    0
#>

function Invoke-IcingaCheckMPIO()
{
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity          = 0
    );

    $CheckPackage = New-IcingaCheckPackage -Name 'Multipath-IO Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $MpioDatas    = Get-IcingaMPIOData;

    if ($MpioDatas.ContainsKey('Exception') -eq $FALSE) {
        foreach ($name in $MpioDatas.Keys) {
            $instance         = $MpioDatas[$name];
            $MpioCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('{0} Package', $name)) ` -OperatorAnd -Verbose $Verbosity;
            $DriverPackage    = New-IcingaCheckPackage -Name ([string]::Format('{0} Drivers Package', $name)) ` -OperatorAnd -Verbose $Verbosity;

            $MpioCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} Active', $name)) `
                        -Value $instance.Active `
                        -NoPerfData
                )
            );

            $MpioCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} NumberDrivers', $name)) `
                        -Value $instance.NumberDrives `
                        -Unit 'c' `
                        -MetricIndex $name `
                        -MetricName 'numberofdrivers'
                )
            );

            foreach ($driverName in $instance.DriveInfo.Keys) {
                $driver = $instance.DriveInfo[$driverName];
                $DriverPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0} Number Paths', $driverName)) `
                            -Value $driver.NumberPaths `
                            -Unit 'c' `
                            -MetricIndex $driverName `
                            -MetricName 'numberofpaths'
                    ).WarnOutOfRange(
                        $Warning
                    ).CritOutOfRange(
                        $Critical
                    )
                );
            }

            if ($DriverPackage.HasChecks()) {
                $MpioCheckPackage.AddCheck($DriverPackage);
            }

            $CheckPackage.AddCheck($MpioCheckPackage);
        }
    } else {
        $Check = New-IcingaCheck -Name 'MultiPath-IO Check Status' -NoPerfData;
        $Check.SetCritical($TestIcingaWindowsInfoEnums.TestIcingaWindowsInfoText[[int]$MpioDatas.Exception], $TRUE) | Out-Null;
        # Enforce the checks to critical in case we get an exception
        $CheckPackage.AddCheck($Check);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
