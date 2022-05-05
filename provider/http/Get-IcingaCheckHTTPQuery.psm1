function Get-IcingaCheckHTTPQuery()
{
    param (
        [array]$Url                  = @(),
        [string]$VHost               = '',
        [array]$Headers              = @(),
        [int]$Timeout                = 10,
        [string]$Username            = '',
        [securestring]$Password      = $null,
        [string]$ProxyUsername       = '',
        [securestring]$ProxyPassword = $null,
        [string]$ProxyServer         = '',
        [array]$Content              = @(),
        [array]$StatusCode           = @(),
        [switch]$ConnectionErrAsCrit = $FALSE
    );

    if ($Url.count -eq 0) {
        Exit-IcingaThrowException -ExceptionType 'Input' -CustomMessage 'Argument empty' -ExceptionThrown 'Plugin execution failed because the -Url argument is not containing any values' -Force;
    }

    [hashtable]$HTTPAllData=@{ };

    foreach ($SingleUrl in $Url) {
        # Initialize

        $HTTPInformation = $null;

        # Determine command arguments

        [hashtable]$InvokeArguments = @{ };
        $InvokeArguments.Add('-Uri', $SingleUrl);
        $InvokeArguments.Add('-TimeoutSec', $Timeout);
        $InvokeArguments.Add('-ErrorAction', 'Stop');
        $InvokeArguments.Add('-UseBasicParsing', $TRUE);

        # Converting headers suitable for -Headers as hashtable/dictionary

        [hashtable]$ConvertedHeaders = @{ }

        if (-Not [string]::IsNullOrEmpty($VHost)) {
            $ConvertedHeaders.Add('Host', $VHost);
        }

        if (-Not [string]::IsNullOrEmpty($Headers)) {
            foreach ($SingleHeader in $Headers){
                $key, $value = ($SingleHeader.Split(':') | ForEach-Object { $_.Trim() })
                $ConvertedHeaders.Add($key, $value);
            }
        }

        if (-Not [string]::IsNullOrEmpty($ConvertedHeaders)) {
            $InvokeArguments.Add('-Headers', $ConvertedHeaders);
        }

        if (($Password -ne $null) -And (-Not [string]::IsNullOrEmpty($Username))) {
            $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $Password)
            $InvokeArguments.Add('-Credential', $Credentials);
        } elseif (($Password -ne $null) -Or (-Not [string]::IsNullOrEmpty($Username))) {
            Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'AuthenticationError' -InputString (
                [string]::Format("Please make sure you provide both Username and Password.")
            ) -Force;
        }

        if (($ProxyPassword -ne $null) -And (-Not [string]::IsNullOrEmpty($ProxyUsername)) -And (-Not [string]::IsNullOrEmpty($ProxyServer))) {
            $InvokeArguments.Add('-Proxy', $ProxyServer);
            $ProxyCredentials = New-Object System.Management.Automation.PSCredential ($ProxyUsername, $ProxyPassword)
            $InvokeArguments.Add('-ProxyCredential', $ProxyCredentials);
        } elseif (($ProxyPassword -ne $null) -Or (-Not [string]::IsNullOrEmpty($ProxyUsername)) -Or (-Not [string]::IsNullOrEmpty($ProxyServer))) {
            Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'ProxyAuthenticationError' -InputString (
                [string]::Format("Please make sure you provide ProxyUsername, ProxyPassword and ProxyServer.")
            ) -Force;
        }

        # Receive information

        Start-IcingaTimer -Name 'HTTPRequest';
        try {
            $HTTPInformation = (Invoke-WebRequest @InvokeArguments);
        } catch {
            if ([string]::IsNullOrEmpty($_.Exception.Response.StatusCode)) {
                $HTTPInformation = @{
                    'StatusCode' = $_.Exception.Message;
                };
            } else {
                $HTTPInformation = @{
                    'StatusCode' = [int]$_.Exception.Response.StatusCode;
                };
            }
        }
        Stop-IcingaTimer -Name 'HTTPRequest';

        [hashtable]$HTTPData = @{ };

        if (-Not [string]::IsNullOrEmpty($HTTPInformation.Content)) {
            $enc = [system.Text.Encoding]::UTF8;
            $HTTPData.Add('ContentSize', $enc.GetBytes($HTTPInformation.Content).Length);
            $HTTPData.Add('Content', $HTTPInformation.Content);
        } else {
            $HTTPData.Add('ContentSize', 0);
        }

        $HTTPData.Add('RequestTime', (Get-IcingaTimer -Name 'HTTPRequest').Elapsed.TotalSeconds);

        # Determine status code match

        if ($StatusCode -contains $HTTPInformation.StatusCode) {
            $Status = $IcingaEnums.IcingaExitCode.OK;
        } else {
            # Defaults
            if (Test-Numeric $HTTPInformation.StatusCode) {
                if ($HTTPInformation.StatusCode -eq $null) {
                    $Status = $IcingaEnums.IcingaExitCode.Unknown;
                } elseif ($HTTPInformation.StatusCode -lt 200) { # < 200 Unknown
                    $Status = $IcingaEnums.IcingaExitCode.Unknown;
                } elseif ($HTTPInformation.StatusCode -ge 600) { # >= 600 Unknown
                    $Status = $IcingaEnums.IcingaExitCode.Unknown;
                } elseif ($HTTPInformation.StatusCode -In 200..399) { # 200-399 OK
                    $Status = $IcingaEnums.IcingaExitCode.OK;
                } elseif ($HTTPInformation.StatusCode -In 400..499) { # 400-499 Warning
                    $Status = $IcingaEnums.IcingaExitCode.Warning;
                } elseif ($HTTPInformation.StatusCode -In 500..599) { # 500-599 Critical
                    $Status = $IcingaEnums.IcingaExitCode.Critical;
                } else {
                    $Status = $IcingaEnums.IcingaExitCode.Unknown; # Proprietary
                }
            } else {
                if ($ConnectionErrAsCrit) {
                    $Status = $IcingaEnums.IcingaExitCode.Critical;
                } else {
                    $Status = $IcingaEnums.IcingaExitCode.Unknown;
                }
            }
        }
        # Content-Check if status code is within range: 200-299
        if ($HTTPInformation.StatusCode -In 200..299) {
            $HTTPData.Add('Matches', @{});
            foreach ($ContentMatch in $Content) {
                $MatchStatus = $FALSE;
                if ($HTTPInformation.Content -match $ContentMatch) { 
                    $MatchStatus=$TRUE;
                }
                $HTTPData['Matches'].Add($ContentMatch, $MatchStatus)
            }
        }

        $HTTPData.Add(
            'StatusCodes', @{
                'Value' = $HTTPInformation.StatusCode;
                'State' = $Status;
            }
        );

        $HTTPAllData.Add($SingleUrl, $HTTPData);
    }

    return $HTTPAllData;
}
