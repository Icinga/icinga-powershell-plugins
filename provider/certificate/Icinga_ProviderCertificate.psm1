function Get-IcingaCertificateData()
{
   param(
      #CertStore-Related Param
      [ValidateSet('*', 'LocalMachine', 'CurrentUser', $null)]
      [string]$CertStore     = $null,
      [array]$CertThumbprint = $null,
      [array]$CertSubject    = $null,
      $CertStorePath         = '*',
      #Local Certs
      [array]$CertPaths      = $null,
      [array]$CertName       = $null
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
      [array]$CertThumbprint = @(),
      [array]$CertSubject    = @(),
      $CertStorePath         = '*'
   );

   $CertStoreArray = @{};
   $CertStorePath  = [string]::Format('Cert:\{0}\{1}', $CertStore, $CertStorePath);
   $CertStoreCerts = Get-ChildItem -Path $CertStorePath -Recurse;

   if ($CertSubject.Count -eq 0 -And $CertThumbprint.Count -eq 0) {
      foreach ($Cert in $CertStoreCerts) {
         $CertStoreArray = Add-IcingaCertificateToHashtable -Certificate $Cert -CertCache $CertStoreArray;
      }
      return $CertStoreCerts;
   }

   foreach ($Cert in $CertStoreCerts) {
      foreach ($Subject in $CertSubject) {
	     if (($Cert.Subject -Like $Subject) -Or $Subject -eq '*') {
            $CertStoreArray = Add-IcingaCertificateToHashtable -Certificate $Cert -CertCache $CertStoreArray;
         }
      }
      if (($CertThumbprint -Contains $Cert.Thumbprint) -Or ($CertThumbprint -Contains '*')) {
         $CertStoreArray = Add-IcingaCertificateToHashtable -Certificate $Cert -CertCache $CertStoreArray;
      }
   }

   return $CertStoreArray;
}

function Add-IcingaCertificateToHashtable()
{
   param(
      $Certificate,
      [hashtable]$CertCache = @{}
   );

   if ($null -eq $CertCache -or $null -eq $Certificate) {
      return $CertCache;
   }

   if ($CertCache.ContainsKey($Certificate.Subject)) {
      $CertCache[$Certificate.Subject].Add(
         $Certificate.Thumbprint,
         $Certificate
      );
   } else {
      $CertCache.Add(
         $Certificate.Subject,
         @{
            $Certificate.Thumbprint = $Certificate
         }
      );
   }

   return $CertCache;
}
