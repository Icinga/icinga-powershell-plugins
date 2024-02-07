<#
.SYNOPSIS
    A plugin to check thread, cpu, memory and pagefile usage for each single process
.DESCRIPTION
    Allows to check of single process and total process resource usage. This includes
    cpu, memory, pagefile, thread count and process count usage.

    It is not recommended for checking the total process count of all running processes, because of performance
    impact. Use the `Invoke-IcingaCheckProcessCount` plugin for this.

    Checking stats and process count for a group of processes with a certain name including resources is supported
    and the plugin recommended for this case.
.PARAMETER PageFileWarning
    Compares each single process page file usage against the given threshold. Will throw warning if exceeded.
    Supports % unit to compare the process page file usage for the entire page file space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER PageFileCritical
    Compares each single process page file usage against the given threshold. Will throw critical if exceeded.
    Supports % unit to compare the process page file usage for the entire page file space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER MemoryWarning
    Compares each single process memory usage against the given threshold. Will throw warning if exceeded.
    Supports % unit to compare the process memory usage for the entire memory space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER MemoryCritical
    Compares each single process memory usage against the given threshold. Will throw critical if exceeded.
    Supports % unit to compare the process memory usage for the entire memory space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER CPUWarning
    Compares each single process cpu usage against the given threshold. Will throw warning if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER CPUCritical
    Compares each single process cpu usage against the given threshold. Will throw critical if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER ThreadCountWarning
    Compares each single process thread usage against the given threshold. Will throw warning if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER ThreadCountCritical
    Compares each single process thread usage against the given threshold. Will throw critical if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalPageFileWarning
    Compares page file usage for all processes with the same name against the given threshold. Will throw warning if exceeded.
    Supports % unit to compare the total process page file usage for the entire page file space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalPageFileCritical
    Compares page file usage for all processes with the same name against the given threshold. Will throw critical if exceeded.
    Supports % unit to compare the total process page file usage for the entire page file space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalMemoryWarning
    Compares memory usage for all processes with the same name against the given threshold. Will throw warning if exceeded.
    Supports % unit to compare the total process memory usage for the entire memory space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalMemoryCritical
    Compares memory usage for all processes with the same name against the given threshold. Will throw critical if exceeded.
    Supports % unit to compare the total process memory usage for the entire memory space available.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalCPUWarning
    Compares cpu usage for all processes with the same name against the given threshold. Will throw warning if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalCPUCritical
    Compares cpu usage for all processes with the same name against the given threshold. Will throw critical if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalThreadCountWarning
    Compares thread usage for all processes with the same name against the given threshold. Will throw warning if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalThreadCountCritical
    Compares thread usage for all processes with the same name against the given threshold. Will throw critical if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalProcessCountWarning
    Compares process count for all processes with the same name against the given threshold. Will throw warning if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER TotalProcessCountCritical
    Compares process count for all processes with the same name against the given threshold. Will throw critical if exceeded.

    Follows the Icinga Plugin threshold guidelines.
.PARAMETER Process
    Allows to filter for a list of processes with a given name. Use the process name without file ending, like '.exe'.
.PARAMETER ExcludeProcess
    Define a list of process names which are excluded from the final result. Only the process name is required without '.exe' at the end.
