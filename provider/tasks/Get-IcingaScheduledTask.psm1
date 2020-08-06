function Get-IcingaScheduledTask()
{
    param (
        [array]$TaskName
    );

    $Tasks = @();

    if ($TaskName.Count -eq 0) {
        $Tasks = Get-ScheduledTask -TaskName '*';
    } else {
        $Tasks = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue;
    }

    return $Tasks;
}
