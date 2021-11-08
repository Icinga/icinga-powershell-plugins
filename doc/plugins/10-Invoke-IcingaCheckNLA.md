
# Invoke-IcingaCheckNLA

## Description

Checks whether the network location awareness(NLA) found the correct firewall profile for a given network adapter

Invoke-IcingaCheckNLA returns either 'OK' or 'CRITICAL', whether the check matches or not.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Profile | String | false |  | Used to specify the profile to check. Available profiles are 'DomainAuthenticated', 'Public', 'Private' |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NICs | Array | false |  | Used to specify the NICs where to check the filewall profile. When not presented every nic which is active will be checked |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckNLA -Profile "DomainAuthenticated" -Verbosity 3;
```

### Example Output 1

```powershell
[CRITICAL] Check package "NLA" (Match All) - [CRITICAL] NLA for vEthernet (DockerNAT)\_ [OK] NLA for Ethernet 4: DomainAuthenticated\_ [CRITICAL] NLA for vEthernet (DockerNAT): Value "Public" is not matching threshold "DomainAuthenticated"
```

### Example Command 2

```powershell
Invoke-IcingaCheckNLA -Profile "DomainAuthenticated" -NICs "Ethernet 1" -Verbosity 1;
```

### Example Output 2

```powershell
[OK] Check package "NLA" (Match All)
```
