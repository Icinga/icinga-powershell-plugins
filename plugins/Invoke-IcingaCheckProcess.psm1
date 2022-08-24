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
.PARAMETER NoPerfData
    Set this argument to not write any performance data
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'msedge';

    [OK] Process Overview: 1 Ok
    | 'msedge_process_count'=809c;; 'msedge_page_file_usage'=4611576B;;;0;9728 'msedge_cpu_usage'=5%;;;0;100 'msedge_thread_count'=809c;; 'msedge_memory_usage'=2335887000B;;;0;68636310000
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'msedge' -CPUWarning '1%' -TotalCPUWarning '5%';

    [WARNING] Process Overview: 1 Warning [WARNING] msedge
    \_ [WARNING] msedge
        \_ [WARNING] msedge [29508]
            \_ [WARNING] CPU Usage: 101.00% is greater than threshold 1%
        \_ [WARNING] msedge [55744]
            \_ [WARNING] CPU Usage: 96.00% is greater than threshold 1%
        \_ [WARNING] msedge Summary
            \_ [WARNING] CPU Usage: 197.00% is greater than threshold 5%
    | 'msedge_process_count'=946c;; 'msedge_page_file_usage'=4962844B;;;0;9728 'msedge_cpu_usage'=197%;5;;0;197 'msedge_thread_count'=946c;; 'msedge_memory_usage'=2743132000B;;;0;68636310000
