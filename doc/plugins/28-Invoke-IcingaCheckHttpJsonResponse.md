# Invoke-IcingaCheckHttpJsonResponse

## Description

Retrieves a JSON-Object via Request or from a file and performs desired checks

Invoke-IcingaCheckHttpJsonResponse returns 'OK', 'WARNING' or 'CRITICAL', depending on the parameters Warning and Critical
The JSON-Object is either fetched from a webserver by using -ServerUri and -ServerPath or read from a local or UNC file by using -FilePath

To detect files which are no longer updated by the application writing them, use Invoke-IcingaCheckDirectory as additional service, for example:
Invoke-IcingaCheckDirectory -Path 'C:\ProgramData\monitoring' -FileNames 'mailserver_connect.json' -ChangeYoungerThan '15m' -Critical '1:'

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| ServerUri | String | false |  | Base URI of the server, example "https://example.comm" |
| ServerPath | String | false |  | Path for the request, example "/v1/my_endpoint" |
| QueryParameter | String | false |  | Query parameter for the request without ?, example "command=example" |
| FilePath | String | false |  | Path to a local or UNC JSON file to read instead of sending a web request, example "C:\ProgramData\monitoring\mailserver_connect.json"<br /> If set, -ServerUri, -ServerPath, -QueryParameter, -Username, -Password, -Timeout and -IgnoreSSL are ignored<br /> If the file does not exist, the plugin will throw an exception and return UNKNOWN |
| Username | String | false |  | Credentials to use for basic auth |
| Password | SecureString | false |  | Credentials to use for basic auth |
| Timeout | Int32 | false | 30 | Timeout in seconds before the http request is aborted. Defaults to 30. Not used in combination with -FilePath |
| ValuePaths | Array | false | @() | Values to read from the JSON object in the format `Variable:JsonField`. The variable is the name used by the plugin<br /> to reference the value within -ValueTypes, -Warning and -Critical and inside the plugin output, the JSON field is the path<br /> of the value inside the JSON object. Nested fields are separated by a dot.<br /> Example: "VariableState:StateField","VariableItems:nested.object.ItemsField" |
| ValueTypes | Array | false | @() | Value types of each variable in the format `Variable:Type`. Supported Types: Numeric, Boolean, DateTime, String, Info, PerfData<br /> Info: The value is printed as information without thresholds and does not change the plugin state. Information is shown with -Verbosity 1 in case the plugin is not OK and always with -Verbosity 2<br /> PerfData: The value is forwarded as performance data string, e.g. "'cpu-usage'=5.6%;80;90;0;100". Single and double quotes are removed and spaces inside labels are replaced by _, resulting in cpu-usage=5.6%;80;90;0;100<br /> Example: "VariableState:Numeric","VariableTime:DateTime","VariableMessage:Info","VariablePerfData:PerfData" |
| Warning | Array | false | @() | Warning thresholds using icinga-powershell syntax in the format `Variable:Threshold`. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"<br /> String values are compared with -like, supporting wildcards like * and ?. A threshold without wildcards is compared for equality.<br /> By default a warning is returned if the value is like the threshold, prefix the threshold with ! to return a warning if the value is not like the threshold.<br /> Example: "myStringAlias:*degraded*", "myStringAlias:failed", "myStringAlias:!OK" |
| Critical | Array | false | @() | Critical thresholds using icinga-powershell syntax in the format `Variable:Threshold`. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True"<br /> String values are compared with -like, supporting wildcards like * and ?. A threshold without wildcards is compared for equality.<br /> By default a critical is returned if the value is like the threshold, prefix the threshold with ! to return a critical if the value is not like the threshold.<br /> Example: "myStringAlias:*degraded*", "myStringAlias:failed", "myStringAlias:!OK" |
| IgnoreSSL | SwitchParameter | false | False | Disables SSL verification and allows the connection to endpoints with self-signed certificates as example |
| StatusOnRequestError | String | false | Unknown | Status to set when the webservice cannot be reached, an error (e.g. 500) is returned or the existing file provided by -FilePath cannot be read, e.g. because of invalid JSON content - default is Unknown<br /> See https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/10-Icinga-Plugins/ for description of threshold values |
| NegateStringResults | SwitchParameter | false | False | Inverts every string comparison. Thresholds without ! prefix will return a warning or critical if the value is not like the threshold,<br /> thresholds with ! prefix if the value is like the threshold |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHttpJsonResponse -NoPerfData -ServerUri "https://my-server.local:8443" -ServerPath "my/path" -QueryParameter "myPar=1" -Username "superuser" -Pass (ConvertTo-SecureString -String "secretPassword" -AsPlainText -Force) -Verbosity 2 -ValuePaths "myNumberOfItems:numberOfItems","oldestTime:oldestItemTimestamp" -ValueTypes "myNumberOfItems:Numeric","oldestTime:DateTime" -Warning "myNumberOfItems:~:2","oldestTime:-2d" -Critical "myNumberOfItems:~:2","oldestTime:-4d"
```

### Example Output 1

```powershell
[CRITICAL] HTTP JSON Response Monitor [CRITICAL] Check returned value for oldestTime (2022/01/27 06:54:18)
 \_ [OK] All requested parameters are available in JSON response: 2
 \_ [OK] Check returned value for myNumberOfItems: 2
 \_ [CRITICAL] Check returned value for oldestTime: 2022/01/27 06:54:18 is lower than 2022/03/07 10:01:31 (-4d)
 \_ [OK] Parameters evaluated: 0
 \_ [OK] Response received: False    
