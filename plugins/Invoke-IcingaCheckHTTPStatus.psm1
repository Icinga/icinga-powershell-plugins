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
    PS> Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content 'Test' -Warning 1 -Verbosity 3;

    Check the HTTP status of a website and lookup a specific content text element

    [OK] HTTP Status Check: 1 Ok (Atleast 1 must be [OK])
    \_ [OK] HTTP Status Check https://icinga.com (All must be [OK])
        \_ [OK] HTTP Content Check (Atleast 1 must be [OK])
            \_ [OK] HTTP Content "Test": Found
        \_ [OK] HTTP Response Time: 144ms
        \_ [OK] HTTP Status Code: 200
    | https_icinga_com::ifw_httpstatus::responsetime=0.144446s;1;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;;
.EXAMPLE
    PS> Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content 'FooBar' -Warning 1 -Verbosity 3;

    Check the HTTP status of a website and lookup a specific content text element. Report CRITICAL on missing content

    [CRITICAL] HTTP Status Check: 1 Critical [CRITICAL] HTTP Status Check https://icinga.com (Atleast 1 must be [OK])
    \_ [CRITICAL] HTTP Status Check https://icinga.com (All must be [OK])
        \_ [CRITICAL] HTTP Content Check (Atleast 1 must be [OK])
            \_ [CRITICAL] HTTP Content "FooBar": Not Found
        \_ [OK] HTTP Response Time: 226ms
        \_ [OK] HTTP Status Code: 200
    | https_icinga_com::ifw_httpstatus::responsetime=0.225516s;1;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;;
.EXAMPLE
    PS> Invoke-IcingaCheckHTTPStatus -Url 'https://netways.de', 'https://icinga.com' -Content 'Experten' -StatusMinimum 1 -Verbosity 3;

    Check multiple URLs with content checks. Use -StatusMinimum to report OK if at least one URL package is OK

    [OK] HTTP Status Check: 1 Critical 1 Ok [CRITICAL] HTTP Status Check https://icinga.com (Atleast 1 must be [OK])
    \_ [CRITICAL] HTTP Status Check https://icinga.com (All must be [OK])
        \_ [CRITICAL] HTTP Content Check (Atleast 1 must be [OK])
            \_ [CRITICAL] HTTP Content "Experten": Not Found
        \_ [INFO] HTTP Response Time: 148ms
        \_ [OK] HTTP Status Code: 200
    \_ [OK] HTTP Status Check https://netways.de (All must be [OK])
        \_ [OK] HTTP Content Check (Atleast 1 must be [OK])
            \_ [OK] HTTP Content "Experten": Found
        \_ [INFO] HTTP Response Time: 133ms
        \_ [OK] HTTP Status Code: 200
    | https_icinga_com::ifw_httpstatus::responsetime=0.148016s;;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;; https_netways_de::ifw_httpstatus::responsetime=0.132889s;;;; https_netways_de::ifw_httpstatus::statuscode=200;;;; https_netways_de::ifw_httpstatus::contentsize=335050B;;;;
.EXAMPLE
    PS> Invoke-IcingaCheckHTTPStatus -Url 'https://netways.de', 'https://icinga.com' -Verbosity 3 -Content 'Experten', 'team' -Minimum 1;

    Check multiple URLs for content matches,  but only require at least one content match per URL

    [OK] HTTP Status Check: 2 Ok (Atleast 2 must be [OK])
    \_ [OK] HTTP Status Check https://icinga.com (All must be [OK])
        \_ [OK] HTTP Content Check (Atleast 1 must be [OK])
            \_ [CRITICAL] HTTP Content "Experten": Not Found
            \_ [OK] HTTP Content "team": Found
        \_ [INFO] HTTP Response Time: 136ms
        \_ [OK] HTTP Status Code: 200
    \_ [OK] HTTP Status Check https://netways.de (All must be [OK])
        \_ [OK] HTTP Content Check (Atleast 1 must be [OK])
            \_ [OK] HTTP Content "Experten": Found
            \_ [OK] HTTP Content "team": Found
        \_ [INFO] HTTP Response Time: 258ms
        \_ [OK] HTTP Status Code: 200
    | https_icinga_com::ifw_httpstatus::responsetime=0.136292s;;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;; https_netways_de::ifw_httpstatus::responsetime=0.258167s;;;; https_netways_de::ifw_httpstatus::statuscode=200;;;; https_netways_de::ifw_httpstatus::contentsize=335050B;;;;