.EXAMPLE
    PS> Invoke-IcingaCheckProcess -Process 'SearchIndexer' -MemoryWarning '0.1%';

    [WARNING] Process Overview: 1 Warning [WARNING] SearchIndexer
    \_ [WARNING] SearchIndexer
        \_ [WARNING] SearchIndexer [16176]
            \_ [WARNING] Memory Usage: 0.58% (382.17MiB) is greater than threshold 0.1% (65.46MiB)
    | 'searchindexer_cpu_usage'=0%;;;0;100 'searchindexer_memory_usage'=400736300B;;;0;68636310000 'searchindexer_thread_count'=44c;; 'searchindexer_page_file_usage'=605704B;;;0;9728 'searchindexer_process_count'=44c;;
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
        [switch]$NoPerfData        = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $ProcessInformation     = (Get-IcingaProcessData -Process $Process);
    $MemoryData             = Get-IcingaMemoryPerformanceCounter;
    $ProcessOverviewPackage = New-IcingaCheckPackage -Name 'Process Overview' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    foreach ($processName in $ProcessInformation.Processes.Keys) {
        $ProcessData    = $ProcessInformation.Processes[$processName];
        $ProcessPackage = New-IcingaCheckPackage -Name $processName -OperatorAnd -Verbose $Verbosity;

        foreach ($processId in $ProcessData.ProcessList.Keys) {
            $ProcessDetails          = $ProcessData.ProcessList[$processId];
            $ProcessCheckPackageName = [string]::Format('{0} [{1}]', $processName, $processId);
            $ProcessIdPackage        = New-IcingaCheckPackage -Name $ProcessCheckPackageName -OperatorAnd -Verbose $Verbosity;

            $PageFileCheck = New-IcingaCheck -Name 'Page File Usage' -Value $ProcessDetails.PageFileUsage -Unit 'B' -NoPerfData -BaseValue $MemoryData['PageFile Total Bytes'] -Minimum 0 -Maximum $MemoryData['PageFile Total Bytes'];
            $PageFileCheck.WarnOutOfRange($PageFileWarning).CritOutOfRange($PageFileCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($PageFileCheck);

            $MemoryCheck = New-IcingaCheck -Name 'Memory Usage' -Value $ProcessDetails.WorkingSetPrivate -Unit 'B' -NoPerfData -BaseValue $MemoryData['Memory Total Bytes'] -Minimum 0 -Maximum $MemoryData['Memory Total Bytes'];
            $MemoryCheck.WarnOutOfRange($MemoryWarning).CritOutOfRange($MemoryCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($MemoryCheck);

            $CPUCheck = New-IcingaCheck -Name 'CPU Usage' -Value $ProcessDetails.PercentProcessorTime -Unit '%' -NoPerfData;
            $CPUCheck.WarnOutOfRange($CPUWarning).CritOutOfRange($CPUCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($CPUCheck);

            $ThreadCheck = New-IcingaCheck -Name 'Thread Count' -Value $ProcessDetails.ThreadCount -Unit 'c' -NoPerfData;
            $ThreadCheck.WarnOutOfRange($ThreadCountWarning).CritOutOfRange($ThreadCountCritical) | Out-Null;
            $ProcessIdPackage.AddCheck($ThreadCheck);

            $ProcessPackage.AddCheck($ProcessIdPackage);
        }

        $ProcessSummary = New-IcingaCheckPackage -Name ([string]::Format('{0} Summary', $processName)) -OperatorAnd -Verbose $Verbosity;

        $PageFileCheck = New-IcingaCheck -Name 'Page File Usage' -Value $ProcessData.PerformanceData.PageFileUsage -Unit 'B' -MetricIndex $processName -MetricName 'pagefile' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_page_file_usage', $processName.ToLower()))) -BaseValue $MemoryData['PageFile Total Bytes'] -Minimum 0 -Maximum $MemoryData['PageFile Total Bytes'];
        $PageFileCheck.WarnOutOfRange($TotalPageFileWarning).CritOutOfRange($TotalPageFileCritical) | Out-Null;
        $ProcessSummary.AddCheck($PageFileCheck);

        $MemoryCheck = New-IcingaCheck -Name 'Memory Usage' -Value $ProcessData.PerformanceData.WorkingSetPrivate -Unit 'B' -MetricIndex $processName -MetricName 'memory' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_memory_usage', $processName.ToLower()))) -BaseValue $MemoryData['Memory Total Bytes'] -Minimum 0 -Maximum $MemoryData['Memory Total Bytes'];
        $MemoryCheck.WarnOutOfRange($TotalMemoryWarning).CritOutOfRange($TotalMemoryCritical) | Out-Null;
        $ProcessSummary.AddCheck($MemoryCheck);

        $CPUCheck = New-IcingaCheck -Name 'CPU Usage' -Value $ProcessData.PerformanceData.PercentProcessorTime -Unit '%' -MetricIndex $processName -MetricName 'cpu' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_cpu_usage', $processName.ToLower())));
        $CPUCheck.WarnOutOfRange($TotalCPUWarning).CritOutOfRange($TotalCPUCritical) | Out-Null;
        $ProcessSummary.AddCheck($CPUCheck);

        $ThreadCheck = New-IcingaCheck -Name 'Thread Count' -Value $ProcessData.PerformanceData.ThreadCount -Unit 'c' -MetricIndex $processName -MetricName 'threads' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_thread_count', $processName.ToLower())));
        $ThreadCheck.WarnOutOfRange($TotalThreadCountWarning).CritOutOfRange($TotalThreadCountCritical) | Out-Null;
        $ProcessSummary.AddCheck($ThreadCheck);

        $ProcessCheck = New-IcingaCheck -Name 'Process Count' -Value $ProcessData.ProcessList.Count -Unit 'c' -MetricIndex $processName -MetricName 'count' -LabelName (Format-IcingaPerfDataLabel ([string]::Format('{0}_process_count', $processName.ToLower())));
        $ProcessCheck.WarnOutOfRange($TotalProcessCountWarning).CritOutOfRange($TotalProcessCountCritical) | Out-Null;
        $ProcessSummary.AddCheck($ProcessCheck);

        $ProcessPackage.AddCheck($ProcessSummary);

        $ProcessOverviewPackage.AddCheck($ProcessPackage);
    }

    return (New-IcingaCheckResult -Check $ProcessOverviewPackage -NoPerfData $NoPerfData -Compile);
}
