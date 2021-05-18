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
        [array]$StatusCode           = @()
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
            $HTTPInformation = @{
                'StatusCode' = $_.Exception.Message;
            };
        }
        Stop-IcingaTimer -Name 'HTTPRequest';

        [hashtable]$HTTPData = @{ };

        if (-Not [string]::IsNullOrEmpty($HTTPInformation.Content)) {
            $enc = [system.Text.Encoding]::UTF8;
            $HTTPData.Add('ContentSize', $enc.GetBytes($HTTPInformation.Content).Length);
            $HTTPData.Add('RequestTime', (Get-IcingaTimer -Name 'HTTPRequest').Elapsed.TotalSeconds);
        } else {
            $HTTPData.Add('ContentSize', 0);
        }

        # Determine status code match

        if ($StatusCode -contains $HTTPInformation.StatusCode) {
            $Status = $IcingaEnums.IcingaExitCode.OK;
        } else {
            # Defaults
            if (Test-Numeric $HTTPInformation.StatusCode) {
                switch ($HTTPInformation.StatusCode) {
                    { $_ -eq $null } { 
                        $Status = $IcingaEnums.IcingaExitCode.Unknown
                    };
                    { $_ -lt 200 } { # < 200 Unknown
                        $Status = $IcingaEnums.IcingaExitCode.Unknown
                    }
                    { $_ -ge 600 } { # >= 600 Unknown
                        $Status = $IcingaEnums.IcingaExitCode.Unknown
                    }
                    { $_ -In 200..399 } { # 200-399 OK
                        $Status = $IcingaEnums.IcingaExitCode.OK
                    }
                    { $_ -In 400..499 } { # 400-499 Warning
                        $Status = $IcingaEnums.IcingaExitCode.Warning
                    }
                    { $_ -In 500..599 } { # 500-599 Critical
                        $Status = $IcingaEnums.IcingaExitCode.Critical
                    }
                    # Proprietary
                    Default {
                        $Status = $IcingaEnums.IcingaExitCode.Unknown
                    }
                }
            } else {
                $Status = $IcingaEnums.IcingaExitCode.Unknown;
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
