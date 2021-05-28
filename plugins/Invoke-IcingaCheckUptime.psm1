<#
.SYNOPSIS
   Checks how long a Windows system has been up for.
.DESCRIPTION
   InvokeIcingaCheckUptime returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' the system has been running for 10 days, WARNING is set to 15d, CRITICAL is set to 30d. In this case the check will return OK.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to check how long a Windows system has been up for.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### WMI Permissions

    * Root\Cimv2
.EXAMPLE
   PS> Invoke-IcingaCheckUptime -Warning 18d -Critical 20d
   [WARNING]: Check package "Windows Uptime: Days: 19 Hours: 13 Minutes: 48 Seconds: 29" is [WARNING]
   | 'Windows Uptime'=1691309,539176s;1555200;1728000
.EXAMPLE
   PS> Invoke-IcingaCheckUptime -Warning 25d:
   [WARNING] Check package "System Uptime: 22d 16h 42m 35s" - [WARNING] System Uptime
   \_ [WARNING] System Uptime: Value "1960955.28s" is lower than threshold "2160000s"
   | 'system_uptime'=1960955.28s;2160000:;
   1
.PARAMETER Warning
   Used to specify a Warning threshold. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y
.PARAMETER Critical
   Used to specify a Critical threshold. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y
.PARAMETER Verbosity
   Changes the behavior of the plugin output which check states are printed:
   0 (default): Only service checks/packages with state not OK will be printed
   1: Only services with not OK will be printed including OK checks of affected check packages including Package config
   2: Everything will be printed regardless of the check state
   3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckUptime()
{
    param(
        [string]$Warning    = $null,
        [string]$Critical   = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

    $WindowsData = Get-IcingaWindows;
    $Name        = ([string]::Format('System Uptime: {0}', (ConvertFrom-TimeSpan -Seconds $WindowsData.windows.metadata.uptime.value)));

    $CheckPackage = New-IcingaCheckPackage -Name $Name -OperatorAnd -Verbose $Verbosity;

    $IcingaCheck = New-IcingaCheck -Name 'System Uptime' -Value $WindowsData.windows.metadata.uptime.value -Unit 's';
    $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    $BootTime = New-IcingaCheck -Name 'Last Boot' -Value ([string]$WindowsData.windows.metadata.uptime.raw) -NoPerfData;

    $CheckPackage.AddCheck($IcingaCheck);
    $CheckPackage.AddCheck($BootTime);

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
