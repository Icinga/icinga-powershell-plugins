<#
.SYNOPSIS
    Checks if defined services have a specific status or checks for all automatic services and if they are running
    and have not been terminated with exit code 0
.DESCRIPTION
    Invoke-IcingaCheckService can be used to check the state of specified services against a user definable threshold.
    In addition the plugin can be used to check for all services which are configured to run automatically on Windows
    startup by not defining a specific service during plugin call. In this case the plugin will return 'CRITICAL'
    for services which are set to `Automatic` and not running, but only if the service ExitCode is not 0.

    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check whether one or more services have a certain status.
    As soon as one of the specified services does not match the status, the function returns 'CRITICAL' instead of 'OK'.
.ROLE
    ### WMI Permissions

    * Root\Cimv2
.EXAMPLE
    PS> Invoke-IcingaCheckService
    [OK] Check package "Services"
    | 'pending_paused_services'=0;; 'running_services'=80;; 'pending_continued_services'=0;; 'stopped_services'=5;; 'pending_started_services'=0;; 'service_count'=85;; 'pending_stopped_services'=0;; 'paused_services'=0;;
.EXAMPLE
    PS> Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status 'Running' -Verbosity 2
    [CRITICAL] Check package "Services" (Match All) - [CRITICAL] Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)"
    \_ [OK] Service "Druckwarteschlange (Spooler)": Running
    \_ [CRITICAL] Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)": Value "Stopped" is not matching threshold "Running"
    | 'pending_paused_services'=0;; 'running_services'=1;; 'pending_continued_services'=0;; 'stopped_services'=1;; 'pending_started_services'=0;; 'service_count'=2;; 'pending_stopped_services'=0;; 'paused_services'=0;; 'service_druckwarteschlange_spooler'=4;;4 'service_ereignisse_zum_abrufen_von_standbildern_wiarpc'=1;;4
.EXAMPLE
    PS>Invoke-IcingaCheckService -Exclude icinga2
    [OK] Check package "Services"
    | 'pending_paused_services'=0;; 'running_services'=80;; 'pending_continued_services'=0;; 'stopped_services'=5;; 'pending_started_services'=0;; 'service_count'=85;; 'pending_stopped_services'=0;; 'paused_services'=0;;
.EXAMPLE
    PS>Invoke-IcingaCheckService -Service '*csv*'
    [CRITICAL] Check package "Services" - [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)", Service "Windows-Ereignissammlung (Wecsvc)", Service "Windows-Sofortverbindung - Konfigurationsregistrierungsstelle (wcncsvc)"
    \_ [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)": Value "Stopped" is not matching threshold "Running"
    \_ [CRITICAL] Service "Windows-Ereignissammlung (Wecsvc)": Value "Stopped" is not matching threshold "Running"
    \_ [CRITICAL] Service "Windows-Sofortverbindung - Konfigurationsregistrierungsstelle (wcncsvc)": Value "Stopped" is not matching threshold "Running"
    | 'pending_paused_services'=0;; 'running_services'=4;; 'pending_continued_services'=0;; 'stopped_services'=3;; 'pending_started_services'=0;; 'service_count'=7;; 'pending_stopped_services'=0;; 'paused_services'=0;; 'service_sicherheitscenter_wscsvc'=4;;4 'service_volumetric_audio_compositordienst_vacsvc'=1;;4 'service_windowsereignissammlung_wecsvc'=1;;4 'service_synchronisierungshost_2c66e0_onesyncsvc_2c66e0'=4;;4 'service_windowssofortverbindung_konfigurationsregistrierungsstelle_wcncsvc'=1;;4 'service_windows_update_medic_service_waasmedicsvc'=4;;4 'service_microsoft_passport_ngcsvc'=4;;4
.PARAMETER Service
    Used to specify an array of services which should be checked against the status. Supports '*' for
    wildcards.
.PARAMETER Exclude
    Allows to exclude services which might come in handy for checking services which are configured to start automatically
    on Windows but are not running and weren't exited properly.
