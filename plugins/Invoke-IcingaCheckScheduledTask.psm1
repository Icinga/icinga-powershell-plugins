<#
.SYNOPSIS
    Checks the current state for a list of specified tasks based on their name and prints the result
.DESCRIPTION
    Check for a list of tasks by their name and compare their current state with a plugin argument
    to determine the plugin output. States of tasks not matching the plugin argument will return
    [CRITICAL], while all other tasks will return [OK]. For not found tasks we will return [UNKNOWN]
    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This plugin will let you check for scheduled tasks and their current state and compare it with the
    plugin argument to determine if they are fine or not
.EXAMPLE
    PS>Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Ready';
    [OK] Check package "Scheduled Tasks"
    | 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Ready 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Ready
.EXAMPLE
    PS>Invoke-IcingaCheckScheduledTask -TaskName 'AutomaticBackup', 'Windows Backup Monitor' -State 'Disabled';
    [CRITICAL] Check package "Scheduled Tasks" - [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\), Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\)
    \_ [CRITICAL] Check package "\Microsoft\Windows\WindowsBackup\"
        \_ [CRITICAL] AutomaticBackup (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"
        \_ [CRITICAL] Windows Backup Monitor (\Microsoft\Windows\WindowsBackup\): Value "Ready" is not matching threshold "Disabled"
    | 'automaticbackup_microsoftwindowswindowsbackup'=Ready;;Disabled 'windows_backup_monitor_microsoftwindowswindowsbackup'=Ready;;Disabled
.PARAMETER TaskName
   A list of tasks to check for. If your tasks contain spaces, wrap them around a ' to ensure they are
   properly handled as string
.PARAMETER State
   The state a task should currently have for the plugin to return [OK]
   Force the usage of IPv6 addresses for ICMP calls by using a hostname
.PARAMETER NoPerfData
   Set this argument to not write any performance data
.PARAMETER Verbosity
   Increase the printed output message by adding additional details or print all data regardless of their status
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckScheduledTask()
{
    param (
        [array]$TaskName,
        [ValidateSet('Unknown', 'Disabled', 'Queued', 'Ready', 'Running')]
        [string]$State,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity     = 0
    );

    $TaskPackages  = New-IcingaCheckPackage -Name 'Scheduled Tasks' -OperatorAnd -Verbose $Verbosity;
    $Tasks         = Get-IcingaScheduledTask -TaskName $TaskName;

    foreach ($taskpath in $Tasks.Keys) {
        $TaskArray = $Tasks[$taskpath];

        $CheckPackage = New-IcingaCheckPackage -Name $taskpath -OperatorAnd -Verbose $Verbosity;

        foreach ($task in $TaskArray) {
            if ($taskpath -eq 'Unknown Tasks') {
                $CheckPackage.AddCheck(
                    (
                        New-IcingaCheck -Name ([string]::Format('{0}: Task not found', $task))
                    ).SetUnknown()
                )
            } else {
                $CheckPackage.AddCheck(
                    (
                        New-IcingaCheck -Name ([string]::Format('{0} ({1})', $task.TaskName, $task.TaskPath)) -Value ($ProviderEnums.ScheduledTaskStatus[[string]$task.State]) -Translation $ProviderEnums.ScheduledTaskName
                    ).CritIfNotMatch($ProviderEnums.ScheduledTaskStatus[$State])
                )
            }
        }

        if ($CheckPackage.HasChecks()) {
            $TaskPackages.AddCheck($CheckPackage);
        }
    }

    return (New-IcingaCheckResult -Check $TaskPackages -NoPerfData $NoPerfData -Compile);
}