.PARAMETER Warning
   Used to specify the web request response time warning threshold in seconds, everything past that threshold is considered a WARNING.
.PARAMETER Critical
   Used to specify the web request response time critical threshold in seconds, everything past that threshold is considered a CRITICAL.
.PARAMETER Url
   Used to specify the URL of the host to check http as string. Use 'http://' or 'https://' to actively chose a protocol. Likewise ':80' or any other port number to specify a port, etc.
.PARAMETER VHost
   Used to specify a VHost as string.
.PARAMETER Headers
   Used to specify headers as Array. Like: -Headers 'Accept:application/json'
.PARAMETER Timeout
   Used to specify the timeout in seconds of the web request as integer. The default is 10 for 10 seconds.
.PARAMETER Username
   Used to specify a username as string to authenticate with. Authentication is only possible with 'https://'. Use with: -Password
.PARAMETER Password
   Used to specify a password as secure string to authenticate with. Authentication is only possible with 'https://'.Use with: -Username
.PARAMETER ProxyUsername
   Used to specify a proxy username as string to authenticate with. Use with: -ProxyPassword & -ProxyServer
.PARAMETER ProxyPassword
   Used to specify a proxy password as secure string to authenticate with. Use with: -ProxyUsername & -ProxyServer
.PARAMETER ProxyServer
   Used to specify a proxy server as string to authenticate with.
.PARAMETER Content
   Used to specify an array of regex-match-strings to match against the content of the web request response.
.PARAMETER StatusCode
   Used to specify expected HTTP status code as array. Multiple status codes which are considered 'OK' can be used.
   This overwrites the default outcomes for HTTP status codes:
   <   200      Unknown
       200-399  OK
       400-499  Warning
       500-599  Critical
   >=  600      Unknown
.PARAMETER Minimum
    Used to specify the minimum number of content matches that must be found to consider the content check as 'OK'.
    If not specified, all content matches must be found.
.PARAMETER StatusMinimum
    Used to specify the minimum number of of the 'HTTP Status Check' package checks that must be 'OK' to consider the overall check as 'OK'.
    This will evaluate the entire package of the Url check, including Status Code, Content Matches and Response Time.
    If not specified, all checks must be 'OK' in order for the overall check to be 'OK'.
.PARAMETER Negate
    A switch used to invert check results.
.PARAMETER AddOutputContent
    Adds the returned content of a website to the plugin output for debugging purpose
.PARAMETER ConnectionErrAsCrit
    By default the plugin will return UNKNOWN in case a connection to a webserver is not possible. By using this
    flag, the result will be modified from UNKNOWN to CRITICAL
