
# Invoke-IcingaCheckUsers

## Description

Checks how many files are in a directory.

Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' contains 200 files, WARNING is set to 150, CRITICAL is set to 300. In this case the check will return CRITICAL
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Username | Array | false |  | Used to specify an array of usernames to match against.  e.g 'Administrator', 'Icinga' |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell

```

### Example Output 1

```powershell

```

### Example Command 2

```powershell

```

### Example Output 2

```powershell

```
