# Invoke-IcingaCheckHttpJsonResponse

## Description

Retrieves a JSON-Object via Request and performs desired checks

Invoke-IcingaCheckHttpJsonResponse returns 'OK', 'WARNING' or 'CRITICAL', depending on the parameters Warning and Critical
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| ServerUri | String | false |  | Base URI of the server, example "https://example.comm" |
| ServerPath | String | false |  | Path for the request, example "/v1/my_endpoint" |
| QueryParameter | String | false |  | Query parameter for the request without ?, example "command=example" |
| Username | String | false |  | Credentials to use for basic auth |
| Password | SecureString | false |  | Credentials to use for basic auth |
| Timeout | Int32 | false | 30 | Timeout in seconds before the http request is aborted. Defaults to 30 |
| ValuePaths | Array | false | @() | paths to look for values in the JSON object that is checked, including an alias for each parameter. Example: "myAlias01:value01","myAlias02:nested.object.value02", "myAlias03:'object'.'my.Par.With.Dots'" |
| ValueTypes | Array | false | @() | Value types of each parameter. Supported Types: Numeric, Boolean, DateTime, String Example: "myAlias01:Numeric","myAlias02:DateTime" |
| Warning | Array | false | @() | Warning thresholds using icinga-powershell syntax. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True" |
| Critical | Array | false | @() | Critical thresholds using icinga-powershell syntax. Example: "myNumericAlias01:~:2","myDateTimeAlias:-10d", "myBooleanAlias:True" |
| IgnoreSSL | SwitchParameter | false | False | Disables SSL verification and allows the connection to endpoints with self-signed certificates as example |
| StatusOnRequestError | String | false | Unknown | Status to set when the webservice cannot be reached or an error (e.g. 500) is returned - default is Unknown See https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/10-Icinga-Plugins/ for description of threshold values |
| NegateStringResults | SwitchParameter | false | False | Negate the conditions set for string parameters. When this is set to true, WarnIfLike/CritIfLike is used instead of WarnIfNotLike/CritIfNotLike for Strings |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NoPerfData | SwitchParameter | false | False |  |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

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


