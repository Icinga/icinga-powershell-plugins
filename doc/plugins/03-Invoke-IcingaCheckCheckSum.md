# Invoke-IcingaCheckCheckSum

## Description

Checks hash against file hash of a file

Invoke-IcingaCheckCheckSum returns either 'OK' or 'CRITICAL', whether the check matches or not.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Path | String | false |  |  |
| Algorithm | String | false | SHA256 | Used to specify a string, which contains the algorithm to be used.  Allowed algorithms: 'SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5' |
| Hash | String | false |  |  |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt"
```

### Example Output 1

```powershell
[OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B    
```

### Example Command 2

```powershell
Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B
```

### Example Output 2

```powershell
[OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B|    
```

### Example Command 3

```powershell
Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D
```

### Example Output 3

```powershell
[CRITICAL] CheckSum C:\Users\Icinga\Downloads\test.txt 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B is not matching 008FB84A017F5DFDAF038DB2FDD6934E6E5D    
```


