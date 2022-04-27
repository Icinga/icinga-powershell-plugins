function Add-IcingaProcessPerfData()
{
    param (
        $ProcessList,
        $ProcessKey,
        $Process
    );

    if ($ProcessList.ContainsKey($ProcessKey) -eq $FALSE) {
        $ProcessList.Add($ProcessKey, $Process.$ProcessKey);
    } else {
        $ProcessList[$ProcessKey] += $Process.$ProcessKey;
    }
}

function Get-IcingaProcessData {

    param (
        [array]$Process = @()
    );

    $ProcessInformation     = Get-IcingaWindowsInformation Win32_Process;
    $ProcessPerfDataList    = Get-IcingaWindowsInformation Win32_PerfFormattedData_PerfProc_Process;
    $CPUCoreCount           = Get-IcingaCPUCount;

    [hashtable]$ProcessData        = @{ };
    [hashtable]$ProcessList        = @{ };
    [hashtable]$ProcessNamesUnique = @{ };
    [hashtable]$ProcessIDsByName   = @{ };

    foreach ($ProcInfo in $ProcessInformation) {
        [string]$processName = $ProcInfo.Name.Replace('.exe', '');

        if ($Process.Count -ne 0) {
            if (-Not ($Process.Contains($processName))) {
                continue;
            }
        }

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            $ProcessList.Add(
                $processName,
                @{
                    'ProcessList'     = @{ };
                    'PerformanceData' = @{ }
                }
            );
        }

        $ProcessList[$processName]['ProcessList'].Add(
            [string]$ProcInfo.ProcessID,
            @{
                'Name'           = $ProcInfo.Name;
                'ProcessId'      = $ProcInfo.ProcessId;
                'Priority'       = $ProcInfo.Priority;
                'PageFileUsage'  = $ProcInfo.PageFileUsage;
                'ThreadCount'    = $ProcInfo.ThreadCount;
                'KernelModeTime' = $ProcInfo.KernelModeTime;
                'UserModeTime'   = $ProcInfo.UserModeTime;
                'WorkingSetSize' = $ProcInfo.WorkingSetSize;
                'CommandLine'    = $ProcInfo.CommandLine;
            }
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'ThreadCount' -Process $ProcInfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'PageFileUsage' -Process $ProcInfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'KernelModeTime' -Process $ProcInfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'UserModeTime' -Process $ProcInfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetSize' -Process $ProcInfo;
    }

    foreach ($ProcInfo in $ProcessPerfDataList) {

        if ($ProcInfo.Name -eq '_Total' -Or $ProcInfo.Name -eq 'Idle') {
            continue;
        }

        [string]$processName = $ProcInfo.Name.Split('#')[0];
        [string]$ProcessId   = [string]$ProcInfo.IDProcess;

        if ($Process.Count -ne 0) {
            If (-Not ($Process.Contains($processName))) {
                continue;
            }
        }

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            continue;
        }

        if ($ProcessList[$processName]['ProcessList'].ContainsKey($ProcessId) -eq $FALSE) {
            continue;
        }

        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'WorkingSetPrivate', ($ProcInfo.WorkingSetPrivate)
        );
        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'PercentProcessorTime', ($ProcInfo.PercentProcessorTime)
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetPrivate' -Process $ProcInfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'PercentProcessorTime' -Process $ProcInfo;
    }

    $ProcessData.Add('Process Count', $ProcessInformation.Count);
    $ProcessData.add('Processes', $ProcessList);

    return $ProcessData;
}
