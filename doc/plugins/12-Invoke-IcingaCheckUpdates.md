
# Invoke-IcingaCheckUpdates

## Description

Checks how many updates are to be applied

Invoke-IcingaCheckUpdates returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g 'C:\Users\Icinga\Backup' 10 updates are pending, WARNING is set to 20, CRITICAL is set to 50. In this case the check will return OK.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| UpdateFilter | Array | false |  |  |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUpdates -Warning 4 -Critical 20
```

### Example Output 1

```powershell
[OK]: Check package "Updates" is [OK]| 'Pending Update Count'=2;4;20
```
