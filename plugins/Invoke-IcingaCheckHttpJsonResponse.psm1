<#
.SYNOPSIS
    Retrieves a JSON-Object via Request and performs desired checks
.DESCRIPTION
   Invoke-IcingaCheckHttpJsonResponse returns 'OK', 'WARNING' or 'CRITICAL', depending on the parameters Warning and Critical
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check the values in a JSON-Response of a webserver for given thresholds. Based on the defined thresholds the appropriate status is returned.
.EXAMPLE
   PS> Invoke-IcingaCheckHttpJsonResponse -NoPerfData -ServerUri "https://my-server.local:8443" -ServerPath "my/path" -QueryParameter "myPar=1" -Username "superuser" -Pass (ConvertTo-SecureString -String "secretPassword" -AsPlainText -Force) -Verbosity 2 -ValuePaths "myNumberOfItems:numberOfItems","oldestTime:oldestItemTimestamp" -ValueTypes "myNumberOfItems:Numeric","oldestTime:DateTime" -Warning "myNumberOfItems:~:2","oldestTime:-2d" -Critical "myNumberOfItems:~:2","oldestTime:-4d"
    [CRITICAL] HTTP JSON Response Monitor [CRITICAL] Check returned value for oldestTime (2022/01/27 06:54:18)
    \_ [OK] All requested parameters are available in JSON response: 2
    \_ [OK] Check returned value for myNumberOfItems: 2
    \_ [CRITICAL] Check returned value for oldestTime: 2022/01/27 06:54:18 is lower than 2022/03/07 10:01:31 (-4d)
    \_ [OK] Parameters evaluated: 0
    \_ [OK] Response received: False
.EXAMPLE
   PS> Invoke-IcingaCheckHttpJsonResponse -NoPerfData -ServerUri "https://my-server.local:8443" -ServerPath "my/path" -QueryParameter "myPar=1" -Username "superuser" -Pass (ConvertTo-SecureString -String "secretPassword" -AsPlainText -Force) -Verbosity 2 -ValuePaths "myNumberOfItems:numberOfItems","oldestTime:oldestItemTimestamp" -ValueTypes "myNumberOfItems:Numeric","oldestTime:DateTime" -Warning "myNumberOfItems:~:1","oldestTime:-2d" -Critical "myNumberOfItems:~:2","oldestTime:-40d"
    [WARNING] HTTP JSON Response Monitor [WARNING] Check returned value for myNumberOfItems (2), Check returned value for oldestTime (2022/01/27 06:54:18)
    \_ [OK] All requested parameters are available in JSON response: 2
    \_ [WARNING] Check returned value for myNumberOfItems: 2 is greater than threshold 1
    \_ [WARNING] Check returned value for oldestTime: 2022/01/27 06:54:18 is lower than 2022/03/07 10:23:58 (-2d)
    \_ [OK] Parameters evaluated: 0
    \_ [OK] Response received: False
.PARAMETER ServerUri
    Base URI of the server, example "https://example.comm"
.PARAMETER ServerPath
    Path for the request, example "/v1/my_endpoint"
.PARAMETER QueryParameter
    Query parameter for the request without ?, example "command=example"
.PARAMETER Username
    Credentials to use for basic auth
.PARAMETER Password
    Credentials to use for basic auth
.PARAMETER Timeout
    Timeout in seconds before the http request is aborted. Defaults to 30
.PARAMETER ValuePaths
    paths to look for values in the JSON object that is checked, including an alias for each parameter. Example: "myAlias01:value01","myAlias02:nested.object.value02", "myAlias03:'object'.'my.Par.With.Dots'"
.PARAMETER ValueTypes
    Value types of each parameter. Supported Types: Numeric, Boolean, DateTime, String Example: "myAlias01:Numeric","myAlias02:DateTime"
.PARAMETER Warning
    Warning thresholds using icinga-powershell syntax. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"
.PARAMETER Critical
    Critical thresholds using icinga-powershell syntax. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"
.PARAMETER IgnoreSSL
    Disables SSL verification and allows the connection to endpoints with self-signed certificates as example
.PARAMETER StatusOnRequestError
    Status to set when the webservice cannot be reached or an error (e.g. 500) is returned - default is Unknown
    See https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/10-Icinga-Plugins/ for description of threshold values
