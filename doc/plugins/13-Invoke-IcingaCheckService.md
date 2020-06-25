
# Invoke-IcingaCheckService

## Description

Checks if a service has a specified status.

Invoke-icingaCheckService returns either 'OK' or 'CRITICAL', if a service status is matching status to be checked.
If no specific services are configured to check for, the plugin will lookup all services which are configured to
run automatically on the Windows startup and report an error in case the service is not running and was not
terminated properly.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Service | Array | false |  | Used to specify an array of services which should be checked against the status. Supports '*' for wildcards. Seperated with ',' |
| Exclude | Array | false | @() | Allows to exclude services which might come in handy for checking services which are configured to start automatically on Windows but are not running and werent exited properly. Seperated with ',' |
| Status | String | false | Running | Status for the specified service or services to check against. |
| Verbosity | Int32 | false | 0 |  |
| NoPerfData | SwitchParameter | false | False |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckService
```

### Example Output 1

```powershell
[OK] Check package "Services"
```

### Example Command 2

```powershell
Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status 'Running' -Verbose 3
```

### Example Output 2

```powershell
[CRITICAL]: Check package "Services" is [CRITICAL] (Match All) \_ [OK]: Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)" is Stopped \_ [CRITICAL]: Service "Druckwarteschlange (Spooler)" Running is not matching Stopped
```

### Example Command 3

```powershell
Invoke-IcingaCheckService -Exclude icinga2
```

### Example Output 3

```powershell
[OK] Check package "Services"
```

### Example Command 4

```powershell
Invoke-IcingaCheckService -Service '*csv*'
```

### Example Output 4

```powershell
[CRITICAL] Check package "Services" - [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)", Service "Windows Update Medic Service (WaaSMedicSvc)", Service "Windows-Ereignissammlung (Wecsvc)" \_ [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)": Value "Stopped" is not matching threshold "Running" \_ [CRITICAL] Service "Windows Update Medic Service (WaaSMedicSvc)": Value "Stopped" is not matching threshold "Running" \_ [CRITICAL] Service "Windows-Ereignissammlung (Wecsvc)": Value "Stopped" is not matching threshold "Running"
```
