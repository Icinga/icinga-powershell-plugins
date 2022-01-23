
# Invoke-IcingaCheckDirectory

## Description

Checks for amount of files within a directory depending on the set filters

Invoke-IcingaCheckDirectory will check within a specific directory for files matching the set filter criteria.
It allows to filter for files with a specific size, modification date, name or file ending.
By using the Warning or Critical threshold you can then set on when the check will be set to 'WARNING' or 'CRITICAL'.

Based on the provided filters, the plugin will return the amount of files found matching those filters.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Path | String | false |  | Used to specify a path. e.g. 'C:\Users\Icinga\Downloads' |
| FileNames | Array | false | @( '*' ) | Used to specify an array of filenames or expressions to match against results to filter for specific files.  e.g '*.txt', '*.sql', finds all files ending with .txt and .sql |
| Recurse | SwitchParameter | false | False | A switch, which can be set to search through directories recursively. |
| Critical | Object | false |  | Checks the resulting file count of the provided filters and input and returns critical for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| Warning | Object | false |  | Checks the resulting file count of the provided filters and input and returns warning for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| WarningTotalSize | Object | false |  | Checks the total folder size of all files of the provided filters and input and returns warning for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| CriticalTotalSize | Object | false |  | Checks the total folder size of all files of the provided filters and input and returns critical for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| WarningSmallestFile | Object | false |  | Checks the smallest file size found for the given filters and input and returns warning for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| CriticalSmallestFile | Object | false |  | Checks the smallest file size found for the given filters and input and returns critical for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| WarningLargestFile | Object | false |  | Checks the largest file size found for the given filters and input and returns warning for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| CriticalLargestFile | Object | false |  | Checks the largest file size found for the given filters and input and returns critical for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| WarningAverageFile | Object | false |  | Checks the average file size found for the given filters and input and returns warning for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| CriticalAverageFile | Object | false |  | Checks the average file size found for the given filters and input and returns critical for the provided threshold.  Follows the Icinga plugin threshold guidelines. |
| CountFolderAsFile | SwitchParameter | false | False | Will add the count of folders on top of the file count, allowing to include it within the threshold check. |
| ShowFileList | SwitchParameter | false | False | Allows to add the file list to the plugin output. Beware that this will cause your database to grow and performance might be slower on huge directories! |
| ChangeTimeEqual | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have been changed 20 days ago are considered within the check. |
| ChangeYoungerThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a change date younger then 20 days are considered within the check. |
| ChangeOlderThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a change date older then 20 days are considered within the check. |
| CreationTimeEqual | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have been created 20 days ago are considered within the check. |
| CreationOlderThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a creation date older then 20 days are considered within the check. |
| CreationYoungerThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a creation date younger then 20 days are considered within the check. |
| FileSizeGreaterThan | String | false |  | String that expects input format like "20MB", which translates to the filze size 20 MB. Allowed units: B, KB, MB, GB, TB.  Thereby all files with a size of 20 MB or larger are considered within the check. |
| FileSizeSmallerThan | String | false |  | String that expects input format like "5MB", which translates to the filze size 5 MB. Allowed units: B, KB, MB, GB, TB.  Thereby all files with a size of 5 MB or less are considered within the check. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3;
```

### Example Output 1

```powershell
[CRITICAL] Directory Check: "C:\Users\Icinga\Downloads": 1 Critical 5 Ok [CRITICAL] File Count (33) (All must be [OK])\_ [OK] Average File Size: 76.94MiB\_ [CRITICAL] File Count: 33 is greater than threshold 30\_ [OK] Folder Count: 1\_ [OK] Largest File Size: 1.07GiB\_ [OK] Smallest File Size: 0B\_ [OK] Total Size: 2.48GiB| 'average_file_size'=80677000B;; 'folder_count'=1;; 'total_size'=2662341000B;; 'largest_file_size'=1149023000B;; 'file_count'=33;20;30 'smallest_file_size'=0B;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThan 5d;
```

### Example Output 2

```powershell
[WARNING] Directory Check: "C:\Users\Icinga\Downloads": 1 Warning 5 Ok [WARNING] File Count (22) (All must be [OK])\_ [OK] Average File Size: 738.29KiB\_ [WARNING] File Count: 22 is greater than threshold 20\_ [OK] Folder Count: 0\_ [OK] Largest File Size: 4.23MiB\_ [OK] Smallest File Size: 0B\_ [OK] Total Size: 15.86MiB| 'average_file_size'=756008B;; 'folder_count'=0;; 'total_size'=16632180B;; 'largest_file_size'=4439043B;; 'file_count'=22;20;30 'smallest_file_size'=0B;;
```

### Example Command 3

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeOlderThan 10d;
```

### Example Output 3

```powershell
[OK] Directory Check: "C:\Users\Icinga\Downloads": 6 Ok (All must be [OK])\_ [OK] Average File Size: 359.40MiB\_ [OK] File Count: 7\_ [OK] Folder Count: 1\_ [OK] Largest File Size: 1.07GiB\_ [OK] Smallest File Size: 0B\_ [OK] Total Size: 2.46GiB| 'average_file_size'=376853700B;; 'folder_count'=1;; 'total_size'=2637976000B;; 'largest_file_size'=1149023000B;; 'file_count'=7;20;30 'smallest_file_size'=0B;;
```

### Example Command 4

```powershell
Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3 -FileNames '*.exe', '*.zip';
```

### Example Output 4

```powershell
[OK] Directory Check: "C:\Users\Icinga\Downloads": 6 Ok (All must be [OK])\_ [OK] Average File Size: 210.57MiB\_ [OK] File Count: 12\_ [OK] Folder Count: 0\_ [OK] Largest File Size: 1.07GiB\_ [OK] Smallest File Size: 0B\_ [OK] Total Size: 2.47GiB| 'average_file_size'=220801200B;; 'folder_count'=0;; 'total_size'=2649615000B;; 'largest_file_size'=1149023000B;; 'file_count'=12;20;30 'smallest_file_size'=0B;;
```

### Example Command 5

```powershell
Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -WarningTotalSize '2GiB';
```

### Example Output 5

```powershell
[CRITICAL] Directory Check: "C:\Users\Icinga\Downloads": 1 Critical 1 Warning 4 Ok [CRITICAL] File Count (33) [WARNING] Total Size (2.48GiB)\_ [CRITICAL] File Count: 33 is greater than threshold 30\_ [WARNING] Total Size: 2.48GiB is greater than threshold 2.00GiB| 'average_file_size'=80677000B;; 'folder_count'=1;; 'total_size'=2662341000B;2147484000; 'largest_file_size'=1149023000B;; 'file_count'=33;20;30 'smallest_file_size'=0B;;
```
