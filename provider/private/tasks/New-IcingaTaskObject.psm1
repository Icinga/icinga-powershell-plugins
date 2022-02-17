function New-IcingaTaskObject()
{
    param (
        $Task = $null
    );

    if ($null -eq $Task) {
        return $null;
    }

    if ($null -ne $Task -And [string]::IsNullOrEmpty($Task.TaskName) -eq $FALSE -And [string]::IsNullOrEmpty($Task.TaskPath) -eq $FALSE) {
        $TaskInfo = Get-ScheduledTaskInfo -TaskName $Task.TaskName -TaskPath $Task.TaskPath -ErrorAction SilentlyContinue;
    } else {
        $TaskInfo = $null;
    }

    $LastRunTime        = $null;
    $NextRunTime        = $null;
    $NumberOfMissedRuns = $null;
    $LastTaskResult     = $null;

    if ($null -ne $TaskInfo) {
        if ($null -ne $TaskInfo.LastRunTime) {
            $LastRunTime = $TaskInfo.LastRunTime.ToString('yyyy\/MM\/dd HH:mm:ss');
        }
        if ($null -ne $TaskInfo.NextRunTime) {
            $NextRunTime = $TaskInfo.NextRunTime.ToString('yyyy\/MM\/dd HH:mm:ss');
        }
        $NumberOfMissedRuns = $TaskInfo.NumberOfMissedRuns;
        $LastTaskResult     = ([String]::Format("{0:X}", $TaskInfo.LastTaskResult));
    }

    return @{
        'TaskName'           = $Task.TaskName;
        'TaskPath'           = $Task.TaskPath;
        'State'              = $Task.State;
        'LastRunTime'        = $LastRunTime;
        'LastTaskResult'     = $LastTaskResult;
        'NextRunTime'        = $NextRunTime;
        'NumberOfMissedRuns' = $NumberOfMissedRuns;
    };
}
