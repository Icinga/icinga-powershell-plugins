<#
.SYNOPSIS
   Check whether a certificate is still trusted and when it runs out or starts.
.DESCRIPTION
   Invoke-IcingaCheckCertificate returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g a certificate will run out in 30 days, WARNING is set to @20d:50d, CRITICAL is set to @0d:50d. In this case the check will return 'WARNING'.
   
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check if a certificate is still valid or about to become valid.
.EXAMPLE
   PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*' -WarningEnd '@10d:365d' -CriticalEnd '@0d:10d' -Verbosity 3
   [OK] Check package "Certificates" (Match All)
   \_ [OK] Check package "Certificate End" (Match All)
      \_ [OK] Certificate CN=Cloudbase-Init WinRM(ACACBAC2A29ADC68D710C715DA20B036407BA3A8): 313784201.23
   | 'certificate_cncloudbaseinit_winrmacacbac2a29adc68d710c715da20b036407ba3a8'=313784201.23;@864000:31536000;@0:864000
.EXAMPLE
   PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*'-CertPaths "C:\ProgramData\icinga2\var\lib\icinga2\certs" -CertName '*.crt' -WarningEnd '@0d:10000d' -Verbosity 3
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
      $WarningEnd            = $null,
      $CriticalEnd           = $null,
      #CertStore-Related Param
      [ValidateSet('*', 'LocalMachine', 'CurrentUser', $null)]
      [string]$CertStore     = $null,
      [array]$CertThumbprint = $null,
      [array]$CertSubject    = $null,
      $CertStorePath         = '*',
      #Local Certs
      [array]$CertPaths      = $null,
      [array]$CertName		  = $null,
      #Other
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity        = 0
   );

   $CertData         = (Get-IcingaCertificateData -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertPaths $CertPaths -CertName $CertName -CertStorePath $CertStorePath);
   $CertPackage      = New-IcingaCheckPackage -Name 'Certificates' -OperatorAnd -Verbose $Verbosity;
   $ValidCertPackage = New-IcingaCheckPackage -Name 'Valid Certificates' -OperatorAnd -Verbose $Verbosity;
   $UntrustedPackage = New-IcingaCheckPackage -Name 'Untrusted Certificates' -OperatorAnd -Verbose $Verbosity;

   if ($null -ne $CriticalStart) {
      $CertPackageStart = New-IcingaCheckPackage -Name 'Certificate Start' -OperatorAnd -Verbose $Verbosity;
   }
   if (($null -ne $WarningEnd) -Or ($null -ne $CriticalEnd)) {
      $CertPackageEnd   = New-IcingaCheckPackage -Name 'Certificate End' -OperatorAnd -Verbose $Verbosity;
   }

   foreach ($Subject in $CertData.Keys) {
      $Thumbprints = $CertData[$Subject];
      foreach ($cert in $Thumbprints.Keys) {
         $cert = $Thumbprints[$cert];

         $CertValid = $FALSE;
         if ($Trusted) {
            $CertValid = Test-Certificate $cert -ErrorAction SilentlyContinue -WarningAction SilentlyContinue;
         } else {
            $CertValid = Test-Certificate $cert -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -AllowUntrustedRoot;
         }
         $CertName = '';
         if ($Cert.Subject.Contains(',')) {
		    $SpanTilAfter = (New-TimeSpan -Start (Get-Date) -End $Cert.NotAfter);
            $CertName = ([string]::Format('Certificate {0}({1} : {2}d)', $Cert.Subject.Split(",")[0], $Cert.NotAfter.ToString('yyyy-MM-dd'), $SpanTilAfter.Days));
         } else {
            $CertName = ([string]::Format('Certificate {0}({1} : {2}d)', $Cert.Subject, $Cert.NotAfter.ToString('yyyy-MM-dd'), $SpanTilAfter.Days));
         }
         $CertName = $CertName.Replace('CN=', '').Replace('cn=', '').Replace('OU=', '').Replace('ou=', '');

         $IcingaCheck = New-IcingaCheck -Name $CertName -Value $CertValid;
         $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
         if ($Trusted) {
            $ValidCertPackage.AddCheck($IcingaCheck);
         } else {
            $UntrustedPackage.AddCheck($IcingaCheck);
         }

         if ($null -ne $CriticalStart) {
	    [datetime]$CritDateTime=$CriticalStart
	    $CritStart=((New-TimeSpan -Start $Cert.NotBefore -End $CritDateTime) -gt 0)
            $IcingaCheck = New-IcingaCheck -Name $CertName -Value $CritStart;
	    $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
            $CertPackageStart.AddCheck($IcingaCheck);
         }
         if(($null -ne $WarningEnd) -Or ($null -ne $CriticalEnd)) {
            $IcingaCheck = New-IcingaCheck -Name $CertName -Value (New-TimeSpan -End $Cert.NotAfter.DateTime).TotalSeconds;
            $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningEnd)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalEnd)) | Out-Null;
            $CertPackageEnd.AddCheck($IcingaCheck);
         }
      }
   }

   if ($ValidCertPackage.HasChecks()) {
      $CertPackage.AddCheck($ValidCertPackage);
   }
   if ($UntrustedPackage.HasChecks()) {
      $CertPackage.AddCheck($UntrustedPackage);
   }

   $CertPackage.AddCheck($CertPackageStart);
   $CertPackage.AddCheck($CertPackageEnd);

   return (New-IcingaCheckResult -Name 'Certificates' -Check $CertPackage -NoPerfData $TRUE -Compile);
}
