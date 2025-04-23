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
.PARAMETER WarningMissedRuns
    Defines a warning threshold for missed runs for filtered tasks.

    Supports Icinga default threshold syntax.
.PARAMETER CriticalMissedRuns
    Defines a critical threshold for missed runs for filtered tasks.

    Supports Icinga default threshold syntax.
.PARAMETER WarningLastRunTime
    Allows to specify a time interval, on which the check will return warning based on the last run time
    of a task and the current time. The LastRunTime is an offset of the last time the task run to the current time, therefore increasing over time

    Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y
.PARAMETER CriticalLastRunTime
    Allows to specify a time interval, on which the check will return critical based on the last run time
    of a task and the current time. The LastRunTime is an offset of the last time the task run to the current time, therefore increasing over time

    Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y
.PARAMETER WarningNextRunTime
    Allows to specify a time interval, on which the check will return warning based on the next run time
    of a task and the current time. The NextRunTime is an offset of the next time the task will run to the current time, therefore increasing over time.
    Negative NextRunTime values mean the task is scheduled in the future

    Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y
.PARAMETER CriticalNextRunTime
    Allows to specify a time interval, on which the check will return critical based on the next run time
    of a task and the current time. The NextRunTime is an offset of the next time the task will run to the current time, therefore increasing over time.
    Negative NextRunTime values mean the task is scheduled in the future

    Values have to be specified as time units like, 10m, 1d, 1w, 2M, 1y
.PARAMETER IgnoreLastRunTime
    By default every task which did not exit with 0 will be handled as critical. If you set this flag,
    the exit code of the task is ignored during check execution
.PARAMETER IgnoreExitCodes
    A list of exit codes which will be considered as [OK]. By default every task which did not exit with 0 will be handled as critical.
.PARAMETER NoPerfData
   Set this argument to not write any performance data
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

function Invoke-IcingaCheckScheduledTask()
{
    param (
        [array]$TaskName             = @(),
        [ValidateSet('Unknown', 'Disabled', 'Queued', 'Ready', 'Running')]
        [array]$State                = @(),
        [array]$IgnoreExitCodes      = @(),
        $WarningMissedRuns           = $null,
        $CriticalMissedRuns          = $null,
        [string]$WarningLastRunTime  = '',
        [string]$CriticalLastRunTime = '',
        [string]$WarningNextRunTime  = '',
        [string]$CriticalNextRunTime = '',
        [switch]$IgnoreLastRunTime   = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity              = 0
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
                $TaskPackage = New-IcingaCheckPackage -Name $task.TaskName -OperatorAnd -Verbose $Verbosity;
                $MetricIndex = [string]::Format('{0}{1}', $task.TaskPath, $task.TaskName).Replace('\', '_');

                if ($MetricIndex[0] -eq '_') {
                    $MetricIndex = $MetricIndex.Substring(1, $MetricIndex.Length - 1);
                }

                $TaskState = New-IcingaCheck `
                    -Name 'State' `
                    -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0} ({1})', $task.TaskName, $task.TaskPath))) `
                    -Value ($ProviderEnums.ScheduledTaskStatus[[string]$task.State]) `
                    -Translation $ProviderEnums.ScheduledTaskName `
                    -MetricIndex $MetricIndex `
                    -MetricName 'state';

                $TaskMissedRunes = New-IcingaCheck `
                    -Name 'Missed Runs' `
                    -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0} ({1}) MissedRuns', $task.TaskName, $task.TaskPath))) `
                    -Value $task.NumberOfMissedRuns `
                    -MetricIndex $MetricIndex `
                    -MetricName 'missedruns';

                $TaskLastResult = New-IcingaCheck `
                    -Name 'Last Task Result' `
                    -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0} ({1}) LastTaskResult', $task.TaskName, $task.TaskPath))) `
                    -Value $task.LastTaskResult `
                    -MetricIndex $MetricIndex `
                    -MetricName 'lasttaskresult';

                [string]$TaskLastRunTimeDate = $task.LastRunTime;

                if ([string]::IsNullOrEmpty($TaskLastRunTimeDate)) {
                    $TaskLastRunTimeDate = 'Never';
                }

                $TaskLastRunTime = New-IcingaCheck `
                    -Name ([string]::Format('Last Run Time [{0}]', $TaskLastRunTimeDate)) `
                    -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0} ({1}) LastRunTime', $task.TaskName, $task.TaskPath))) `
                    -Value (Get-IcingaUnixTimeOffsetNow -TimeString $task.LastRunTime) `
                    -Unit 's' `
                    -Translation @{ 0 = 'Never'; } `
                    -MetricIndex $MetricIndex `
                    -MetricName 'lastruntime';

                [string]$TaskNextRunTimeDate = $task.NextRunTime;

                if ([string]::IsNullOrEmpty($TaskNextRunTimeDate)) {
                    $TaskNextRunTimeDate = 'Never';
                }

                $TaskNextRunTime = New-IcingaCheck `
                    -Name ([string]::Format('Next Run Time [{0}]', $TaskNextRunTimeDate)) `
                    -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0} ({1}) NextRunTime', $task.TaskName, $task.TaskPath))) `
                    -Value (Get-IcingaUnixTimeOffsetNow -TimeString $task.NextRunTime) `
                    -Unit 's' `
                    -Translation @{ 0 = 'Never'; } `
                    -MetricIndex $MetricIndex `
                    -MetricName 'nextruntime';

                if ($State.Count -ne 0 -and $State -NotContains ([string]$task.State)) {
                    $TaskState.CritIfNotMatch($ProviderEnums.ScheduledTaskStatus[$State[0]]) | Out-Null;
                }

                $TaskMissedRunes.WarnOutOfRange($WarningMissedRuns).CritOutOfRange($CriticalMissedRuns) | Out-Null;
                if ($task.LastTaskResult -ne 0 -And $IgnoreLastRunTime -eq $FALSE -and $IgnoreExitCodes -NotContains $task.LastTaskResult) {
                    $TaskLastResult.SetCritical() | Out-Null;
                }
                $TaskLastRunTime.WarnOutOfRange($WarningLastRunTime).CritOutOfRange($CriticalLastRunTime) | Out-Null;
                $TaskNextRunTime.WarnOutOfRange($WarningNextRunTime).CritOutOfRange($CriticalNextRunTime) | Out-Null;

                $TaskPackage.AddCheck($TaskState);
                $TaskPackage.AddCheck($TaskMissedRunes);
                $TaskPackage.AddCheck($TaskLastResult);
                $TaskPackage.AddCheck($TaskLastRunTime);
                $TaskPackage.AddCheck($TaskNextRunTime);

                $CheckPackage.AddCheck($TaskPackage);
            }
        }

        if ($CheckPackage.HasChecks()) {
            $TaskPackages.AddCheck($CheckPackage);
        }
    }

    return (New-IcingaCheckResult -Check $TaskPackages -NoPerfData $NoPerfData -Compile);
}