```

### Example Command 2

```powershell
Invoke-IcingaCheckHttpJsonResponse -NoPerfData -ServerUri "https://my-server.local:8443" -ServerPath "my/path" -QueryParameter "myPar=1" -Username "superuser" -Pass (ConvertTo-SecureString -String "secretPassword" -AsPlainText -Force) -Verbosity 2 -ValuePaths "myNumberOfItems:numberOfItems","oldestTime:oldestItemTimestamp" -ValueTypes "myNumberOfItems:Numeric","oldestTime:DateTime" -Warning "myNumberOfItems:~:1","oldestTime:-2d" -Critical "myNumberOfItems:~:2","oldestTime:-40d"
```

### Example Output 2

```powershell
[WARNING] HTTP JSON Response Monitor [WARNING] Check returned value for myNumberOfItems (2), Check returned value for oldestTime (2022/01/27 06:54:18)
 \_ [OK] All requested parameters are available in JSON response: 2
 \_ [WARNING] Check returned value for myNumberOfItems: 2 is greater than threshold 1
 \_ [WARNING] Check returned value for oldestTime: 2022/01/27 06:54:18 is lower than 2022/03/07 10:23:58 (-2d)
 \_ [OK] Parameters evaluated: 0
 \_ [OK] Response received: False    
```

### Example Command 3

```powershell
Invoke-IcingaCheckHttpJsonResponse -FilePath 'C:\ProgramData\monitoring\mailserver_connect.json' -ValuePaths 'VariableState:StateField','VariableMessage:MessageField','VariablePerfData:PerfDataField' -ValueTypes 'VariableState:Numeric','VariableMessage:Info','VariablePerfData:PerfData' -Warning 'VariableState:0' -Critical 'VariableState:1' -Verbosity 1
```

### Example Output 3

```powershell
[CRITICAL] HTTP JSON Response Monitor [CRITICAL] Check returned value for VariableState
 \_ [OK] All requested parameters are available in JSON response: 3
 \_ [INFO] Check returned value for VariableMessage: This is a test message
 \_ [CRITICAL] Check returned value for VariableState: Value 2 is greater than threshold 1
 \_ [INFO] Parameters evaluated: 3
 \_ [INFO] Response received: Yes
 | cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponse::values=3;3:;;; cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponsecheckvalue::variablestate=2;0;1;; cprogramdatamonitoringmailserverconnectjson::ifw_httpjsonresponse::parametercount=3;;;; cpu-usage=5.6%;80;90;0;100    
```

### Example Command 4

```powershell
Invoke-IcingaCheckHttpJsonResponse -ServerUri 'https://localhost:5668' -ServerPath 'v1/checker' -QueryParameter 'command=cpu' -ValuePaths 'MyExitCode:Invoke-IcingaCheckCPU.exitcode', 'MyOutput:Invoke-IcingaCheckCPU.checkresult', 'MyPerfData:Invoke-IcingaCheckCPU.perfdata' -ValueTypes 'MyExitCode:Numeric', 'MyOutput:Info', 'MyPerfData:PerfData' -Warning 'MyExitCode:-1' -Verbosity 2 -IgnoreSSL
```

### Example Output 4

```powershell
[WARNING] HTTP JSON Response Monitor [WARNING] Check returned value for MyExitCode
 \_ [OK] All requested parameters are available in JSON response: 3
 \_ [WARNING] Check returned value for MyExitCode: Value 0 is greater than threshold -1
 \_ [INFO] Check returned value for MyOutput: [INFO] CPU Load
 \_ [INFO] Parameters evaluated: 3
 \_ [INFO] Response received: Yes
 | httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponse::values=3;3:;;; httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponsecheckvalue::myexitcode=0;-1;;; httpslocalhost5668v1checkercommandcpu::ifw_httpjsonresponse::parametercount=3;;;; totalload::ifw_cpu::load=10.923052%;;;0;100 0_0::ifw_cpu::load=19.5434%;;;0;100 0_total::ifw_cpu::load=19.5434%;;;0;100 1_1::ifw_cpu::load=17.24464%;;;0;100 1_total::ifw_cpu::load=17.24464%;;;0;100 2_2::ifw_cpu::load=3.452083%;;;0;100 2_total::ifw_cpu::load=3.452083%;;;0;100 3_3::ifw_cpu::load=3.452083%;;;0;100 3_total::ifw_cpu::load=3.452083%;;;0;100    
```


