function Global:Get-IcingaHttpResponse()
{
    param (
        [string]$ServerUri      = '',
        [string]$ServerPath     = '',
        [string]$QueryParameter = '',
        [string]$Username       = '',
        [SecureString]$Password = $null,
        [int]$Timeout           = 30,
        [switch]$IgnoreSSL      = $FALSE
    );

    if ([string]::IsNullOrEmpty($ServerUri)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerUri" on "Get-IcingaHttpResponse"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ([string]::IsNullOrEmpty($ServerPath)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerPath" on "Get-IcingaHttpResponse"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    [hashtable]$authHeader = @{ };

    if ([string]::IsNullOrEmpty($Username) -eq $FALSE -And $null -ne $Password) {
        $authHeader = New-IcingaBasicAuthHeader -Username $Username -Password $Password;
    }

    $URI = Join-WebPath -Path $ServerUri -ChildPath $ServerPath;
    if ($QueryParameter) {
        $URI = [string]::Format('{0}?{1}', $URI, $QueryParameter);
    }

    Write-IcingaDebugMessage -Message 'Calling uri "{0}"' -Objects $URI;

    # this adds TLS1.2 as protocol if it was not present. Required since some systems do not use TLS1.2 by default
    Set-IcingaTLSVersion;

    if ($IgnoreSSL) {
        Enable-IcingaUntrustedCertificateValidation;
    }

    $response = Invoke-RestMethod -Uri $URI -Method Get -Headers $authHeader -TimeoutSec $Timeout;

    Write-IcingaDebugMessage -Message 'Response: {0}' -Objects $response;

    return $response;
}
