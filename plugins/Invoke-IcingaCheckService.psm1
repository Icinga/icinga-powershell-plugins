<#
.SYNOPSIS
   Checks if a service has a specified status.
.DESCRIPTION
   Invoke-icingaCheckService returns either 'OK' or 'CRITICAL', if a service status is matching status to be checked.
   If no specific services are configured to check for, the plugin will lookup all services which are configured to
   run automatically on the Windows startup and report an error in case the service is not running and was not
   terminated properly.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check whether one or more services have a certain status. 
   As soon as one of the specified services does not match the status, the function returns 'CRITICAL' instead of 'OK'.
.EXAMPLE
   PS>Invoke-IcingaCheckService
   [OK] Check package "Services"
.EXAMPLE
   PS>Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status 'Running' -Verbose 3
   [CRITICAL]: Check package "Services" is [CRITICAL] (Match All)
    \_ [OK]: Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)" is Stopped
    \_ [CRITICAL]: Service "Druckwarteschlange (Spooler)" Running is not matching Stopped
.EXAMPLE
   PS>Invoke-IcingaCheckService -Exclude icinga2
   [OK] Check package "Services"
.EXAMPLE
   PS>Invoke-IcingaCheckService -Service '*csv*'
   [CRITICAL] Check package "Services" - [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)", Service "Windows Update Medic Service (WaaSMedicSvc)", Service "Windows-Ereignissammlung (Wecsvc)"
    \_ [CRITICAL] Service "Volumetric Audio Compositor-Dienst (VacSvc)": Value "Stopped" is not matching threshold "Running"
    \_ [CRITICAL] Service "Windows Update Medic Service (WaaSMedicSvc)": Value "Stopped" is not matching threshold "Running"
    \_ [CRITICAL] Service "Windows-Ereignissammlung (Wecsvc)": Value "Stopped" is not matching threshold "Running"
.PARAMETER Service
   Used to specify an array of services which should be checked against the status. Supports '*' for
   wildcards. Seperated with ','
.PARAMETER Exclude
   Allows to exclude services which might come in handy for checking services which are configured to start automatically
   on Windows but are not running and werent exited properly.
   Seperated with ','
.PARAMETER Status
   Status for the specified service or services to check against.
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
   param(
      [array]$Service,
      [array]$Exclude     = @(),
      [ValidateSet('Stopped', 'StartPending', 'StopPending', 'Running', 'ContinuePending', 'PausePending', 'Paused')]
      [string]$Status     = 'Running',
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0,
      [switch]$NoPerfData
   );

   $ServicesPackage      = New-IcingaCheckPackage -Name 'Services' -OperatorAnd -Verbose $Verbosity;
   $ServicesCountPackage = New-IcingaCheckPackage -Name 'Count Services' -OperatorAnd -Verbose $Verbosity -Hidden;
   $FetchedServices      = @{};
   [int]$StoppedCount,[int]$StartPendingCount,[int]$StopPendingCount,[int]$RunningCount,[int]$ContinuePendingCount,[int]$PausePendingCount,[int]$PausedCount,[int]$ServicesCounted = 0

   # Automatic load auto start services and check for errors in case no service
   # to check for is configured
   if ($Service.Count -eq 0) {
      $AutoServices = Get-IcingaServices -Exclude $Exclude;
      foreach ($autoservice in $AutoServices.Values) {
         if ($autoservice.configuration.ExitCode -eq 0) {
            continue;
         }
         if ($autoservice.configuration.StartType.Raw -ne $ProviderEnums.ServiceStartupType.Automatic) {
            continue;
         }
         if ($autoservice.configuration.Status.Raw -eq $ProviderEnums.ServiceStatus.Running) {
            continue;
         }

         $FetchedServices.Add(
            $autoservice.metadata.ServiceName,
            $autoservice
         );
      }
   } else {
      $FetchedServices = Get-IcingaServices -Service $Service -Exclude $Exclude;
   }

   foreach ($services in $FetchedServices.Keys) {
      $services = $FetchedServices[$services];
      $IcingaCheck = $null;

      $ServiceName     = Get-IcingaServiceCheckName -ServiceInput $services.metadata.DisplayName -Service $services;
      $ConvertedStatus = ConvertTo-ServiceStatusCode -Status $Status;
      $StatusRaw       = $services.configuration.Status.raw;

      $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $services -Translation $ProviderEnums.ServiceStatusName;
      $IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;
      $ServicesPackage.AddCheck($IcingaCheck)

      switch($StatusRaw) {
         {1 -contains $_} { $StoppedCount++;         $ServicesCounted++}
         {2 -contains $_} { $StartPendingCount++;    $ServicesCounted++}
         {3 -contains $_} { $StopPendingCount++;     $ServicesCounted++}
         {4 -contains $_} { $RunningCount++;         $ServicesCounted++}
         {5 -contains $_} { $ContinuePendingCount++; $ServicesCounted++}
         {6 -contains $_} { $PausePendingCount++;    $ServicesCounted++}
         {7 -contains $_} { $PausedCount++;          $ServicesCounted++}
      }
   }

   $IcingaStopped         = New-IcingaCheck -Name 'stopped services'           -Value $StoppedCount;
   $IcingaStartPending    = New-IcingaCheck -Name 'pending started services'   -Value $StartPendingCount;
   $IcingaStopPending     = New-IcingaCheck -Name 'pending stopped services'   -Value $StopPendingCount;
   $IcingaRunning         = New-IcingaCheck -Name 'running services'           -Value $RunningCount;
   $IcingaContinuePending = New-IcingaCheck -Name 'pending continued services' -Value $ContinuePendingCount;
   $IcingaPausePending    = New-IcingaCheck -Name 'pending paused services'    -Value $PausePendingCount;
   $IcingaPaused          = New-IcingaCheck -Name 'paused services'            -Value $PausePendingCount;

   $IcingaCount           = New-IcingaCheck -Name 'service count'              -Value $ServicesCounted;

   $ServicesCountPackage.AddCheck($IcingaStopped)
   $ServicesCountPackage.AddCheck($IcingaStartPending)
   $ServicesCountPackage.AddCheck($IcingaStopPending)
   $ServicesCountPackage.AddCheck($IcingaRunning)
   $ServicesCountPackage.AddCheck($IcingaContinuePending)
   $ServicesCountPackage.AddCheck($IcingaPausePending)
   $ServicesCountPackage.AddCheck($IcingaPaused)

   $ServicesCountPackage.AddCheck($IcingaCount)
   $ServicesPackage.AddCheck($ServicesCountPackage)

   return (New-IcingaCheckResult -Name 'Services' -Check $ServicesPackage -NoPerfData $NoPerfData -Compile);
}
