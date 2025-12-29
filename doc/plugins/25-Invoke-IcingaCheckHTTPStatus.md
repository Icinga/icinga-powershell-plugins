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
| Warning | Object | false |  | Used to specify the web request response time warning threshold in seconds, everything past that threshold is considered a WARNING. |
| Critical | Object | false |  | Used to specify the web request response time critical threshold in seconds, everything past that threshold is considered a CRITICAL. |
| Url | Array | false | @() | Used to specify the URL of the host to check http as string. Use 'http://' or 'https://' to actively chose a protocol. Likewise ':80' or any other port number to specify a port, etc. |
| VHost | String | false |  | Used to specify a VHost as string. |
| Headers | Array | false | @() | Used to specify headers as Array. Like: -Headers 'Accept:application/json' |
| Timeout | Int32 | false | 10 | Used to specify the timeout in seconds of the web request as integer. The default is 10 for 10 seconds. |
| Username | String | false |  | Used to specify a username as string to authenticate with. Authentication is only possible with 'https://'. Use with: -Password |
| Password | SecureString | false |  | Used to specify a password as secure string to authenticate with. Authentication is only possible with 'https://'.Use with: -Username |
| ProxyUsername | String | false |  | Used to specify a proxy username as string to authenticate with. Use with: -ProxyPassword & -ProxyServer |
| ProxyPassword | SecureString | false |  | Used to specify a proxy password as secure string to authenticate with. Use with: -ProxyUsername & -ProxyServer |
| ProxyServer | String | false |  | Used to specify a proxy server as string to authenticate with. |
| Content | Array | false | @() | Used to specify an array of regex-match-strings to match against the content of the web request response. |
| StatusCode | Array | false | @() | Used to specify expected HTTP status code as array. Multiple status codes which are considered 'OK' can be used.<br /> This overwrites the default outcomes for HTTP status codes:<br /> <   200      Unknown<br />     200-399  OK<br />     400-499  Warning<br />     500-599  Critical<br /> >=  600      Unknown |
| Minimum | Int32 | false | -1 | Used to specify the minimum number of content matches that must be found to consider the content check as 'OK'.<br /> If not specified, all content matches must be found. |
| StatusMinimum | Int32 | false | -1 | Used to specify the minimum number of of the 'HTTP Status Check' package checks that must be 'OK' to consider the overall check as 'OK'.<br /> This will evaluate the entire package of the Url check, including Status Code, Content Matches and Response Time.<br /> If not specified, all checks must be 'OK' in order for the overall check to be 'OK'. |
| Negate | SwitchParameter | false | False | A switch used to invert check results. |
| AddOutputContent | SwitchParameter | false | False | Adds the returned content of a website to the plugin output for debugging purpose |
| ConnectionErrAsCrit | SwitchParameter | false | False | By default the plugin will return UNKNOWN in case a connection to a webserver is not possible. By using this<br /> flag, the result will be modified from UNKNOWN to CRITICAL |
| IgnoreSSL | SwitchParameter | false | False | Use this flag to ignore SSL errors in case your endpoints are not trusted by the client or you are using self-signed certificates. |
| NoPerfData | SwitchParameter | false | False | Used to disable PerfData. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content 'Test' -Warning 1 -Verbosity 3;
```

### Example Output 1

```powershell
Check the HTTP status of a website and lookup a specific content text element

[OK] HTTP Status Check: 1 Ok (Atleast 1 must be [OK])
\_ [OK] HTTP Status Check https://icinga.com (All must be [OK])
    \_ [OK] HTTP Content Check (Atleast 1 must be [OK])
        \_ [OK] HTTP Content "Test": Found
    \_ [OK] HTTP Response Time: 144ms
    \_ [OK] HTTP Status Code: 200
| https_icinga_com::ifw_httpstatus::responsetime=0.144446s;1;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckHTTPStatus -URL https://icinga.com -StatusCode 200,105 -Content 'FooBar' -Warning 1 -Verbosity 3;
```

### Example Output 2

```powershell
Check the HTTP status of a website and lookup a specific content text element. Report CRITICAL on missing content

[CRITICAL] HTTP Status Check: 1 Critical [CRITICAL] HTTP Status Check https://icinga.com (Atleast 1 must be [OK])
\_ [CRITICAL] HTTP Status Check https://icinga.com (All must be [OK])
    \_ [CRITICAL] HTTP Content Check (Atleast 1 must be [OK])
        \_ [CRITICAL] HTTP Content "FooBar": Not Found
    \_ [OK] HTTP Response Time: 226ms
    \_ [OK] HTTP Status Code: 200
| https_icinga_com::ifw_httpstatus::responsetime=0.225516s;1;;; https_icinga_com::ifw_httpstatus::statuscode=200;;;; https_icinga_com::ifw_httpstatus::contentsize=467701B;;;;    
```

### Example Command 3

```powershell
Invoke-IcingaCheckHTTPStatus -Url 'https://netways.de', 'https://icinga.com' -Content 'Experten' -StatusMinimum 1 -Verbosity 3;
```

### Example Output 3

```powershell
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
```

### Example Command 4

```powershell
Invoke-IcingaCheckHTTPStatus -Url 'https://netways.de', 'https://icinga.com' -Verbosity 3 -Content 'Experten', 'team' -Minimum 1;
```

### Example Output 4

```powershell
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
```


