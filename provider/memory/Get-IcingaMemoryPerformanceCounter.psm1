function Global:Get-IcingaMemoryPerformanceCounter()
{

    if ((Test-IcingaPerformanceCounterCategory -Category 'Memory') -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PerfCounterCategoryMissing -CustomMessage 'Category "Memory" not found' -Force;
    }

    $PerfCounters          = New-IcingaPerformanceCounterArray -Counter "\Memory\% committed bytes in use", "\Memory\Available Bytes", "\Paging File(*)\% usage";
    [hashtable]$Initial    = @{ };
    [hashtable]$MemoryData = @{
        'PageFile' = @{ }
    };

    foreach ($item in $PerfCounters.Keys) {
        $Initial.Add($item, $PerfCounters[$item]);
    }

    $MemoryData.Add(
        'Memory Available Bytes',
        [decimal]($Initial['\Memory\Available Bytes'].value)
    );
    $MemoryData.Add(
        'Memory Total Bytes',
        (Get-IcingaWindowsInformation Win32_ComputerSystem).TotalPhysicalMemory
    );
    $MemoryData.Add(
        'Memory Used Bytes',
        ($MemoryData['Memory Total Bytes'] - $MemoryData['Memory Available Bytes'])
    );
    $MemoryData.Add(
        'Memory Used %',
        (100 - [Math]::Round(($MemoryData['Memory Available Bytes'] / $MemoryData['Memory Total Bytes']) * 100, 2))
    );
    $MemoryData.Add(
        'Committed Bytes %',
        $Initial.'\Memory\% committed bytes in use'.value
    );
    $MemoryData.Add(
        'PageFile Total Bytes',
        0
    );
    $MemoryData.Add(
        'PageFile Used Bytes',
        0
    );
    $MemoryData.Add(
        'PageFile Used %',
        0
    );

    if ((Get-IcingaWindowsInformation Win32_ComputerSystem).AutomaticManagedPagefile -eq $FALSE) {
        # Page File is managed by User
        $PageFileSettings = Get-IcingaWindowsInformation Win32_PageFileSetting;

        foreach ($entry in $PageFileSettings) {
            if ($MemoryData.PageFile.ContainsKey($entry.Name)) {
                continue;
            }

            $MemoryData.PageFile.Add(
                $entry.Name,
                @{
                    'InitialSize' = $entry.InitialSize;
                    'Managed'     = $TRUE;
                    'Name'        = $entry.Name;
                    'TotalSize'   = $entry.MaximumSize;
                }
            );

            $MemoryData['PageFile Total Bytes'] += $entry.MaximumSize;
            $MemoryData['PageFile Used Bytes']  += $entry.InitialSize;
        }
    }

    # Page File is managed by Windows
    $PageFileUsage = Get-IcingaWindowsInformation Win32_PageFileUsage;

    foreach ($entry in $PageFileUsage) {
        if ($MemoryData.PageFile.ContainsKey($entry.Name)) {
            $MemoryData.PageFile[$entry.Name].Add(
                'Allocated', $entry.AllocatedBaseSize
            );
            $MemoryData.PageFile[$entry.Name].Add(
                'Usage', $entry.CurrentUsage
            );
            $MemoryData.PageFile[$entry.Name].Add(
                'PeakUsage', $entry.PeakUsage
            );
            $MemoryData.PageFile[$entry.Name].Add(
                'TempPageFile', $entry.TempPageFile
            );
            continue;
        }

        $MemoryData.PageFile.Add(
            $entry.Name,
            @{
                'InitialSize'  = 0;
                'MaximumSize'  = 0;
                'TotalSize'    = $entry.AllocatedBaseSize;
                'Allocated'    = $entry.AllocatedBaseSize;
                'Usage'        = $entry.CurrentUsage;
                'PeakUsage'    = $entry.PeakUsage;
                'TempPageFile' = $entry.TempPageFile;
                'Managed'      = $FALSE;
                'Name'         = $entry.Name;
            }
        );

        $MemoryData['PageFile Total Bytes'] += $entry.AllocatedBaseSize;
        $MemoryData['PageFile Used Bytes']  += $entry.CurrentUsage;
    }

    foreach ($entry in $PerfCounters['\Paging File(*)\% usage'].Keys) {

        $AvailablePageFiles = $MemoryData.PageFile.Keys;

        foreach ($PageFile in $AvailablePageFiles) {
            if ($entry -Like ([string]::Format('*{0}*', $PageFile)))  {
                $MemoryData.PageFile[$PageFile].Add(
                    'PercentUsed', $PerfCounters['\Paging File(*)\% usage'][$entry].value
                );
                break;
            }
        }
    }

    if ($MemoryData['PageFile Total Bytes'] -ne 0) {
        $MemoryData['PageFile Used %'] = [Math]::Round(($MemoryData['PageFile Used Bytes']) / ($MemoryData['PageFile Total Bytes']) * 100, 2);
    }

    return $MemoryData;
}