.PARAMETER NoPerfData
    Set this argument to not write any performance data
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'powershell';

    [OK] Process Overview: 1 Ok
    | 'powershell::ifw_process::cpu'=76%;;;0;100 'powershell::ifw_process::memory'=1501471000B;;;0;6436880000 'powershell::ifw_process::pagefile'=1885120B;;;0;6979322000 'powershell::ifw_process::count'=7c;; 'powershell::ifw_process::threads'=106c;;
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'powershell' -CPUWarning '1%' -TotalCPUWarning '5%';

    [WARNING] Process Overview: 1 Warning [WARNING] powershell
    \_ [WARNING] powershell
        \_ [WARNING] powershell [13436]
            \_ [WARNING] CPU Usage: 75.00% is greater than threshold 1%
        \_ [WARNING] powershell [9332]
            \_ [WARNING] CPU Usage: 98.00% is greater than threshold 1%
        \_ [WARNING] powershell Summary
            \_ [WARNING] CPU Usage: 173.00% is greater than threshold 5%
    | 'powershell::ifw_process::cpu'=173%;5;;0;173 'powershell::ifw_process::memory'=1510900000B;;;0;6436880000 'powershell::ifw_process::pagefile'=1892332B;;;0;6979322000 'powershell::ifw_process::count'=7c;; 'powershell::ifw_process::threads'=112c;;
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'SearchIndexer' -MemoryWarning '0.1%';

    [WARNING] Process Overview: 1 Warning [WARNING] SearchIndexer
    \_ [WARNING] SearchIndexer
        \_ [WARNING] SearchIndexer [5112]
            \_ [WARNING] Memory Usage: 0.30% (18.56MiB) is greater than threshold 0.1% (6.14MiB)
    | 'searchindexer::ifw_process::count'=1c;; 'searchindexer::ifw_process::pagefile'=24156B;;;0;6979322000 'searchindexer::ifw_process::threads'=8c;; 'searchindexer::ifw_process::cpu'=0%;;;0;100 'searchindexer::ifw_process::memory'=19460100B;;;0;6436880000
