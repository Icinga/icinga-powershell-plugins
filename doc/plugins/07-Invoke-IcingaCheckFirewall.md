
# Invoke-IcingaCheckFirewall

## Description

Checks whether a firewall module is enabled or not

Invoke-IcingaCheckFirewall returns either 'OK' or 'CRITICAL', whether the check matches or not.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Profile | Array | false |  | Used to specify an array of profiles to check. Available profiles are 'Domain', 'Public', 'Private' |
| Enabled | SwitchParameter | false | False | Used to specify whether the firewall profiles should be enabled or disabled.  -Enabled $TRUE translates to enabled, while not being specified translates to disabled. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckFirewall -Profile "Domain" -Verbosity 3
```

### Example Output 1

```powershell
[OK] Check package "Firewall profiles" (Match All)\_ [OK] Firewall Profile Domain is True| 'firewall_profile_domain'=True;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckFirewall -Profile "Domain", "Private" -Verbosity 1}
```

### Example Output 2

```powershell
[OK] Check package "Firewall profiles" (Match All)| 'firewall_profile_domain'=True;; 'firewall_profile_private'=True;;
```
