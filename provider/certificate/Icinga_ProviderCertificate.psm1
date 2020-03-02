function Get-IcingaCertificateData()
{
   param(
      #CertStore-Related Param
      [ValidateSet('*', 'LocalMachine', 'CurrentUser')]
      [string]$CertStore     = '*',
      [array]$CertThumbprint = $null,
      [array]$CertSubject    = $null,
      $CertStorePath         = '*',
      #Local Certs
      [array]$CertPaths      = $null,
      [array]$CertName	     = $null

   );
   [hashtable]$CertData = @{};
   
   if ([string]::IsNullOrEmpty($CertStore) -eq $FALSE){
      $CertDataStore = Get-IcingaCertStoreCertificates -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertStorePath $CertStorePath;
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

   $CertData.Add('CertStore', $CertDataStore);
   $CertData.Add('CertFile', $CertDataFile);
   
   return $CertData;
}

function Get-IcingaCertStoreCertificates()
{
   param(
   #CertStore-Related Param
   [ValidateSet('*', 'LocalMachine', 'CurrentUser')]
   [string]$CertStore = '*',
   [array]$CertThumbprint = $null,
   [array]$CertSubject    = $null,
   $CertStorePath         = '*'
   );

   $CertStoreArray = @();
   $CertStorePath  = [string]::Format('Cert:\{0}\{1}', $CertStore, $CertStorePath);
   $CertStoreCerts = Get-ChildItem -Path $CertStorePath;
   
   if ($CertSubject -eq $null) {
      $CertSubject += '*'
   }
   
   if ($CertSubject -ne $null) {
      foreach ($Subject in $CertSubject)
      {
         $CertStoreArray += Get-ChildItem -Path $CertStorePath -Recurse | Where-Object { $_.Subject -like $Subject };
      }
   }
   
   if ($CertThumbprint -ne $null) {
      foreach ($Thumbprint in $CertThumbprint)
      {
         if ($CertStoreArray.Thumbprint -like ($Thumbprint)) {
            $CertStoreArray += Get-ChildItem -Path $CertStorePath -Recurse | Where-Object { $_.Thumbprint -like $Thumbprint };
         }
      }   
   }
   
   return $CertStoreArray;
}
