
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
| Critical | Object | false |  | Used to specify a Critical threshold. Follows the Icinga plugin threshold |
| Warning | Object | false |  | Used to specify a Warning threshold. Follows the Icinga plugin threshold |
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
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
```

### Example Output 1

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 19
```

### Example Command 2

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
```

### Example Output 2

```powershell
[WARNING]: Check package "C:\Users\Icinga\Downloads" is [WARNING] (Match All) \_ [WARNING]: C:\Users\Icinga\Downloads is 24
```

### Example Command 3

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThan 20d
```

### Example Output 3

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 1
```

### Example Command 4

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeOlderThan 100d
```

### Example Output 4

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 19
```

### Example Command 5

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -FileNames "*.txt","*.sql" -Warning 20 -Critical 30 -Verbosity 3
```

### Example Output 5

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 4
```
