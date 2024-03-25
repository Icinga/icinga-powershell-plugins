# Invoke-IcingaCheckProcess

## Description

A plugin to check thread, cpu, memory and pagefile usage for each single process

Allows to check of single process and total process resource usage. This includes
cpu, memory, pagefile, thread count and process count usage.

It is not recommended for checking the total process count of all running processes, because of performance
impact. Use the `Invoke-IcingaCheckProcessCount` plugin for this.

Checking stats and process count for a group of processes with a certain name including resources is supported
and the plugin recommended for this case.

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| PageFileWarning | Object | false |  | Compares each single process page file usage against the given threshold. Will throw warning if exceeded.<br /> Supports % unit to compare the process page file usage for the entire page file space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| PageFileCritical | Object | false |  | Compares each single process page file usage against the given threshold. Will throw critical if exceeded.<br /> Supports % unit to compare the process page file usage for the entire page file space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| MemoryWarning | Object | false |  | Compares each single process memory usage against the given threshold. Will throw warning if exceeded.<br /> Supports % unit to compare the process memory usage for the entire memory space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| MemoryCritical | Object | false |  | Compares each single process memory usage against the given threshold. Will throw critical if exceeded.<br /> Supports % unit to compare the process memory usage for the entire memory space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| CPUWarning | Object | false |  | Compares each single process cpu usage against the given threshold. Will throw warning if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| CPUCritical | Object | false |  | Compares each single process cpu usage against the given threshold. Will throw critical if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| ThreadCountWarning | Object | false |  | Compares each single process thread usage against the given threshold. Will throw warning if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| ThreadCountCritical | Object | false |  | Compares each single process thread usage against the given threshold. Will throw critical if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalPageFileWarning | Object | false |  | Compares page file usage for all processes with the same name against the given threshold. Will throw warning if exceeded.<br /> Supports % unit to compare the total process page file usage for the entire page file space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalPageFileCritical | Object | false |  | Compares page file usage for all processes with the same name against the given threshold. Will throw critical if exceeded.<br /> Supports % unit to compare the total process page file usage for the entire page file space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalMemoryWarning | Object | false |  | Compares memory usage for all processes with the same name against the given threshold. Will throw warning if exceeded.<br /> Supports % unit to compare the total process memory usage for the entire memory space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalMemoryCritical | Object | false |  | Compares memory usage for all processes with the same name against the given threshold. Will throw critical if exceeded.<br /> Supports % unit to compare the total process memory usage for the entire memory space available.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalCPUWarning | Object | false |  | Compares cpu usage for all processes with the same name against the given threshold. Will throw warning if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalCPUCritical | Object | false |  | Compares cpu usage for all processes with the same name against the given threshold. Will throw critical if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalThreadCountWarning | Object | false |  | Compares thread usage for all processes with the same name against the given threshold. Will throw warning if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalThreadCountCritical | Object | false |  | Compares thread usage for all processes with the same name against the given threshold. Will throw critical if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalProcessCountWarning | Object | false |  | Compares process count for all processes with the same name against the given threshold. Will throw warning if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| TotalProcessCountCritical | Object | false |  | Compares process count for all processes with the same name against the given threshold. Will throw critical if exceeded.<br /> <br /> Follows the Icinga Plugin threshold guidelines. |
| Process | Array | false | @() | Allows to filter for a list of processes with a given name. Use the process name without file ending, like '.exe'. |
| ExcludeProcess | Array | false | @() | Define a list of process names which are excluded from the final result. Only the process name is required without '.exe' at the end. |
| NoPerfData | SwitchParameter | false | False | Set this argument to not write any performance data |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckProcess -Process 'powershell';
```

### Example Output 1

```powershell
[OK] Process Overview: 1 Ok
| 'powershell::ifw_process::cpu'=76%;;;0;100 'powershell::ifw_process::memory'=1501471000B;;;0;6436880000 'powershell::ifw_process::pagefile'=1885120B;;;0;6979322000 'powershell::ifw_process::count'=7c;; 'powershell::ifw_process::threads'=106c;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckProcess -Process 'powershell' -CPUWarning '1%' -TotalCPUWarning '5%';
```

### Example Output 2

```powershell
[WARNING] Process Overview: 1 Warning [WARNING] powershell
\_ [WARNING] powershell
    \_ [WARNING] powershell [13436]
        \_ [WARNING] CPU Usage: 75.00% is greater than threshold 1%
    \_ [WARNING] powershell [9332]
        \_ [WARNING] CPU Usage: 98.00% is greater than threshold 1%
    \_ [WARNING] powershell Summary
        \_ [WARNING] CPU Usage: 173.00% is greater than threshold 5%
| 'powershell::ifw_process::cpu'=173%;5;;0;173 'powershell::ifw_process::memory'=1510900000B;;;0;6436880000 'powershell::ifw_process::pagefile'=1892332B;;;0;6979322000 'powershell::ifw_process::count'=7c;; 'powershell::ifw_process::threads'=112c;;    
```

### Example Command 3

```powershell
Invoke-IcingaCheckProcess -Process 'SearchIndexer' -MemoryWarning '0.1%';
```

### Example Output 3

```powershell
[WARNING] Process Overview: 1 Warning [WARNING] SearchIndexer
\_ [WARNING] SearchIndexer
    \_ [WARNING] SearchIndexer [5112]
        \_ [WARNING] Memory Usage: 0.30% (18.56MiB) is greater than threshold 0.1% (6.14MiB)
| 'searchindexer::ifw_process::count'=1c;; 'searchindexer::ifw_process::pagefile'=24156B;;;0;6979322000 'searchindexer::ifw_process::threads'=8c;; 'searchindexer::ifw_process::cpu'=0%;;;0;100 'searchindexer::ifw_process::memory'=19460100B;;;0;6436880000    
```


