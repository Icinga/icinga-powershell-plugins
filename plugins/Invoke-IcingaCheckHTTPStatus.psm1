<#
.SYNOPSIS
   Checks the response time, the return code and content of HTTP requests.
.DESCRIPTION
   Invoke-IcingaCheckHTTPStatus returns either 'OK', 'WARNING' or 'CRITICAL', wether components of the check match or not.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check the status of http services.
   The result of the check is based on one of the following:
   - the match result of the response time, will either be 'OK', 'WARNING' or 'CRITICAL'.
   - the match result of the content match, will either be 'OK', or 'CRITICAL'.
   - the match result of the status code match, will either be 'OK' or 'CRITICAL'.
   Thereby the final match result will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content "Test" -Warning 1 -Verbosity 3
   [OK] Check package "HTTP Status Check" (Match All)
   \_ [OK] Check package "HTTP Content Check" ()
      \_ [OK] HTTP Content "Test": True
      \_ [OK] HTTP Response Time: 0.508972s
      \_ [OK] HTTP Status Code: 200
   | 'http_content_test'=1;; 'http_response_time'=0.508972s;1; 'http_status'=200;; 'http_content_size'=47917B;;
.EXAMPLE
   PS> Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content "FooBar" -Warning 1 -Verbosity 3}
   [OK] Check package "HTTP Status Check" (Match All)
   \_ [OK] Check package "HTTP Content Check" ()
   \_ [CRITICAL] HTTP Content "FooBar"
      \_ [OK] HTTP Response Time: 0.251071s
      \_ [OK] HTTP Status Code: 200
   | 'http_content_foobar'=0;; 'http_response_time'=0.251071s;1; 'http_status'=200;; 'http_content_size'=89970B;;
.PARAMETER Warning
   Used to specify the webrequest response time warning threshold in seconds, everything past that threshold is considered a WARNING.
.PARAMETER Critical
   Used to specify the webrequest response time critical threshold in seconds, everything past that threshold is considered a CRITICAL.
.PARAMETER Url
   Used to specify the URL of the host to check http as string. Use 'http://' or 'https://' to actively chose a protocol. Likewise ':80' or any other port number to specify a port, etc.
.PARAMETER VHost
   Used to specify a VHost as string.
.PARAMETER Headers
   Used to specify headers as Array. Like: -Headers 'Accept:application/json'
.PARAMETER Timeout
   Used to specify the timeout in seconds of the webrequest as integer. The default is 10 for 10 seconds.
.PARAMETER Username
   Used to specify a username as string to authenticate with. Authentication is only possible with 'https://'. Use with: -Password
.PARAMETER Password
   Used to specify a password as securestring to authenticate with. Authentication is only possible with 'https://'.Use with: -Username
.PARAMETER ProxyUsername
   Used to specify a proxy username as string to authenticate with. Use with: -ProxyPassword & -ProxyServer
.PARAMETER ProxyPassword
   Used to specify a proxy password as securestring to authenticate with. Use with: -ProxyUsername & -ProxyServer
.PARAMETER ProxyServer
   Used to specify a proxy server as string to authenticate with.
.PARAMETER Content
   Used to specify an array of regex-match-strings to match against the content of the webrequest response.
.PARAMETER Content
   Used to specify expected HTTP status code as array. Multiple status codes which are considered 'OK' can be used.
   This overwrites the default outcomes for HTTP status codes:
   <   200      Unknown
       200-399  OK
       400-499  Warning
       500-599  Critical
   >=  600      Unknown
.PARAMETER Negate
    A switch used to invert check results.
.PARAMETER AddOutputContent
    Adds the returned content of a webseite to the plugin output for debugging purpose
.PARAMETER NoPerfData
    Used to disable PerfData.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>
# Error Handling
# Array umbauen

