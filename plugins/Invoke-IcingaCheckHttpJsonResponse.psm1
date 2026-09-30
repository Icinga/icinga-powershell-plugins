<#
.SYNOPSIS
    Retrieves a JSON-Object via Request or from a file and performs desired checks
.DESCRIPTION
   Invoke-IcingaCheckHttpJsonResponse returns 'OK', 'WARNING' or 'CRITICAL', depending on the parameters Warning and Critical
   The JSON-Object is either fetched from a webserver by using -ServerUri and -ServerPath or read from a local or UNC file by using -FilePath

   To detect files which are no longer updated by the application writing them, use Invoke-IcingaCheckDirectory as additional service, for example:
   Invoke-IcingaCheckDirectory -Path 'C:\ProgramData\monitoring' -FileNames 'mailserver_connect.json' -ChangeYoungerThan '15m' -Critical '1:'

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check the values in a JSON-Response of a webserver or a JSON file for given thresholds. Based on the defined thresholds the appropriate status is returned.
   Values can also be printed as information or forwarded as raw performance data, allowing to monitor JSON files written by other monitoring scripts.
   The third example reads a file with the following content:
   { "StateField": 2, "MessageField": "This is a test message", "PerfDataField": "'cpu-usage'=5.6%;80;90;0;100" }
   The fourth example shows the integration of the Icinga for Windows REST-Api, by executing Invoke-IcingaCheckCPU with the api checks feature
   and forwarding its exit code, plugin output and performance data.
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
.EXAMPLE
   PS> Invoke-IcingaCheckHttpJsonResponse -FilePath 'C:\ProgramData\monitoring\mailserver_connect.json' -ValuePaths 'VariableState:StateField','VariableMessage:MessageField','VariablePerfData:PerfDataField' -ValueTypes 'VariableState:Numeric','VariableMessage:Info','VariablePerfData:PerfData' -Warning 'VariableState:0' -Critical 'VariableState:1' -Verbosity 1
    [CRITICAL] HTTP JSON Response Monitor [CRITICAL] Check returned value for VariableState
    \_ [OK] All requested parameters are available in JSON response: 3
    \_ [INFO] Check returned value for VariableMessage: This is a test message
    \_ [CRITICAL] Check returned value for VariableState: Value 2 is greater than threshold 1
    \_ [INFO] Parameters evaluated: 3
    \_ [INFO] Response received: Yes
    | cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponse::values=3;3:;;; cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponsecheckvalue::variablestate=2;0;1;; cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponse::parametercount=3;;;; cpu-usage=5.6%;80;90;0;100
.EXAMPLE
   PS> Invoke-IcingaCheckHttpJsonResponse -ServerUri 'https://localhost:5668' -ServerPath 'v1/checker' -QueryParameter 'command=cpu' -ValuePaths 'MyExitCode:Invoke-IcingaCheckCPU.exitcode', 'MyOutput:Invoke-IcingaCheckCPU.checkresult', 'MyPerfData:Invoke-IcingaCheckCPU.perfdata' -ValueTypes 'MyExitCode:Numeric', 'MyOutput:Info', 'MyPerfData:PerfData' -Warning 'MyExitCode:-1' -Verbosity 2 -IgnoreSSL
    [WARNING] HTTP JSON Response Monitor [WARNING] Check returned value for MyExitCode
    \_ [OK] All requested parameters are available in JSON response: 3
    \_ [WARNING] Check returned value for MyExitCode: Value 0 is greater than threshold -1
    \_ [INFO] Check returned value for MyOutput: [INFO] CPU Load
    \_ [INFO] Parameters evaluated: 3
    \_ [INFO] Response received: Yes
    | httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponse::values=3;3:;;; httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponsecheckvalue::myexitcode=0;-1;;; httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponse::parametercount=3;;;; totalload::ifw_cpu::load=10.923052%;;;0;100 0_0::ifw_cpu::load=19.5434%;;;0;100 0_total::ifw_cpu::load=19.5434%;;;0;100 1_1::ifw_cpu::load=17.24464%;;;0;100 1_total::ifw_cpu::load=17.24464%;;;0;100 2_2::ifw_cpu::load=3.452083%;;;0;100 2_total::ifw_cpu::load=3.452083%;;;0;100 3_3::ifw_cpu::load=3.452083%;;;0;100 3_total::ifw_cpu::load=3.452083%;;;0;100
.PARAMETER ServerUri
    Base URI of the server, example "https://example.comm"
.PARAMETER ServerPath
    Path for the request, example "/v1/my_endpoint"
.PARAMETER QueryParameter
    Query parameter for the request without ?, example "command=example"
.PARAMETER FilePath
    Path to a local or UNC JSON file to read instead of sending a web request, example "C:\ProgramData\monitoring\mailserver_connect.json"
    If set, -ServerUri, -ServerPath, -QueryParameter, -Username, -Password, -Timeout and -IgnoreSSL are ignored
    If the file does not exist, the plugin will throw an exception and return UNKNOWN
.PARAMETER Username
    Credentials to use for basic auth
.PARAMETER Password
    Credentials to use for basic auth
.PARAMETER Timeout
    Timeout in seconds before the http request is aborted. Defaults to 30. Not used in combination with -FilePath
.PARAMETER ValuePaths
    Values to read from the JSON object in the format `Variable:JsonField`. The variable is the name used by the plugin
    to reference the value within -ValueTypes, -Warning and -Critical and inside the plugin output, the JSON field is the path
    of the value inside the JSON object. Nested fields are separated by a dot.
    Example: "VariableState:StateField","VariableItems:nested.object.ItemsField"