#>
function Invoke-IcingaCheckProcess()
{
    param (
        $PageFileWarning           = $null,
        $PageFileCritical          = $null,
        $MemoryWarning             = $null,
        $MemoryCritical            = $null,
        $CPUWarning                = $null,
        $CPUCritical               = $null,
        $ThreadCountWarning        = $null,
        $ThreadCountCritical       = $null,
        $TotalPageFileWarning      = $null,
        $TotalPageFileCritical     = $null,
        $TotalMemoryWarning        = $null,
        $TotalMemoryCritical       = $null,
        $TotalCPUWarning           = $null,
        $TotalCPUCritical          = $null,
        $TotalThreadCountWarning   = $null,
        $TotalThreadCountCritical  = $null,
        $TotalProcessCountWarning  = $null,
        $TotalProcessCountCritical = $null,
        [array]$Process            = @(),
        [array]$ExcludeProcess     = @(),
        [switch]$NoPerfData        = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $ProviderInformation    = Get-IcingaProviderData -Name 'Process' -IncludeFilter $Process -ExcludeFilter $ExcludeProcess;
    $ProcessData            = $ProviderInformation.Process;
    $MemoryData             = Get-IcingaMemoryPerformanceCounter;
    $ProcessOverviewPackage = New-IcingaCheckPackage -Name 'Process Overview' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    foreach ($entry in (Get-IcingaProviderElement $ProcessData.Metrics)) {
        $ProcessName    = $entry.Name;
        $ProcessPackage = New-IcingaCheckPackage -Name $processName -OperatorAnd -Verbose $Verbosity;

        foreach ($processDetail in (Get-IcingaProviderElement $entry.Value.List)) {
            $ProcessCheckPackageName = [string]::Format('{0} [{1}]', $processName, $processDetail.Value.ProcessId);
            $ProcessIdPackage        = New-IcingaCheckPackage -Name $ProcessCheckPackageName -OperatorAnd -Verbose $Verbosity;

            $PageFileCheck = New-IcingaCheck -Name 'Page File Usage' -Value $processDetail.Value.PageFileUsage -Unit 'B' -NoPerfData -BaseValue $MemoryData['PageFile Total Bytes'] -Minimum 0 -Maximum $MemoryData['PageFile Total Bytes'];
            $PageFileCheck.WarnOutOfRange($PageFileWarning).CritOutOfRange($PageFileCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($PageFileCheck);

            $MemoryCheck = New-IcingaCheck -Name 'Memory Usage' -Value $processDetail.Value.MemoryUsage -Unit 'B' -NoPerfData -BaseValue $MemoryData['Memory Total Bytes'] -Minimum 0 -Maximum $MemoryData['Memory Total Bytes'];
            $MemoryCheck.WarnOutOfRange($MemoryWarning).CritOutOfRange($MemoryCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($MemoryCheck);

            $CPUCheck = New-IcingaCheck -Name 'CPU Usage' -Value $processDetail.Value.CpuUsage -Unit '%' -NoPerfData;
            $CPUCheck.WarnOutOfRange($CPUWarning).CritOutOfRange($CPUCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($CPUCheck);

            $ThreadCheck = New-IcingaCheck -Name 'Thread Count' -Value $processDetail.Value.ThreadCount -Unit 'c' -NoPerfData;
            $ThreadCheck.WarnOutOfRange($ThreadCountWarning).CritOutOfRange($ThreadCountCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($ThreadCheck);

            $ProcessPackage.AddCheck($ProcessIdPackage);
        }

        $ProcessSummary = New-IcingaCheckPackage -Name ([string]::Format('{0} Summary', $ProcessName)) -OperatorAnd -Verbose $Verbosity;

        $PageFileCheck = New-IcingaCheck -Name 'Page File Usage' -Value $entry.Value.Total.PageFileUsage -Unit 'B' -MetricIndex $ProcessName -MetricName 'pagefile' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_page_file_usage', $ProcessName.ToLower()))) -BaseValue $MemoryData['PageFile Total Bytes'] -Minimum 0 -Maximum $MemoryData['PageFile Total Bytes'];
        $PageFileCheck.WarnOutOfRange($TotalPageFileWarning).CritOutOfRange($TotalPageFileCritical) | Out-Null;
        $ProcessSummary.AddCheck($PageFileCheck);

        $MemoryCheck = New-IcingaCheck -Name 'Memory Usage' -Value $entry.Value.Total.MemoryUsage -Unit 'B' -MetricIndex $ProcessName -MetricName 'memory' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_memory_usage', $ProcessName.ToLower()))) -BaseValue $MemoryData['Memory Total Bytes'] -Minimum 0 -Maximum $MemoryData['Memory Total Bytes'];
        $MemoryCheck.WarnOutOfRange($TotalMemoryWarning).CritOutOfRange($TotalMemoryCritical) | Out-Null;
        $ProcessSummary.AddCheck($MemoryCheck);

        $CPUCheck = New-IcingaCheck -Name 'CPU Usage' -Value $entry.Value.Total.CpuUsage -Unit '%' -MetricIndex $ProcessName -MetricName 'cpu' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_cpu_usage', $ProcessName.ToLower())));
        $CPUCheck.WarnOutOfRange($TotalCPUWarning).CritOutOfRange($TotalCPUCritical) | Out-Null;
        $ProcessSummary.AddCheck($CPUCheck);

        $ThreadCheck = New-IcingaCheck -Name 'Thread Count' -Value $entry.Value.Total.ThreadCount -Unit 'c' -MetricIndex $ProcessName -MetricName 'threads' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_thread_count', $ProcessName.ToLower())));
        $ThreadCheck.WarnOutOfRange($TotalThreadCountWarning).CritOutOfRange($TotalThreadCountCritical) | Out-Null;
        $ProcessSummary.AddCheck($ThreadCheck);

        $ProcessCheck = New-IcingaCheck -Name 'Process Count' -Value $entry.Value.Total.ProcessCount -Unit 'c' -MetricIndex $processName -MetricName 'count' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_process_count', $processName.ToLower())));
        $ProcessCheck.WarnOutOfRange($TotalProcessCountWarning).CritOutOfRange($TotalProcessCountCritical) | Out-Null;
        $ProcessSummary.AddCheck($ProcessCheck);

        $ProcessPackage.AddCheck($ProcessSummary);

        $ProcessOverviewPackage.AddCheck($ProcessPackage);
    }

    return (New-IcingaCheckResult -Check $ProcessOverviewPackage -NoPerfData $NoPerfData -Compile);
}
