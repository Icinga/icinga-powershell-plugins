function Get-IcingaScheduledTask()
{
    param (
        [array]$TaskName
    );

    $Tasks      = @( );
    $TaskFilter = @{ };
    $TaskNames  = @{ };

    if ($TaskName.Count -eq 0) {
        $Tasks = Get-ScheduledTask -TaskName '*';
    } else {
        $Tasks = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue;
    }

    foreach ($task in $Tasks) {
        $CreatedTask = (New-IcingaTaskObject -Task $task)

        if ($TaskFilter.ContainsKey($task.TaskPath) -eq $FALSE) {
            $TaskFilter.Add(
                $task.TaskPath,
                @( $CreatedTask )
            );
        } else {
            $TaskFilter[$task.TaskPath] += $CreatedTask;
        }

        if ($TaskNames.ContainsKey($task.TaskName) -eq $FALSE) {
            $TaskNames.Add($task.TaskName, $TRUE);
        }
    }

    $TaskFilter.Add(
        'Unknown Tasks',
        @()
    );

    foreach ($task in $TaskName) {
        if ($task -eq '*' -or $task.Contains('*')) {
            continue;
        }

        if ($TaskNames.ContainsKey($task) -eq $FALSE) {
            $TaskFilter['Unknown Tasks'] += $task;
        }
    }

    return $TaskFilter;
}
