<#
.SYNOPSIS
   Checks if a process is running;
.DESCRIPTION
   Invoke-IcingaCheckProcessRunning returns either 'ON' or 'CRITICAL' whether the process is running
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check if a process exist.
   Based whether the process is running the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckProcessRunning -Process Firefox
   [OK] Check package "Process Running Check"
   | 'process_firefox_running_check'=firefox;;
.PARAMETER Process
   Used to specify an array of processes to check if running.
   e.g. conhost,wininit
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckProcessRunning()
{
   param(
      [array]$Process,
      [switch]$NoPerfData,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0
   );

    $ProcessPackage = New-icingaCheckPackage -Name "Process Running Check" -OperatorAnd -Verbose $Verbosity -NoPerfData $NoPerfData;

    foreach ($proc in $Process) {
       $ProcessObject = Get-Process -Name $proc -ErrorAction SilentlyContinue | select -first 1
       $IcingaCheck = New-IcingaCheck -Name "Process $proc running Check" -Value $ProcessObject.ProcessName;
       $IcingaCheck.CritIfNotMatch([string]$proc) | Out-Null;
       $ProcessPackage.AddCheck($IcingaCheck);
    }
   
   return (New-IcingaCheckResult -Check $ProcessPackage -NoPerfData $NoPerfData -Compile);
}
