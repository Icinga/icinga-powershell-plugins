
# Invoke-IcingaCheckService

## Description

Checks if a service has a specified status.

Invoke-icingaCheckService returns either 'OK' or 'CRITICAL', if a service status is matching status to be checked.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Service | Array | false |  | Used to specify an array of services which should be checked against the status. Seperated with ',' |
| Status | String | false | Running | Status for the specified service or services to check against. |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status '1' -Verbose 3
```

### Example Output 1

```powershell
[CRITICAL]: Check package "Services" is [CRITICAL] (Match All) \_ [OK]: Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)" is Stopped \_ [CRITICAL]: Service "Druckwarteschlange (Spooler)" Running is not matching Stopped
```
