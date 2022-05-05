
# Invoke-IcingaCheckHTTPStatus

## Description

Checks the response time, the return code and content of HTTP requests.

Invoke-IcingaCheckHTTPStatus returns either 'OK', 'WARNING' or 'CRITICAL', wether components of the check match or not.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify the webrequest response time warning threshold in seconds, everything past that threshold is considered a WARNING. |
| Critical | Object | false |  | Used to specify the webrequest response time critical threshold in seconds, everything past that threshold is considered a CRITICAL. |
| Url | Array | false | @() | Used to specify the URL of the host to check http as string. Use 'http://' or 'https://' to actively chose a protocol. Likewise ':80' or any other port number to specify a port, etc. |
| VHost | String | false |  | Used to specify a VHost as string. |
| Headers | Array | false | @() | Used to specify headers as Array. Like: -Headers 'Accept:application/json' |
| Timeout | Int32 | false | 10 | Used to specify the timeout in seconds of the webrequest as integer. The default is 10 for 10 seconds. |
| Username | String | false |  | Used to specify a username as string to authenticate with. Authentication is only possible with 'https://'. Use with: -Password |
| Password | SecureString | false |  | Used to specify a password as securestring to authenticate with. Authentication is only possible with 'https://'.Use with: -Username |
| ProxyUsername | String | false |  | Used to specify a proxy username as string to authenticate with. Use with: -ProxyPassword & -ProxyServer |
| ProxyPassword | SecureString | false |  | Used to specify a proxy password as securestring to authenticate with. Use with: -ProxyUsername & -ProxyServer |
| ProxyServer | String | false |  | Used to specify a proxy server as string to authenticate with. |
| Content | Array | false | @() | Used to specify an array of regex-match-strings to match against the content of the webrequest response. |
| StatusCode | Array | false | @() |  |
| Minimum | Int32 | false | -1 |  |
| Negate | SwitchParameter | false | False | A switch used to invert check results. |
| AddOutputContent | SwitchParameter | false | False | Adds the returned content of a website to the plugin output for debugging purpose |
| ConnectionErrAsCrit | SwitchParameter | false | False | By default the plugin will return UNKNOWN in case a connection to a webserver is not possible. By using this flag, the result will be modified from UNKNOWN to CRITICAL |
| NoPerfData | SwitchParameter | false | False | Used to disable PerfData. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content "Test" -Warning 1 -Verbosity 3
```

### Example Output 1

```powershell
[OK] Check package "HTTP Status Check" (Match All)
\_ [OK] Check package "HTTP Content Check" ()
   \_ [OK] HTTP Content "Test": True
   \_ [OK] HTTP Response Time: 0.508972s
   \_ [OK] HTTP Status Code: 200
| 'http_content_test'=1;; 'http_response_time'=0.508972s;1; 'http_status'=200;; 'http_content_size'=47917B;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content "FooBar" -Warning 1 -Verbosity 3}
```

### Example Output 2

```powershell
[OK] Check package "HTTP Status Check" (Match All)
\_ [OK] Check package "HTTP Content Check" ()
\_ [CRITICAL] HTTP Content "FooBar"
   \_ [OK] HTTP Response Time: 0.251071s
   \_ [OK] HTTP Status Code: 200
| 'http_content_foobar'=0;; 'http_response_time'=0.251071s;1; 'http_status'=200;; 'http_content_size'=89970B;;    
```
