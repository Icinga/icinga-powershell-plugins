function Get-IcingaCertificateData()
{
   param(
    #CertStore-Related Param
	  [ValidateSet('LocalMachine', 'CurrentUser')]
	  [string]$CertStore     = $null,
	  [array]$CertThumbprint = $null,
	  [array]$CertSubject    = $null,
	#Local Certs
      [array]$CertPaths      = $null,
	  [array]$CertName		 = $null
   );
   [hashtable]$CertData = @{};
   
   if ([string]::IsNullOrEmpty($CertStore) -eq $FALSE){
      $CertDataStore = Get-IcingaCertStoreCertificates -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject
   }
   
   if (($null -ne $CertPaths) -or ($null -ne $CertName)) {
      $CertDataFile = Get-IcingaDirectoryRecurse -Path $CertPaths -FileNames $CertName;
	  Write-Host "HI"
   }
   
   if ($null -ne $CertDataFile) {
      foreach ($Cert in $CertDataFile) {
         $CertConverted = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $Cert.FullName;
	     $CertDataFile = $CertConverted;
      }
   }

   $CertData.Add('CertStore', $CertDataStore);
   $CertData.Add('CertFile', $CertDataFile);
   
   return $CertData;
}

function Get-IcingaCertStoreCertificates()
{
   param(
    #CertStore-Related Param
	  [ValidateSet('LocalMachine', 'CurrentUser')]
	  [string]$CertStore = 'LocalMachine',
	  [array]$CertThumbprint = $null,
	  [array]$CertSubject    = $null
	);

   $CertStoreArray = @();
   $CertStorePath  = [string]::Format('Cert:\{0}\My', $CertStore)
   $CertStoreCerts = Get-ChildItem -Path $CertStorePath;
   
   if ($CertSubject -ne $null) {
      foreach ($Subject in $CertSubject)
      {
	     $CertStoreArray += Get-ChildItem -Path $CertStorePath | Where-Object { $_.Subject -like $Subject }
      }
   }
   
   if ($CertThumbprint -ne $null) {
      foreach ($Thumbprint in $CertThumbprint)
      {
	     if ($CertStoreArray.Thumbprint -like ($Thumbprint)) {
	        $CertStoreArray += Get-ChildItem -Path $CertStorePath | Where-Object { $_.Thumbprint -like $Thumbprint }
		 }
      }   
   }
   
   return $CertStoreArray;
}
