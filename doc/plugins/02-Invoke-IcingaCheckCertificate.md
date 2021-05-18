
# Invoke-IcingaCheckCertificate

## Description

Check whether a certificate is still trusted and when it runs out or starts.

Invoke-IcingaCheckCertificate returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g a certificate will run out in 30 days, WARNING is set to '20d:', CRITICAL is set to '50d:'. In this case the check will return 'WARNING'.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Trusted | SwitchParameter | false | False | Used to switch on trusted behavior. Whether to check, If the certificate is trusted by the system root. Will return Critical in case of untrusted.  Note: it is currently required that the root and intermediate CA is known and trusted by the local system. |
| CriticalStart | Object | false |  | Used to specify a date. The start date of the certificate has to be past the date specified, otherwise the check results in critical. Use carefully. Use format like: 'yyyy-MM-dd' |
| WarningEnd | Object | false | 30d: | Used to specify a Warning range for the end date of an certificate. In this case a string. Allowed units include: ms, s, m, h, d, w, M, y |
| CriticalEnd | Object | false | 10d: | Used to specify a Critical range for the end date of an certificate. In this case a string. Allowed units include: ms, s, m, h, d, w, M, y |
| CertStore | String | false | * | Used to specify which CertStore to check. Valid choices are '*', 'LocalMachine', 'CurrentUser' |
| CertThumbprint | Array | false |  | Used to specify an array of Thumbprints, which are used to determine what certificate to check, within the CertStore. |
| CertSubject | Array | false |  | Used to specify an array of Subjects, which are used to determine what certificate to check, within the CertStore. |
| CertStorePath | Object | false | * | Used to specify which path within the CertStore should be checked. |
| CertPaths | Array | false |  | Used to specify an array of paths on your system, where certificate files are. Use with CertName. |
| CertName | Array | false |  | Used to specify an array of certificate names of certificate files to check. Use with CertPaths. |
| Recurse | SwitchParameter | false | False | Includes sub-directories and entries while looking for certificates on a given path |
| IgnoreEmpty | SwitchParameter | false | False | Will return `OK` instead of `UNKNOWN`, in case no certificates for the given filter and path were found |
| Verbosity | Int32 | false | 3 | Other |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
You can check certificates in the local certificate store of Windows:
```

### Example Output 1

```powershell
PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertSubject '*' -WarningEnd '30d:' -CriticalEnd '10d:'[OK] Check package "Certificates" (Match All)\_ [OK] Certificate 'test.example.com' (valid until 2033-11-19 : 4993d) valid for: 431464965.59
```

### Example Command 2

```powershell
Also a directory with a file name pattern is possible:
```

### Example Output 2

```powershell
PS> Invoke-IcingaCheckCertificate -CertPaths "C:\ProgramData\icinga2\var\lib\icinga2\certs" -CertName '*.crt' -WarningEnd '10000d:'[WARNING] Check package "Certificates" (Match All) - [WARNING] Certificate 'test.example.com' (valid until 2033-11-19 : 4993d) valid for, Certificate 'Icinga CA' (valid until 2032-09-18 : 4566d) valid for\_ [WARNING] Certificate 'test.example.com' (valid until 2033-11-19 : 4993d) valid for: Value "431464907.76" is lower than threshold "864000000"\_ [WARNING] Certificate 'Icinga CA' (valid until 2032-09-18 : 4566d) valid for: Value "394583054.72" is lower than threshold "864000000"
```

### Example Command 3

```powershell
The checks can be combined into a single check:
```

### Example Output 3

```powershell
PS> Invoke-IcingaCheckCertificate -CertStore 'LocalMachine' -CertStorePath 'My' -CertThumbprint '*'-CertPaths "C:\ProgramData\icinga2\var\lib\icinga2\certs" -CertName '*.crt' -Trusted[CRITICAL] Check package "Certificates" (Match All) - [CRITICAL] Certificate 'test.example.com' trusted, Certificate 'Icinga CA' trusted\_ [CRITICAL] Check package "Certificate 'test.example.com'" (Match All) \_ [OK] Certificate 'test.example.com' (valid until 2033-11-19 : 4993d) valid for: 431464853.88 \_ [CRITICAL] Certificate 'test.example.com' trusted: Value "False" is not matching threshold "True"\_ [CRITICAL] Check package "Certificate 'Icinga CA'" (Match All) \_ [OK] Certificate 'Icinga CA' (valid until 2032-09-18 : 4566d) valid for: 394583000.86 \_ [CRITICAL] Certificate 'Icinga CA' trusted: Value "False" is not matching threshold "True"
```
