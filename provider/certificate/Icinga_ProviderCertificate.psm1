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

   [array]$CertData = @();

   if ([string]::IsNullOrEmpty($CertStore) -eq $FALSE){
      $CertData += Get-IcingaCertStoreCertificates -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertStorePath $CertStorePath;
   }

   if (($null -ne $CertPaths) -or ($null -ne $CertName)) {
      $CertDataFile = @();

      foreach ($path in $CertPaths) {
         foreach ($name in $CertName) {
            [array]$files = Get-IcingaDirectoryRecurse -Path $path -FileNames $name;
            if ($null -ne $files) {
               $CertDataFile += $files;
            } else {
               # Remember that pattern didn't match
               $CertData += @{
                  Path = "${path}\${name}"
                  Cert = $null
               };   
            }
         }
      }
   }

   if ($null -ne $CertDataFile) {
      foreach ($Cert in $CertDataFile) {
         try {
            $CertConverted = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $Cert.FullName; 
            $CertData += @{
               Path = $Cert.FullName
               Cert = $CertConverted
            }; 
         } catch {
            # Not a valid certificate
            $CertData += @{
               Path = $Cert.FullName
               Cert = $null
            }; 
         }
      }
   }

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

   $CertStoreArray = @();
   $CertStorePath  = [string]::Format('Cert:\{0}\{1}', $CertStore, $CertStorePath);
   $CertStoreCerts = Get-ChildItem -Path $CertStorePath -Recurse;

   if ($CertSubject.Count -eq 0 -And $CertThumbprint.Count -eq 0) {
      $CertSubject += '*'
   }

   :findCert foreach ($Cert in $CertStoreCerts) {
      $data = @{
         Thumbprint = $Cert.Thumbprint
         Cert       = $Cert
      }
      if (($CertThumbprint -Contains '*') -Or ($CertThumbprint -Contains $Cert.Thumbprint)) {
         $CertStoreArray += $data;
         break;
      }

      foreach ($Subject in $CertSubject) {
        if ($Subject -eq '*' -Or ($Cert.Subject -Like $Subject)) {
            $CertStoreArray += $data;
            break findCert;
         }
      }
   }

   return $CertStoreArray;
}