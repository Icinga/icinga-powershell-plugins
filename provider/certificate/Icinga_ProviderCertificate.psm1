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
      [array]$CertName       = $null,
      [switch]$Recurse
   );

   [array]$CertData = @();

   if ([string]::IsNullOrEmpty($CertStore) -eq $FALSE){
      $CertData += Get-IcingaCertStoreCertificates -CertStore $CertStore -CertThumbprint $CertThumbprint -CertSubject $CertSubject -CertStorePath $CertStorePath;
   }

   if (($null -ne $CertPaths) -or ($null -ne $CertName)) {
      $CertDataFile = @();

      foreach ($path in $CertPaths) {
         foreach ($name in $CertName) {
            $searchPath = $path
            if (-not $Recurse) {
               # For Get-ChildItem we need to add the wildcard when not recursing
               # Please see the docs!
               $searchPath = "${path}\*"
            }
            [array]$files = Get-ChildItem -Recurse:$Recurse -Include $name -Path $searchPath;

            if ($null -ne $files) {
               $CertDataFile += $files;
            } else {
               # Remember that pattern didn't match
               if ($CertPaths.length -eq 1) {
                  $certPath = $name;
               } else {
                  $certPath = "${path}\${name}";
               }
               $CertData += @{
                  Path = $certPath
                  Cert = $null
               };   
            }
         }
      }
   }

   if ($null -ne $CertDataFile) {
      foreach ($Cert in $CertDataFile) {
         $path = $Cert.FullName
         if ($CertPaths.length -eq 1) {
            $path = $path.Replace("${CertPaths}\", '')
         }
         try {
            $CertConverted = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $Cert.FullName; 
            $CertData += @{
               Path = $path
               Cert = $CertConverted
            }; 
         } catch {
            # Not a valid certificate
            $CertData += @{
               Path = $path
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

   foreach ($Cert in $CertStoreCerts) {
      $data = @{
         Thumbprint = $Cert.Thumbprint
         Cert       = $Cert
      }
      if (($CertThumbprint -Contains '*') -Or ($CertThumbprint -Contains $Cert.Thumbprint)) {
         $CertStoreArray += $data;
         continue;
      }

      foreach ($Subject in $CertSubject) {
        if ($Subject -eq '*' -Or ($Cert.Subject -Like $Subject)) {
            $CertStoreArray += $data;
            break;
         }
      }
   }

   return $CertStoreArray;
}