.PARAMETER NegateStringResults
    Negate the conditions set for string parameters. When this is set to true, WarnIfLike/CritIfLike is used instead of WarnIfNotLike/CritIfNotLike for Strings
.PARAMETER Verbosity
   Changes the behavior of the plugin output which check states are printed:
   0 (default): Only service checks/packages with state not OK will be printed
   1: Only services with not OK will be printed including OK checks of affected check packages including Package config
   2: Everything will be printed regardless of the check state
   3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
#>
function Invoke-IcingaCheckHttpJsonResponse()
{
    param (
        [string]$ServerUri            = '',
        [string]$ServerPath           = '',
        [string]$QueryParameter       = '',
        [string]$Username             = $null,
        [SecureString]$Password       = $null,
        [int]$Timeout                 = 30,
        [array]$ValuePaths            = @(),
        [array]$ValueTypes            = @(),
        [array]$Warning               = @(),
        [array]$Critical              = @(),
        [switch]$IgnoreSSL            = $FALSE,
        [ValidateSet("Unknown", "Warning", "Critical", "OK")]
        [string]$StatusOnRequestError = "Unknown",
        [switch]$NegateStringResults  = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity               = 0,
        [switch]$NoPerfData           = $FALSE
    );

    if ([string]::IsNullOrEmpty($ServerUri)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerUri"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ([string]::IsNullOrEmpty($ServerPath)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerPath"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ($ValuePaths.Count -eq 0) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ValuePaths"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ($ValueTypes.Count -eq 0) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ValueTypes"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    [string]$MetricIndex = [string]::Join('', @($ServerUri, $ServerPath, $QueryParameter));

    $Arguments = @{
        'ServerUri'      = $ServerUri;
        'ServerPath'     = $ServerPath;
        'QueryParameter' = $QueryParameter;
        'Timeout'        = $Timeout;
        'IgnoreSSL'      = $IgnoreSSL;
    };

    if ([string]::IsNullOrEmpty($Username) -eq $FALSE -And $null -ne $Password) {
        $Arguments.Add('Username', $Username);
        $Arguments.Add('Pass', $Password);
    }

    $CheckPackage = New-IcingaCheckPackage -Name 'HTTP JSON Response Monitor' -OperatorAnd -Verbose $Verbosity;

    # Parse Parameter definition
    $parameterDefinitionList = @{ };

    Write-IcingaDebugMessage -Message 'Evaluating parameter definitions: {0}' -Objects $ValuePaths;
    foreach ($pathDefinition in $ValuePaths) {
        if ($pathDefinition.IndexOf(":") -le 0) {
            Write-IcingaDebugMessage -Message 'Format of definition not supported: {0}' -Objects $pathDefinition;
            $parameterDefinitionList = $null;
            break
        }

        $alias = $pathDefinition.Split(":")[0];
        $path  = $pathDefinition.Substring($pathDefinition.IndexOf(":") + 1);
        if ($parameterDefinitionList.ContainsKey($alias) -or [string]::IsNullOrWhiteSpace($pathDefinition)) {
            # duplicate & empty paths keys are not allowed
            Write-IcingaDebugMessage -Message 'Found duplicate parameter {0} - this is not allowed' -Objects $alias;
            $parameterDefinitionList = $null;
            break
        } else {
            Write-IcingaDebugMessage -Message 'Found parameter {0} with path {1}' -Objects $alias, $path;
            $parameterDefinitionList.Add($alias,
                @{
                    Alias = $alias;
                    Path  = $path;
                }
            );
        }
    }

    if ($null -ne $parameterDefinitionList) {
        foreach ($parameterDef in $parameterDefinitionList.Values) {
            # get valuetype
            $arrMatch = $ValueTypes -match ($parameterDef.alias + ":");
            if ($null -eq $arrMatch -or $arrMatch.Length -ne 1) {
                $parameterDefinitionList = $null;
                Write-IcingaDebugMessage -Message 'No valuetype defined for "{0}"' -Objects $($parameterDef.Alias);
                break;
            }
            $parameterDef.Add("ValueType", $arrMatch[0].Substring($arrMatch[0].IndexOf(":") + 1))

            # get warning thresholds
            $arrMatch = $Warning -match ($parameterDef.alias + ":");
            if ($null -ne $arrMatch -and $arrMatch.Length -eq 1) {
                $parameterDef.Add("Warning", $arrMatch[0].Substring($arrMatch[0].IndexOf(":") + 1));
            }

            # get critical thresholds
            $arrMatch = $Critical -match ($parameterDef.alias + ":")
            if ($null -ne $arrMatch -and $arrMatch.Length -eq 1) {
                $parameterDef.Add("Critical", $arrMatch[0].Substring($arrMatch[0].IndexOf(":") + 1));
            }

            if ($null -eq $parameterDef.Warning -and $null -eq $parameterDef.Critical) {
                Write-IcingaDebugMessage -Message 'No thresholds defined for "{0}"' -Objects $($parameterDef.Alias);
                $parameterDefinitionList = $null;
                break
            }
        }
    }

    Write-IcingaDebugMessage -Message 'Done evaluating parameters';
    # End parsing parameter definition

    $ParameterCheck = New-IcingaCheck -Name 'Parameters evaluated' -Value $parameterDefinitionList.Count -ObjectExists $parameterDefinitionList -MetricIndex $MetricIndex -MetricName 'parametercount';
    $CheckPackage.AddCheck($ParameterCheck);

    if ($null -ne $parameterDefinitionList) {
        $JsonObjectToCheck    = $null;
        $ErrorOnRequest       = $FALSE;
        $ErrorMessageResponse = '';

        try {
            $JsonObjectToCheck = Get-IcingaHttpResponse @Arguments;
        } catch {
            $ErrorMessageResponse = $_;
            $ErrorOnRequest       = $TRUE;
        }

        $GotResponseCheck = New-IcingaCheck -Name 'Response received' -Value $TRUE -MetricIndex $MetricIndex -MetricName 'hasresponse' -Translation @{ 'true' = 'Yes' };

        if ($ErrorOnRequest) {
            switch ($StatusOnRequestError) {
                'Unknown' {
                    # a new check has to be created, since objectexists was not specified above
                    $GotResponseCheck = New-IcingaCheck -Name 'Response received' -Value $FALSE -ObjectExists $JsonObjectToCheck -MetricIndex $MetricIndex -MetricName 'hasresponse';
                    # nothing to do, since the response is null and objectexists leads to unknown
                    break;
                };
                'Warning' {
                    $GotResponseCheck = New-IcingaCheck -Name 'Response received' -Value $FALSE -MetricIndex $MetricIndex -MetricName 'hasresponse' -Translation @{ 'false' = $ErrorMessageResponse; 'true' = 'Connected' };
                    $GotResponseCheck.WarnIfNotMatch($TRUE) | Out-Null;
                    #$GotResponseCheck.SetWarning($ErrorMessageResponse, $TRUE) | Out-Null;
                    break;
                };
                'Critical' {
                    $GotResponseCheck = New-IcingaCheck -Name 'Response received' -Value $FALSE -MetricIndex $MetricIndex -MetricName 'hasresponse' -Translation @{ 'false' = $ErrorMessageResponse; 'true' = 'Connected' };
                    $GotResponseCheck.CritIfNotMatch($TRUE) | Out-Null;
                    #$GotResponseCheck.SetCritical($ErrorMessageResponse, $TRUE) | Out-Null;
                    break;
                };
                'OK' {
                    # Nothing to do
                    break;
                };
            }
        }

        $CheckPackage.AddCheck($GotResponseCheck)

        if ($ErrorOnRequest -eq $FALSE -and $null -ne $JsonObjectToCheck) {
            # get icinga-checks for all parameters defined and add them to the checkpackage
            [System.Collections.Generic.List[System.Object]]$listOfChecks = Get-IcingaCheckHttpJsonResponseChecks -ParameterDefinitionList $parameterDefinitionList -JsonObjectToCheck $JsonObjectToCheck -NegateStringResults:$NegateStringResults -MetricIndex $MetricIndex;
            foreach ($check in $listOfChecks) {
                $CheckPackage.AddCheck($check);
            }

            $ParametersAvailableCheck = New-IcingaCheck -Name 'All requested parameters are available in JSON response' -Value $listOfChecks.Count -MetricIndex $MetricIndex -MetricName 'values';
            $ParametersAvailableCheck.WarnIfLowerThan($parameterDefinitionList.Count) | Out-Null;
            $CheckPackage.AddCheck($ParametersAvailableCheck);
        }
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
