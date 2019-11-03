
# Invoke-IcingaCheckDirectory

## Description

Checks how many files are in a directory.

Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' contains 200 files, WARNING is set to 150, CRITICAL is set to 300. In this case the check will return CRITICAL
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Path | String | false |  | Used to specify a path. e.g. 'C:\Users\Icinga\Downloads' |
| FileNames | Array | false |  | Used to specify an array of filenames or expressions to match against.  e.g '*.txt', '*.sql' # Fiends all files ending with .txt and .sql |
| Recurse | SwitchParameter | false | False | A switch, which can be set to filter through directories recursively. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| ChangeTimeEqual | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have been changed 20 days ago are considered within the check. |
| ChangeYoungerThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a change date younger then 20 days are considered within the check. |
| ChangeOlderThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a change date older then 20 days are considered within the check. |
| CreationTimeEqual | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have been created 20 days ago are considered within the check. |
| CreationOlderThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a creation date older then 20 days are considered within the check. |
| CreationYoungerThan | String | false |  | String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.  Thereby all files which have a creation date younger then 20 days are considered within the check. |
| FileSizeGreaterThan | String | false |  |  |
| FileSizeSmallerThan | String | false |  |  |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |

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
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThen 20d -ChangeOlderThen 10d
```

### Example Output 3

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 1
```

### Example Command 4

```powershell
Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -FileNames "*.txt","*.sql" -Warning 20 -Critical 30 -Verbosity 3
```

### Example Output 4

```powershell
[OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All) \_ [OK]: C:\Users\Icinga\Downloads is 4
```