function Invoke-IcingaCheckHTTPStatus()
{
    param (
        $Warning                     = $null,
        $Critical                    = $null,
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
        [int]$Minimum                = -1,
        [switch]$Negate              = $FALSE,
        [switch]$AddOutputContent    = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity              = 0
    )

    $HTTPData = (Get-IcingaCheckHTTPQuery -Url $Url -VHost $VHost -Headers $Headers -Timeout $Timeout -Username $Username -Password $Password -ProxyUsername $ProxyUsername -ProxyPassword $ProxyPassword -ProxyServer $ProxyServer -Content $Content -StatusCode $StatusCode);

    # In case -Minimum isn't set, implied -OperatorAnd
    if ($Minimum -eq -1) {
        $Minimum = $Url.Count;
    }

    $HTTPAllStatusPackage = New-IcingaCheckPackage -Name "HTTP Status Check" -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    foreach ($SingleUrl in $Url) {

        $TransformedUrl = $SingleUrl  -Replace "[:\./]", "_" -Replace "(_)+", "_";
        # Full Package
        $HTTPStatusPackage = New-IcingaCheckPackage -Name ([string]::Format('HTTP Status Check {0}', $SingleUrl)) -OperatorAnd -Verbose $Verbosity;

        # Status Code

        $HTTPStatusCodeCheck = New-IcingaCheck -Name "HTTP Status Code" -Value $HTTPData[$SingleUrl]['StatusCodes'].Value -LabelName ([string]::Format('{0}.http_status', $TransformedUrl));


        if ($Negate -eq $false) {
            # Normal
            switch ($HTTPData[$SingleUrl]['StatusCodes'].State) {
                $IcingaEnums.IcingaExitCode.OK {
                    # Do nothing
                    break;
                };
                $IcingaEnums.IcingaExitCode.Warning {
                    $HTTPStatusCodeCheck.SetWarning() | Out-Null;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Critical {
                    $HTTPStatusCodeCheck.SetCritical() | Out-Null;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Unknown {
                    $HTTPStatusCodeCheck.SetUnknown() | Out-Null;
                    break;
                };
            }
        } else {
            # Negate
            switch ($HTTPData[$SingleUrl]['StatusCodes'].State) {
                $IcingaEnums.IcingaExitCode.OK {
                    $HTTPStatusCodeCheck.SetCritical() | Out-Null;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Warning {
                    # Do nothing
                    break;
                };
                $IcingaEnums.IcingaExitCode.Critical {
                    # Do nothing
                    break;
                };
                $IcingaEnums.IcingaExitCode.Unknown {
                    $HTTPStatusCodeCheck.SetUnknown() | Out-Null;
                    break;
                };
            }
        }

        $HTTPStatusPackage.AddCheck($HTTPStatusCodeCheck);

        # Content Package
        if ($HTTPData.$SingleUrl.'StatusCodes'.Value -ne $null) {
            $ContentPackage = New-IcingaCheckPackage -Name "HTTP Content Check" -OperatorMin $Minimum -Verbose $Verbosity -IgnoreEmptyPackage;
        } else {
            $ContentPackage = New-IcingaCheckPackage -Name "HTTP Content Check" -OperatorMin $Minimum -Verbose $Verbosity -IgnoreEmptyPackage -Hidden;
        }

        # Found & Not Found
        foreach ($ContentKeys in $HTTPData[$SingleUrl]['Matches'].Keys) {
            if ($HTTPData[$SingleUrl]['StatusCodes'].Value -ne $null) {
                $HTTPContentMatchPackage = New-IcingaCheck `
                    -Name ([string]::Format('HTTP Content "{0}"', $ContentKeys)) `
                    -Value $HTTPData[$SingleUrl]['Matches'][$ContentKeys] `
                    -LabelName ([string]::Format('{0}.http_content_{1}', $TransformedUrl, $ContentKeys)) `
                    -Translation @{ 'true' = 'Found'; 'false' = 'Not Found' };
            } else {
                $HTTPContentMatchPackage = New-IcingaCheck `
                    -Name ([string]::Format('HTTP Content "{0}"', $ContentKeys)) `
                    -Value $HTTPData[$SingleUrl]['Matches'][$ContentKeys] `
                    -LabelName ([string]::Format('{0}.http_content_{1}', $TransformedUrl, $ContentKeys)) `
                    -Translation @{ 'true' = 'Found'; 'false' = 'Not Found' } `
                    -Hidden;
            }

            if ($HTTPData[$SingleUrl]['Matches'][$ContentKeys] -eq $FALSE) {
                $HTTPContentMatchPackage.SetCritical() | Out-Null;
            }
            $ContentPackage.AddCheck($HTTPContentMatchPackage);
        }
        $HTTPStatusPackage.AddCheck($ContentPackage);

        if ($AddOutputContent) {
            $HTTPStatusPackage.AddCheck(
                (
                    New-IcingaCheck -Name "HTTP Content" -Value $HTTPData.$SingleUrl.Content -NoPerfData
                )
            );
        }

        # Response Time
        if ($HTTPData.$SingleUrl['RequestTime'] -eq $null) {
            $HTTPResponseTimeCheck = New-IcingaCheck -Name "HTTP Response Time" -Value 0 -LabelName ([string]::Format('{0}.http_response_time', $TransformedUrl)) -Unit 's' -Hidden;
            $HTTPResponseTimeCheck.SetUnknown() | Out-Null;
        } else {
            $HTTPResponseTimeCheck = New-IcingaCheck -Name "HTTP Response Time" -Value $HTTPData.$SingleUrl['RequestTime'] -LabelName ([string]::Format('{0}.http_response_time', $TransformedUrl)) -Unit 's';
            $HTTPResponseTimeCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        }
        $HTTPStatusPackage.AddCheck($HTTPResponseTimeCheck);

        # PerfData
        $PerfDataPackage = New-IcingaCheckPackage -Name 'PerfData' -OperatorAnd -Verbose $Verbosity -Hidden -Checks @(
            (New-IcingaCheck -Name 'Content Size' -Value $HTTPData.$SingleUrl['ContentSize'] -Unit 'B' -LabelName ([string]::Format('{0}.http_content_size', $TransformedUrl)))
        );
        $HTTPStatusPackage.AddCheck($PerfDataPackage);

        $HTTPAllStatusPackage.AddCheck($HTTPStatusPackage);
    }

    return (New-IcingaCheckResult -Check $HTTPAllStatusPackage -NoPerfData $NoPerfData -Compile);
}
