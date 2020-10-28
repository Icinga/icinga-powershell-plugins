
# Invoke-IcingaCheckService

## Description

Checks if defined services have a specific status or checks for all automatic services and if they are running
and have not been terminated with exit code 0

Invoke-IcingaCheckService can be used to check the state of specified services against a user definable threshold.
In addition the plugin can be used to check for all services which are configured to run automatically on Windows
startup by not defining a specific service during plugin call. In this case the plugin will return 'CRITICAL'
for services which are set to `Automatic` and not running, but only if the service ExitCode is not 0.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Cimv2

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Service | Array | false |  | Used to specify an array of services which should be checked against the status. Supports '*' for wildcards. |
| Exclude | Array | false | @() | Allows to exclude services which might come in handy for checking services which are configured to start automatically on Windows but are not running and weren't exited properly. |
| Status | String | false | Running | Status for the specified service or services to check against. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckService
```

### Example Output 1

```powershell
[OK] Check package "Services"| 'pending_paused_services'=0;; 'running_services'=80;; 'pending_continued_services'=0;; 'stopped_services'=5;; 'pending_started_services'=0;; 'service_count'=85;; 'pending_stopped_services'=0;; 'paused_services'=0;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status 'Running' -Verbosity 2
```

### Example Output 2

```powershell
[CRITICAL] Check package "Services" (Match All) - [CRITICAL] Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)"\_ [OK] Service "Druckwarteschlange (Spooler)": Running\_ [CRITICAL] Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)": Value "Stopped" is not matching threshold "Running"| 'pending_paused_services'=0;; 'running_services'=1;; 'pending_continued_services'=0;; 'stopped_services'=1;; 'pending_started_services'=0;; 'service_count'=2;; 'pending_stopped_services'=0;; 'paused_services'=0;; 'service_druckwarteschlange_spooler'=4;;4 'service_ereignisse_zum_abrufen_von_standbildern_wiarpc'=1;;4
```

### Example Command 3

```powershell
Invoke-IcingaCheckService -Exclude icinga2
```

### Example Output 3

```powershell
[OK] Check package "Services"| 'pending_paused_services'=0;; 'running_services'=80;; 'pending_continued_services'=0;; 'stopped_services'=5;; 'pending_started_services'=0;; 'service_count'=85;; 'pending_stopped_services'=0;; 'paused_services'=0;;
```

### Example Command 4

```powershell
Invoke-IcingaCheckService -Service '*csv*'
```

### Example Output 4

```powershell
[CRITICAL] Check package "Services" - [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)", Service "Windows-Ereignissammlung (Wecsvc)", Service "Windows-Sofortverbindung - Konfigurationsregistrierungsstelle (wcncsvc)"\_ [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)": Value "Stopped" is not matching threshold "Running"\_ [CRITICAL] Service "Windows-Ereignissammlung (Wecsvc)": Value "Stopped" is not matching threshold "Running"\_ [CRITICAL] Service "Windows-Sofortverbindung - Konfigurationsregistrierungsstelle (wcncsvc)": Value "Stopped" is not matching threshold "Running"| 'pending_paused_services'=0;; 'running_services'=4;; 'pending_continued_services'=0;; 'stopped_services'=3;; 'pending_started_services'=0;; 'service_count'=7;; 'pending_stopped_services'=0;; 'paused_services'=0;; 'service_sicherheitscenter_wscsvc'=4;;4 'service_volumetric_audio_compositordienst_vacsvc'=1;;4 'service_windowsereignissammlung_wecsvc'=1;;4 'service_synchronisierungshost_2c66e0_onesyncsvc_2c66e0'=4;;4 'service_windowssofortverbindung_konfigurationsregistrierungsstelle_wcncsvc'=1;;4 'service_windows_update_medic_service_waasmedicsvc'=4;;4 'service_microsoft_passport_ngcsvc'=4;;4
```
