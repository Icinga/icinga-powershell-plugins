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
   PS> Invoke-IcingaCheckUptime -Warning '10m'
   [WARNING] System Uptime: 0d 1h 25m 50s [WARNING] System Uptime
   \_ [WARNING] System Uptime: Value 1.43h is greater than threshold 10m
   | windows::ifw_uptime::uptime=5149.979s;600;;;
.EXAMPLE
   PS> Invoke-IcingaCheckUptime -Warning '2h:'
   [WARNING] System Uptime: 0d 1h 28m 40s [WARNING] System Uptime
   \_ [WARNING] System Uptime: Value 1.48h is lower than threshold 2h
   | windows::ifw_uptime::uptime=5319.563s;7200:;;;
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
    param (
        [string]$Warning    = $null,
        [string]$Critical   = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

    $WindowsData  = Get-IcingaWindows;
    $TimeSpan     = New-TimeSpan -Seconds $WindowsData.windows.metadata.uptime.value;
    $UptimeHR     = [string]::Format('{0}d {1}h {2}m {3}s', $TimeSpan.Days, $TimeSpan.Hours, $TimeSpan.Minutes, $TimeSpan.Seconds);
    $Name         = [string]::Format('System Uptime: {0}', $UptimeHR);

    $CheckPackage = New-IcingaCheckPackage -Name $Name -OperatorAnd -Verbose $Verbosity;

    $IcingaCheck  = New-IcingaCheck -Name 'System Uptime' -Value $WindowsData.windows.metadata.uptime.value -Unit 's' -MetricIndex 'windows' -MetricName 'uptime';
    $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    $BootTime = New-IcingaCheck -Name 'Last Boot' -Value ([string]$WindowsData.windows.metadata.uptime.raw) -NoPerfData;

    $CheckPackage.AddCheck($IcingaCheck);
    $CheckPackage.AddCheck($BootTime);

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