.PARAMETER ValueTypes
    Value types of each variable in the format `Variable:Type`. Supported Types: Numeric, Boolean, DateTime, String, Info, PerfData
    Info: The value is printed as information without thresholds and does not change the plugin state. Information is shown with -Verbosity 1 in case the plugin is not OK and always with -Verbosity 2
    PerfData: The value is forwarded as performance data string, e.g. "'cpu-usage'=5.6%;80;90;0;100". Single and double quotes are removed and spaces inside labels are replaced by _, resulting in cpu-usage=5.6%;80;90;0;100
    Example: "VariableState:Numeric","VariableTime:DateTime","VariableMessage:Info","VariablePerfData:PerfData"
.PARAMETER Warning
    Warning thresholds using icinga-powershell syntax in the format `Variable:Threshold`. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"
    String values are compared with -like, supporting wildcards like * and ?. A threshold without wildcards is compared for equality.
    By default a warning is returned if the value is like the threshold, prefix the threshold with ! to return a warning if the value is not like the threshold.
    Example: "myStringAlias:*degraded*", "myStringAlias:failed", "myStringAlias:!OK"
.PARAMETER Critical
    Critical thresholds using icinga-powershell syntax in the format `Variable:Threshold`. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"
    String values are compared with -like, supporting wildcards like * and ?. A threshold without wildcards is compared for equality.
    By default a critical is returned if the value is like the threshold, prefix the threshold with ! to return a critical if the value is not like the threshold.
    Example: "myStringAlias:*degraded*", "myStringAlias:failed", "myStringAlias:!OK"
.PARAMETER IgnoreSSL
    Disables SSL verification and allows the connection to endpoints with self-signed certificates as example
.PARAMETER StatusOnRequestError
    Status to set when the webservice cannot be reached, an error (e.g. 500) is returned or the existing file provided by -FilePath cannot be read, e.g. because of invalid JSON content - default is Unknown
    See https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/10-Icinga-Plugins/ for description of threshold values
.PARAMETER NegateStringResults
    Inverts every string comparison. Thresholds without ! prefix will return a warning or critical if the value is not like the threshold,
    thresholds with ! prefix if the value is like the threshold
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
        [string]$FilePath             = '',
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

    [bool]$UseFile = ([string]::IsNullOrEmpty($FilePath) -eq $FALSE);

    if ($UseFile) {
        if ((Test-Path -LiteralPath $FilePath -PathType Leaf) -eq $FALSE) {
            Exit-IcingaThrowException -Force -CustomMessage '"-FilePath" is not directing to an existing file' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentConflict;
        }
    } else {
        if ([string]::IsNullOrEmpty($ServerUri)) {
            Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerUri"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
        }

        if ([string]::IsNullOrEmpty($ServerPath)) {
            Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ServerPath"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
        }
    }

    if ($ValuePaths.Count -eq 0) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ValuePaths"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ($ValueTypes.Count -eq 0) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ValueTypes"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    [string]$MetricIndex = [string]::Join('', @($ServerUri, $ServerPath, $QueryParameter));

    if ($UseFile) {
        $MetricIndex = $FilePath;
    }

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

            if ($parameterDef.ValueType -eq 'Info' -or $parameterDef.ValueType -eq 'PerfData') {
                continue;
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

    $RawPerfData = @();

    if ($null -ne $parameterDefinitionList) {
        $JsonObjectToCheck    = $null;
        $ErrorOnRequest       = $FALSE;
        $ErrorMessageResponse = '';

        if ($UseFile) {
            $JsonFile             = Read-IcingaJsonFile -Path $FilePath;
            $JsonObjectToCheck    = $JsonFile.Content;
            $ErrorMessageResponse = $JsonFile.Error;
            $ErrorOnRequest       = ($null -eq $JsonFile.Content);
        } else {
            try {
                $JsonObjectToCheck = Get-IcingaHttpResponse @Arguments;
            } catch {
                $ErrorMessageResponse = $_;
                $ErrorOnRequest       = $TRUE;
            }
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
            $JsonResults = Get-IcingaCheckHttpJsonResponseChecks -ParameterDefinitionList $parameterDefinitionList -JsonObjectToCheck $JsonObjectToCheck -NegateStringResults:$NegateStringResults -MetricIndex $MetricIndex;
            foreach ($check in $JsonResults.Checks) {
                $CheckPackage.AddCheck($check);
            }

            $RawPerfData = $JsonResults.PerfData;

            $ParametersAvailableCheck = New-IcingaCheck -Name 'All requested parameters are available in JSON response' -Value ($JsonResults.Checks.Count + $JsonResults.PerfData.Count) -MetricIndex $MetricIndex -MetricName 'values';
            $ParametersAvailableCheck.WarnIfLowerThan($parameterDefinitionList.Count) | Out-Null;
            $CheckPackage.AddCheck($ParametersAvailableCheck);
        }
    }

    $ExitCode = New-IcingaCheckResult -Check $CheckPackage -NoPerfData $TRUE -Compile;

    if ($NoPerfData -eq $FALSE) {
        foreach ($entry in $RawPerfData) {
            if ([string]::IsNullOrEmpty($entry)) {
                continue;
            }

            if ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Length -ne 0) {
                $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Append(' ') | Out-Null;
            }

            $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Append($entry) | Out-Null;
        }

        Write-IcingaPluginPerfData;
    }

    return $ExitCode;
}
