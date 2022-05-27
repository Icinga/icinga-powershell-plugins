<#
.SYNOPSIS
    Checks cpu usage of cores.
.DESCRIPTION
    Invoke-IcingaCheckCPU returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g A system has 4 cores, each running at 60% usage, WARNING is set to 50%, CRITICAL is set to 75%. In this case the check will return WARNING.
    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check on the current cpu usage of a specified core.
    Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### Performance Counter

    * Processor(*)\% processor time

    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
    PS>Invoke-IcingaCheckCPU -Warning 50 -Critical 75
    [OK]: Check package "CPU Load" is [OK]
    | 'Core #0'=4,59%;50;75;0;100 'Core #1'=0,94%;50;75;0;100 'Core #2'=11,53%;50;75;0;100 'Core #3'=4,07%;50;75;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckCPU -Warning 50 -Critical 75 -Core 1
    [OK]: Check package "CPU Load" is [OK]
    | 'Core #1'=2,61%;50;75;0;100
.PARAMETER Warning
    Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
    Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Core
    Used to specify a single core to check for. For the average load across all cores use `_Total`
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

function Invoke-IcingaCheckCPU()
{
    param (
        $Warning            = $null,
        $Critical           = $null,
        [string]$Core       = '*',
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

    $CpuCounter       = New-IcingaPerformanceCounterArray '\Processor(*)\% processor time';
    $CounterStructure = New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash $CpuCounter;
    $CpuPackage       = New-IcingaCheckPackage -Name 'CPU Load' -OperatorAnd -Verbose $Verbosity;
    [int]$CpuCount    = ([string](Get-IcingaCPUCount -CounterArray $CounterStructure)).Length;

    foreach ($counter in $CounterStructure.Keys) {
        if ($Core -ne '*' -And $counter -ne $Core) {
            continue;
        }
        $IcingaCheck = (
            New-IcingaCheck `
                -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount -Value $counter.Replace('_', '') -Digits $CpuCount -Symbol ' '))) `
                -Value $CounterStructure[$counter]['% processor time'].value `
                -Unit '%' `
                -MetricIndex ($counter.Replace('_', '')) `
                -MetricName 'load'
        ).WarnOutOfRange($Warning).CritOutOfRange($Critical);

        $CpuPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Name 'CPU Load' -Check $CpuPackage -NoPerfData $NoPerfData -Compile);
}
