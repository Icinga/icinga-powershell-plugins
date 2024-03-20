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

    * \Processor Information(*)\% Processor Utility

    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
    PS>Invoke-IcingaCheckCPU -Warning '60%' -Critical '80%';
    [OK] CPU Load
    | '0_4::ifw_cpu::load'=9.149948%;60;80;0;100 '0_2::ifw_cpu::load'=9.431381%;60;80;0;100 '0_6::ifw_cpu::load'=24.89185%;60;80;0;100 'totalload::ifw_cpu::load'=10.823693%;60;80;0;100 '0_7::ifw_cpu::load'=9.531499%;60;80;0;100 '0_3::ifw_cpu::load'=8.603164%;60;80;0;100 '0_1::ifw_cpu::load'=6.57868%;60;80;0;100 '0_total::ifw_cpu::load'=10.823693%;60;80;0;100 '0_5::ifw_cpu::load'=8.502121%;60;80;0;100 '0_0::ifw_cpu::load'=9.900898%;60;80;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckCPU -Warning '60%' -Critical '80%' -Core 'Total';
    [OK] CPU Load
    | 'totalload::ifw_cpu::load'=11.029226%;60;80;0;100 '0_total::ifw_cpu::load'=11.029226%;60;80;0;100
.PARAMETER Warning
    Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
    Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Core
    Used to specify a single core to check for. For the average load across all cores use `_Total`
.PARAMETER SocketFilter
    Allows to specify one or mutlitple sockets by using their socket id. Not matching socket id's will not be evaluated
    by the plugin.
.PARAMETER OverallOnly
    If this flag is set, the Warning and Critical thresholds will only apply to the `Overall Load` metric instead of all
    returned cores. Requires that the plugin either fetches all cores with `*` or `Total` for the -Core argument
.PARAMETER OverallTotalAsSum
    Changes the output of the overall total load to report the sum of all sockets combined instead of the default
    average of all sockets
.PARAMETER DisableProcessList
    Disables the reporting of the top 10 CPU consuming process list
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
        $Warning                    = $null,
        $Critical                   = $null,
        [string]$Core               = '*',
        [array]$SocketFilter        = @(),
        [switch]$OverallOnly        = $FALSE,
        [switch]$OverallTotalAsSum  = $FALSE,
        [switch]$DisableProcessList = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity             = 0
    );

    $CpuData        = Get-IcingaProviderDataValuesCpu;
    $CpuPackage     = New-IcingaCheckPackage -Name 'CPU Load' -OperatorAnd -Verbose $Verbosity;
    $ProcessPackage = New-IcingaCheckPackage -Name 'Top 10 Process CPU usage' -OperatorAnd -Verbose 2 -IgnoreEmptyPackage;

    foreach ($socket in (Get-IcingaProviderElement $CpuData.Metrics)) {
        [string]$SocketId = $socket.Name.Replace('Socket #', '');

        if ((Test-IcingaArrayFilter -InputObject $SocketId -Include $SocketFilter) -eq $FALSE) {
            continue;
        }

        $SocketPackage = New-IcingaCheckPackage -Name $socket.Name -OperatorAnd -Verbose $Verbosity;

        foreach ($thread in (Get-IcingaProviderElement $socket.Value)) {
            # Transform "_Total" to "Total"
            $Core = $Core.Replace('_', '');

            if ($Core -ne '*' -And $thread.Name -ne $Core) {
                continue;
            }

            $IcingaCheck = (
                New-IcingaCheck `
                    -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount -Value $thread.Name -Digits $CpuData.Metadata.CoreDigits -Symbol ' '))) `
                    -Value $thread.Value `
                    -Unit '%' `
                    -MetricIndex ([string]::Format('{0}_{1}', $SocketId, $thread.Name)) `
                    -MetricName 'load'
            );

            # Only alert for warning/critical if 'OverallOnly' is not set
            if ($OverallOnly -eq $FALSE) {
                $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            }

            $SocketPackage.AddCheck($IcingaCheck);
        }

        $CpuPackage.AddCheck($SocketPackage);
    }

    if ($Core -eq '*' -Or $Core -Like '*Total*') {
        $TotalLoadValue = $CpuData.Metadata.TotalLoad;

        if ($OverallTotalAsSum) {
            $TotalLoadValue = $CpuData.Metadata.TotalLoadSum;
        }

        $IcingaCheck = (
            New-IcingaCheck `
                -Name 'Overall Load' `
                -Value $TotalLoadValue `
                -Unit '%' `
                -MetricIndex 'totalload' `
                -MetricName 'load'
        ).WarnOutOfRange($Warning).CritOutOfRange($Critical);

        $CpuPackage.AddCheck($IcingaCheck);
    }

    if ($DisableProcessList -eq $FALSE) {
        $ProcessData   = Get-IcingaProviderDataValuesProcess;
        [bool]$HasData = $FALSE;

        foreach ($cpuProcess in (Get-IcingaProviderElement $ProcessData.Metadata.Hot.Cpu)) {
            $HasData      = $TRUE;
            $ProcessCheck = New-IcingaCheck -Name ([string]::Format('Process {0} with id {1}', $cpuProcess.Value.Name, $cpuProcess.Value.ProcessId)) -Value $cpuProcess.Value.CpuUsage -Unit '%' -NoPerfData;
            $ProcessPackage.AddCheck($ProcessCheck);
        }

        if ($HasData -eq $FALSE) {
            $ProcessCheck = New-IcingaCheck -Name 'Process Data' -NoPerfData;
            $ProcessCheck.SetOk('No process with high CPU usage found', $TRUE) | Out-Null;
            $ProcessPackage.AddCheck($ProcessCheck);
        }

        $CpuPackage.AddCheck($ProcessPackage);
    }

    return (New-IcingaCheckResult -Name 'CPU Load' -Check $CpuPackage -NoPerfData $NoPerfData -Compile);
}
