<#
.SYNOPSIS
   ???
.DESCRIPTION
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.PARAMETER Warning
   jaofjafoofaj

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
	  $WarningStart          = $null,
	  $CriticalStart         = $null,
	  $WarningEnd            = $null,
	  $CriticalEnd           = $null,
    #CertStore-Related Param
	  [ValidateSet('LocalMachine', 'CurrentUser')]
	  [string]$CertStore     = $null,
	  [array]$CertThumbprint = $null,
	  [array]$CertSubject    = $null,
	#Local Certs
      [array]$CertPaths      = $null,
	  [array]$CertName		 = $null,
	#Other
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0,
      [switch]$NoPerfData
   );

   $CertData                    = (Get-IcingaCertificateData -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertPaths $CertPaths -CertName $CertName);
   $CertPackage                 = New-IcingaCheckPackage -Name 'Certificates' -OperatorAnd -Verbose $Verbosity;

   $Date                        = Get-Date; 
   
   if ([string]::IsNullOrEmpty($CertStore) -eq $FALSE){
      $CertDataStore = Get-IcingaCertStoreCertificates -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject
   }
   
   if (($null -ne $CertPaths) -or ($null -ne $CertName)) {
      $CertDataFile = Get-IcingaDirectoryRecurse -Path $CertPaths -FileNames $CertName;
   }
   
   if ($null -ne $CertDataFile) {
      foreach ($Cert in $CertDataFile) {
         $CertConverted = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $Cert.FullName;
	     $CertDataFile = $CertConverted;
      }
   }

# Check for Trusted
   if($Trusted) {
      foreach($Cert in $CertData.CertStore) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate {0}', $Cert.Serialnumber)) -Value (Test-Certificate $Cert -ErrorAction silentlycontinue);
		 $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
		 $CertPackage.AddCheck($IcingaCheck);
      }
      foreach($Cert in $CertData.CertFile) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate {0}', $Cert.Serialnumber)) -Value (Test-Certificate $Cert -ErrorAction silentlycontinue);
		 $IcingaCheck.CritIfNotMatch($TRUE) | Out-Null;
		 $CertPackage.AddCheck($IcingaCheck);
      }
   }

# Check for Start of Cert
   if(($null -ne $WarningStart) -Or ($null -ne $CriticalStart)) {
      $CertPackageStart            = New-IcingaCheckPackage -Name 'Certificate Start' -OperatorAnd -Verbose $Verbosity;
      foreach($Cert in $CertData.CertStore) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate Start {0}', $Cert.Serialnumber)) -Value (ConvertFrom-TimeSpan -Seconds (New-TimeSpan -End $Cert.NotBefore.Datetime).TotalSeconds);
         $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningStart)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalStart)) | Out-Null;
	     $CertPackageStart.AddCheck($IcingaCheck);
	  }
	  foreach($Cert in $CertData.CertFile) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate Start {0}', $Cert.Serialnumber)) -Value (ConvertFrom-TimeSpan -Seconds (New-TimeSpan -End $Cert.NotBefore.Datetime).TotalSeconds);
         $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningStart)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalStart)) | Out-Null;
		 $CertPackageStart.AddCheck($IcingaCheck);
      }
   }
# Check for End of Cert
   if(($null -ne $WarningEnd) -Or ($null -ne $CriticalEnd)) {
      $CertPackageEnd              = New-IcingaCheckPackage -Name 'Certificate End' -OperatorAnd -Verbose $Verbosity;
      foreach($Cert in $CertData.CertStore) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate Start {0}', $Cert.Serialnumber)) -Value (ConvertFrom-TimeSpan -Seconds (New-TimeSpan -End $Cert.NotAfter.Datetime).TotalSeconds);
		 $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningEnd)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalEnd)) | Out-Null;
		 $CertPackageEnd.AddCheck($IcingaCheck);

	  }
	  foreach($Cert in $CertData.CertFile) {
         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Certificate Start {0}', $Cert.Serialnumber)) -Value (ConvertFrom-TimeSpan -Seconds (New-TimeSpan -End $Cert.NotAfter.Datetime).TotalSeconds);
         $IcingaCheck.WarnOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $WarningEnd)).CritOutOfRange((ConvertTo-SecondsFromIcingaThresholds -Threshold $CriticalEnd)) | Out-Null;
		 $CertPackageEnd.AddCheck($IcingaCheck);
     }
   }

   $CertPackage.AddCheck($CertPackageStart);
   $CertPackage.AddCheck($CertPackageEnd);
   
   return (New-IcingaCheckResult -Name 'Certificates' -Check $CertPackage -NoPerfData $NoPerfData -Compile);
}
