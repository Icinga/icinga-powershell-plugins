# Invoke-IcingaCheckFirewall

## Description

Checks whether a firewall module is enabled or not

Invoke-IcingaCheckFirewall returns either 'OK' or 'CRITICAL', whether the check matches or not.

More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| FirewallProfile | Array | false |  | Used to specify an array of profiles to check. Available profiles are 'Domain', 'Public', 'Private' |
| Enabled | SwitchParameter | false | False | Used to specify whether the firewall profiles should be enabled or disabled.  -Enabled $TRUE translates to enabled, while not being specified translates to disabled. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckFirewall -Profile "Domain" -Verbosity 3
```

### Example Output 1

```powershell
[OK] Check package "Firewall profiles" (Match All)
\_ [OK] Firewall Profile Domain is True
| 'firewall_profile_domain'=True;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckFirewall -Profile "Domain", "Private" -Verbosity 1}
```

### Example Output 2

```powershell
[OK] Check package "Firewall profiles" (Match All)
| 'firewall_profile_domain'=True;; 'firewall_profile_private'=True;;    
```