.PARAMETER IgnoreSSL
    Use this flag to ignore SSL errors in case your endpoints are not trusted by the client or you are using self-signed certificates.
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
        [int]$StatusMinimum          = -1,
        [switch]$Negate              = $FALSE,
        [switch]$AddOutputContent    = $FALSE,
        [switch]$ConnectionErrAsCrit = $FALSE,
        [switch]$IgnoreSSL           = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity              = 0
    );

    $HTTPData = (Get-IcingaCheckHTTPQuery -Url $Url -VHost $VHost -Headers $Headers -Timeout $Timeout -Username $Username -Password $Password -ProxyUsername $ProxyUsername -ProxyPassword $ProxyPassword -ProxyServer $ProxyServer -Content $Content -StatusCode $StatusCode -ConnectionErrAsCrit:$ConnectionErrAsCrit -IgnoreSSL:$IgnoreSSL -Verbose $Verbosity);

    # In case -Minimum isn't set, implied -OperatorAnd
    if ($Minimum -eq -1) {
        $Minimum = $Content.Count;
    }

    # If not specified, assume the -StatusMinimum is equal to the number of URLs
    if ($StatusMinimum -eq -1) {
        $StatusMinimum = $Url.Count; # All checks must be OK
    }

    $HTTPAllStatusPackage = New-IcingaCheckPackage -Name "HTTP Status Check" -OperatorMin $StatusMinimum -Verbose $Verbosity -AddSummaryHeader;

    foreach ($SingleUrl in $Url) {

        $TransformedUrl = $SingleUrl  -Replace "[:\./]", "_" -Replace "(_)+", "_";
        $MetricIndex    = $TransformedUrl; # $TransformedUrl.Replace('_', '');
        # Full Package
        $HTTPStatusPackage = New-IcingaCheckPackage -Name ([string]::Format('HTTP Status Check {0}', $SingleUrl)) -OperatorAnd -Verbose $Verbosity;

        # Status Code

        $HTTPStatusCodeCheck = New-IcingaCheck `
            -Name "HTTP Status Code" `
            -Value $HTTPData[$SingleUrl]['StatusCodes'].Value `
            -MetricIndex $MetricIndex `
            -MetricName 'statuscode';

        if ($Negate -eq $false) {
            # Normal
            switch ($HTTPData[$SingleUrl]['StatusCodes'].State) {
                0 {
                    $HTTPStatusCodeCheck.SetOk() | Out-Null;
                    break;
                };
                1 {
                    $HTTPStatusCodeCheck.SetWarning() | Out-Null;
                    break;
                };
                2 {
                    $HTTPStatusCodeCheck.SetCritical() | Out-Null;
                    break;
                };
                3 {
                    $HTTPStatusCodeCheck.SetUnknown() | Out-Null;
                    break;
                };
            }
        } else {
            # Negate
            switch ($HTTPData[$SingleUrl]['StatusCodes'].State) {
                0 {
                    $HTTPStatusCodeCheck.SetCritical() | Out-Null;
                    break;
                };
                1 {
                    $HTTPStatusCodeCheck.SetOk() | Out-Null;
                    break;
                };
                2 {
                    $HTTPStatusCodeCheck.SetOk() | Out-Null;
                    break;
                };
                3 {
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
                    -Translation @{ 'true' = 'Found'; 'false' = 'Not Found' } `
                    -MetricIndex $MetricIndex `
                    -MetricName ([string]::Format('httpcontent_{0}', $ContentKeys));
            } else {
                $HTTPContentMatchPackage = New-IcingaCheck `
                    -Name ([string]::Format('HTTP Content "{0}"', $ContentKeys)) `
                    -Value $HTTPData[$SingleUrl]['Matches'][$ContentKeys] `
                    -LabelName ([string]::Format('{0}.http_content_{1}', $TransformedUrl, $ContentKeys)) `
                    -Translation @{ 'true' = 'Found'; 'false' = 'Not Found' } `
                    -Hidden `
                    -MetricIndex $MetricIndex `
                    -MetricName ([string]::Format('httpcontent_{0}', $ContentKeys));
            }

            if ($HTTPData[$SingleUrl]['Matches'][$ContentKeys] -eq $FALSE) {
                $HTTPContentMatchPackage.SetCritical() | Out-Null;
            } else {
                # Ensure we do not move into INFO state
                $HTTPContentMatchPackage.SetOk() | Out-Null;
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
            $HTTPResponseTimeCheck = New-IcingaCheck -Name "HTTP Response Time" -Value 0 -LabelName ([string]::Format('{0}.http_response_time', $TransformedUrl)) -Unit 's' -Hidden -MetricIndex $MetricIndex -MetricName 'responsetime';
            $HTTPResponseTimeCheck.SetUnknown() | Out-Null;
        } else {
            $HTTPResponseTimeCheck = New-IcingaCheck -Name "HTTP Response Time" -Value $HTTPData.$SingleUrl['RequestTime'] -LabelName ([string]::Format('{0}.http_response_time', $TransformedUrl)) -Unit 's' -MetricIndex $MetricIndex -MetricName 'responsetime';
            $HTTPResponseTimeCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        }
        $HTTPStatusPackage.AddCheck($HTTPResponseTimeCheck);

        # PerfData
        $PerfDataPackage = New-IcingaCheckPackage -Name 'PerfData' -OperatorAnd -Verbose $Verbosity -Hidden -Checks @(
            (New-IcingaCheck -Name 'Content Size' -Value $HTTPData.$SingleUrl['ContentSize'] -Unit 'B' -LabelName ([string]::Format('{0}.http_content_size', $TransformedUrl)) -MetricIndex $MetricIndex -MetricName 'contentsize');
        );
        $HTTPStatusPackage.AddCheck($PerfDataPackage);

        $HTTPAllStatusPackage.AddCheck($HTTPStatusPackage);
    }

    return (New-IcingaCheckResult -Check $HTTPAllStatusPackage -NoPerfData $NoPerfData -Compile);
}
