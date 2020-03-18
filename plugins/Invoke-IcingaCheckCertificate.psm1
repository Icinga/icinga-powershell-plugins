<#
.SYNOPSIS
   Check whether a certificate is still trusted and when it runs out or starts.
.DESCRIPTION
   Invoke-IcingaCheckCertificate returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g a certificate will run out in 30 days, WARNING is set to '20d:', CRITICAL is set to '50d:'. In this case the check will return 'WARNING'.
   
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check if a certificate is still valid or about to become valid.
.EXAMPLE
   PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*' -WarningEnd '30d:' -CriticalEnd '10d:' -Verbosity 3
   [OK] Check package "Certificates" (Match All)
   \_ [OK] Check package "Certificate End" (Match All)
      \_ [OK] Certificate CN=Cloudbase-Init WinRM(ACACBAC2A29ADC68D710C715DA20B036407BA3A8): 313784201.23
.EXAMPLE
   PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*'-CertPaths "C:\ProgramData\icinga2\var\lib\icinga2\certs" -CertName '*.crt' -WarningEnd '10000d:' -Verbosity 3
   [WARNING] Check package "Certificates" (Match All) - [WARNING] Certificate test-server(AD647B1AC4EF5B91F7261A7EE517C418844D7756), Certificate Cloudbase-Init WinRM(ACACBAC2A29ADC68D710C715DA20B036407BA3A8)
   \_ [WARNING] Check package "Certificate End" (Match All)
   \_ [WARNING] Certificate test-server(AD147B1AC4EF5B91F7261A7EE517C418844D7756): Value "471323842.25" is between threshold "0:864000000"
   \_ [WARNING] Certificate Cloudbase-Init WinRM(ACACBAC1A29ADC68D710C715DA20B036407BA3A8): Value "313538391.82" is between threshold "0:864000000"
.EXAMPLE
   PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*'-CertPaths "C:\ProgramData\icinga2\var\lib\icinga2\certs" -CertName '*.crt' -Verbosity 3 -Trusted
   [CRITICAL] Check package "Certificates" (Match All) - [CRITICAL] Certificate test-server(AD647B1AC4EF5B91F7261A7EE517C418844D7756), Certificate Cloudbase-Init WinRM(ACACBAC2A29ADC68D710C715DA20B036407BA3A8)
   \_ [CRITICAL] Certificate test-server(AD647B1AC4EF5B91F7261A7EE517C418844D7756): Value "False" is not matching threshold "True"
   \_ [CRITICAL] Certificate Cloudbase-Init WinRM(ACACBAC2A29ADC68D710C715DA20B036407BA3A8): Value "False" is not matching threshold "True"

.PARAMETER Trusted
   Used to switch on trusted behavior. Whether to check, If the certificate is trusted by the system root.
   Will return Critical in case of untrust.

.PARAMETER CriticalStart
   Used to specify a date. The start date of the certificate has to be past the date specified, otherwise the check results in critical. Use carefully.
   Use format like: 'yyyy-MM-dd'
   
.PARAMETER WarningEnd
   Used to specify a Warning range for the end date of an certificate. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y

.PARAMETER CriticalEnd
   Used to specify a Critical range for the end date of an certificate. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y
   
.PARAMETER CertStore
   Used to specify which CertStore to check. Valid choices are '*', 'LocalMachine', 'CurrentUser', ''
   
 .PARAMETER CertThumbprint
   Used to specify an array of Thumbprints, which are used to determine what certificate to check, within the CertStore.

.PARAMETER CertSubject
   Used to specify an array of Subjects, which are used to determine what certificate to check, within the CertStore.
   
.PARAMETER CertStorePath
   Used to specify which path within the CertStore should be checked.
   
.PARAMETER CertPaths
   Used to specify an array of paths on your system, where certificate files are. Use with CertName.
   
.PARAMETER CertName
   Used to specify an array of certificate names of certificate files to check. Use with CertPaths.
   
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckCertificate()
{
   param(
      #Checking
      [switch]$Trusted,
      $CriticalStart         = $null,
      $WarningEnd            = '30d:',
      $CriticalEnd           = '10d:',
      #CertStore-Related Param
      [ValidateSet('*', 'LocalMachine', 'CurrentUser', $null)]
      [string]$CertStore     = $null,
      [array]$CertThumbprint = $null,
      [array]$CertSubject    = $null,
      $CertStorePath         = '*',
      #Local Certs
      [array]$CertPaths      = $null,
      [array]$CertName       = $null,
      #Other
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity        = 3
   );

   $CertData         = (Get-IcingaCertificateData -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertPaths $CertPaths -CertName $CertName -CertStorePath $CertStorePath);
   $CertPackage      = New-IcingaCheckPackage -Name 'Certificates' -OperatorAnd -Verbose $Verbosity;

   if ($null -ne $CriticalStart) {
      try {
         [datetime]$CritDateTime = $CriticalStart
      } catch {
         Write-Host "[UNKNOWN] CriticalStart ${CriticalStart} can not be parsed!"
         return 3
      }
   }

   foreach ($Subject in $CertData.Keys) {
      $Thumbprints = $CertData[$Subject];
      foreach ($cert in $Thumbprints.Keys) {
         $cert = $Thumbprints[$cert];

         $SpanTilAfter = (New-TimeSpan -Start (Get-Date) -End $Cert.NotAfter);
         if ($Cert.Subject.Contains(',')) {
            [string]$CertName = $Cert.Subject.Split(",")[0];
         } else {
            [string]$CertName = $Cert.Subject;
         }

         $CertName = $CertName -ireplace '(cn|ou)=', '';
         $CheckNamePrefix = "Certificate '${CertName}'";

         $checks = @();

         if ($Trusted) {
            $CertValid = Test-Certificate $cert -ErrorAction SilentlyContinue -WarningAction SilentlyContinue;

            $IcingaCheck = New-IcingaCheck -Name "${CheckNamePrefix} trusted" -Value $CertValid;
            $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
            $checks += $IcingaCheck;
         }

         if ($null -ne $CriticalStart) {
            $CritStart = ((New-TimeSpan -Start $Cert.NotBefore -End $CritDateTime) -gt 0)
            $IcingaCheck = New-IcingaCheck -Name "${CheckNamePrefix} already valid" -Value $CritStart;
            $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
            $checks += $IcingaCheck;
         }

         if(($null -ne $WarningEnd) -Or ($null -ne $CriticalEnd)) {
            $ValidityInfo = ([string]::Format('valid until {0} : {1}d', $Cert.NotAfter.ToString('yyyy-MM-dd'), $SpanTilAfter.Days));

            $IcingaCheck = New-IcingaCheck -Name "${CheckNamePrefix} ($ValidityInfo) valid for" -Value (New-TimeSpan -End $Cert.NotAfter.DateTime).TotalSeconds;
            $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningEnd)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalEnd)) | Out-Null;
            $checks += $IcingaCheck;
         }

         if ($checks.Length -eq 1) {
            # Only add one check instead of the package
            # TODO: this should be a feature of the framework (collapsing packages)
            $CertPackage.AddCheck($checks[0])
         } else {
            $CertCheck = New-IcingaCheckPackage -Name $CheckNamePrefix -OperatorAnd;
            foreach ($check in $checks) {
               $CertCheck.AddCheck($check)
            }
            $CertPackage.AddCheck($CertCheck)
         }
      }
   }

   return (New-IcingaCheckResult -Name 'Certificates' -Check $CertPackage -NoPerfData $TRUE -Compile);
}
