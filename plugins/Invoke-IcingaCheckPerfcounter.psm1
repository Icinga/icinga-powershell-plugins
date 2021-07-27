<#
.SYNOPSIS
   Performs checks on various performance counter
.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   Use "Show-IcingaPerformanceCounterCategories" to see all performance counter categories available.
   To gain insight on an specific performance counter use "Show-IcingaPerformanceCounters <performance counter category>"
   e.g '

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to perform checks on different performance counter.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
   PS> Invoke-IcingaCheckPerfCounter -PerfCounter '\processor(*)\% processor time' -Warning 60 -Critical 90
   [WARNING]: Check package "Performance Counter" is [WARNING]
   | 'processor1_processor_time'=68.95;60;90 'processor3_processor_time'=4.21;60;90 'processor5_processor_time'=9.5;60;90 'processor_Total_processor_time'=20.6;60;90 'processor0_processor_time'=5.57;60;90 'processor2_processor_time'=0;60;90 'processor4_processor_time'=6.66;60;90
.PARAMETER Warning
   Used to specify a Warning threshold.
.PARAMETER Critical
   Used to specify a Critical threshold.
.PARAMETER IgnoreEmptyChecks
    Overrides the default behaviour of the plugin in case no check element was found and
    prevent the plugin from exiting UNKNOWN and returns OK instead
.PARAMETER PerfCounter
   Used to specify an array of performance counter to check against.
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

function Invoke-IcingaCheckPerfCounter()
{
    param(
        [array]$PerfCounter,
        $Warning                   = $null,
        $Critical                  = $null,
        [switch]$IgnoreEmptyChecks = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $Counters     = New-IcingaPerformanceCounterArray -CounterArray $PerfCounter;
    $CheckPackage = New-IcingaCheckPackage -Name 'Performance Counter' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks;

    foreach ($counter in $Counters.Keys) {

        $CounterPackage = New-IcingaCheckPackage -Name $counter -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks;

        if ([string]::IsNullOrEmpty($Counters[$counter].error) -eq $FALSE) {
            $CheckPackage.AddCheck(
                (
                    New-IcingaCheck -Name $counter -NoPerfData
                ).SetUnknown($Counters[$counter].error, $TRUE)
            )
            continue;
        }

        foreach ($instanceName in $Counters[$counter].Keys) {
            $instance = $Counters[$counter][$instanceName];

            if ([string]::IsNullOrEmpty($instance.error) -eq $FALSE) {
                $CounterPackage.AddCheck(
                    (
                        New-IcingaCheck -Name $instanceName -NoPerfData
                    ).SetUnknown($instance.error, $TRUE)
                )
                continue;
            }

            if ($instance -IsNot [hashtable]) {
                $IcingaCheck  = New-IcingaCheck -Name $counter -Value $Counters[$counter].Value;
                $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
                $CounterPackage.AddCheck($IcingaCheck);
                break;
            }
            $IcingaCheck  = New-IcingaCheck -Name $instanceName -Value $instance.Value;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $CounterPackage.AddCheck($IcingaCheck);
        }
        $CheckPackage.AddCheck($CounterPackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
