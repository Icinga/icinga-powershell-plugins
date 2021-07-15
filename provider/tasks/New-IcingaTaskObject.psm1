function New-IcingaTaskObject()
{
    param (
        $Task = $null
    );

    if ($null -eq $Task) {
        return $null;
    }

    $TaskInfo = Get-ScheduledTaskInfo -TaskName $Task.TaskName -TaskPath $Task.TaskPath;

    $LastRunTime = $null;
    $NextRunTime = $null;

    if ($null -ne $TaskInfo.LastRunTime) {
        $LastRunTime = $TaskInfo.LastRunTime.ToString('yyyy\/MM\/dd HH:mm:ss');
    }
    if ($null -ne $TaskInfo.NextRunTime) {
        $NextRunTime = $TaskInfo.NextRunTime.ToString('yyyy\/MM\/dd HH:mm:ss');
    }

    return @{
        'TaskName'           = $Task.TaskName;
        'TaskPath'           = $Task.TaskPath;
        'State'              = $Task.State;
        'LastRunTime'        = $LastRunTime;
        'LastTaskResult'     = ([String]::Format("{0:X}", $TaskInfo.LastTaskResult));
        'NextRunTime'        = $NextRunTime;
        'NumberOfMissedRuns' = $TaskInfo.NumberOfMissedRuns;
    };
}
