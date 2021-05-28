<#
.SYNOPSIS
   Tests the given certificate against patterns if it should be excluded or not from the returned list of certificates which are tested for validity

.DESCRIPTION
   A certificate, passed by the -Certificate parameter, is tested for every string contained in an array passed by the -ExcludePattern parameter. 
   The array is looped through and accordingly compared, or moreover the fields are tested if the given string is contained. 

.PARAMETER Certificate
   Used to pass the certificate which the search will performed against.

.PARAMETER ExcludePattern
   Used to specify an array of strings which should be tested.

.INPUTS
   System.Boolean
.OUTPUTS
   System.Boolean
#>

function Test-IcingaCertificateExcludePattern
{
    [OutputType([boolean])]
    param (
        [array]$ExcludePattern                                                       = @(),
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    #If the array is empty, just behave like it's not contained
    if (($null -eq $ExcludePattern) -or ($ExcludePattern.Count -lt 1)) {
        return $false
    }

    #Iterate through the array of patterns and look for the string in Subject, Issuer, Subject Alternative Name
    foreach ($ExcludeString in $ExcludePattern) {
        if ($Certificate.Subject.Contains($ExcludeString)) {
            return $true
        }

        if ($Certificate.Issuer.Contains($ExcludeString)) {
            return $true
        }

        try {
            if (($Certificate.Extensions | Where-Object { $_.Oid.FriendlyName -eq "subject alternative name" }).Format(1).Contains($ExcludeString)) {
                return $true
            }
        } catch {
            #Certificate doesn't have SANs; continue with next ExcludeString in the array
            continue;
        }
    }

    #if nothing is found, return false
    return $false
}