.PARAMETER Status
    Status for the specified service or services to check against.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckService()
{
    param (
        [array]$Service     = @(),
        [array]$Exclude     = @(),
        [ValidateSet('Stopped', 'StartPending', 'StopPending', 'Running', 'ContinuePending', 'PausePending', 'Paused')]
        [string]$Status     = 'Running',
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0,
        [switch]$NoPerfData
    );

    $ServicesPackage       = New-IcingaCheckPackage -Name 'Services' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $ServicesCountPackage  = New-IcingaCheckPackage -Name 'Count Services' -OperatorAnd -Verbose $Verbosity -Hidden;
    $FetchedServices       = @{};
    $ServiceSummary        = $null;

    # Automatic load auto start services and check for errors in case no service
    # to check for is configured
    if ($Service.Count -eq 0) {
        $AutoServices = Get-IcingaServices -Exclude $Exclude;
        foreach ($autoservice in $AutoServices.Values) {

            # Skip services which are not defined to run automatically
            if ($autoservice.configuration.StartType.Raw -ne $ProviderEnums.ServiceStartupType.Automatic) {
                continue;
            }

            $ServiceSummary = Add-IcingaServiceSummary -ServiceStatus $autoservice.configuration.Status.Raw -ServiceData $ServiceSummary;

            # Check if the service is running
            if ($autoservice.configuration.Status.Raw -eq $ProviderEnums.ServiceStatus.Running) {
                $ServicesPackage.AddCheck(
                    (New-IcingaWindowsServiceCheckObject -Status 'Running' -Service $autoservice -NoPerfData)
                );
                continue;
            }

            # Service is not running but the ExitCode is 0 -> this is fine and should not raise a critical
            if ($autoservice.configuration.ExitCode -eq 0) {
                $ServicesPackage.AddCheck(
                    (New-IcingaWindowsServiceCheckObject -Status 'Stopped' -Service $autoservice -NoPerfData)
                );
                continue;
            }

            # Services which should be running, but are not
            $ServicesPackage.AddCheck(
                (New-IcingaWindowsServiceCheckObject -Status 'Running' -Service $autoservice -NoPerfData)
            );
        }
    } else {
        $FetchedServices = Get-IcingaServices -Service $Service -Exclude $Exclude;
        foreach ($services in $FetchedServices.Values) {
            $ServicesPackage.AddCheck(
                (New-IcingaWindowsServiceCheckObject -Status $Status -Service $services)
            );

            $ServiceSummary = Add-IcingaServiceSummary -ServiceStatus $StatusRaw -ServiceData $ServiceSummary;
        }
    }

    # Check our included services and add an unknown state for each service which was not found on the system
    foreach ($ServiceArg in $Service) {
        if ($null -eq $FetchedServices -Or $FetchedServices.ContainsKey($ServiceArg) -eq $FALSE) {
            if ($ServiceArg.Contains('*')) {
                continue;
            }
            $ServicesPackage.AddCheck(
                (New-IcingaCheck -Name ([string]::Format('{0}: Service not found', $ServiceArg))).SetUnknown()
            );
        }
    }

    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'stopped services' -Value $ServiceSummary.StoppedCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'pending started services' -Value $ServiceSummary.StartPendingCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'pending stopped services' -Value $ServiceSummary.StopPendingCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'running services' -Value $ServiceSummary.RunningCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'pending continued services' -Value $ServiceSummary.ContinuePendingCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'pending paused services' -Value $ServiceSummary.PausePendingCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'paused services' -Value $ServiceSummary.PausedCount)
    );
    $ServicesCountPackage.AddCheck(
        (New-IcingaCheck -Name 'service count' -Value $ServiceSummary.ServicesCounted)
    );

    $ServicesPackage.AddCheck($ServicesCountPackage)

    return (New-IcingaCheckResult -Name 'Services' -Check $ServicesPackage -NoPerfData $NoPerfData -Compile);
}
