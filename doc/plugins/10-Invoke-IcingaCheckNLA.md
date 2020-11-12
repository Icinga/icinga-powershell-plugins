
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
| Verbosity | Int32 | false | 0 |  |
| NICs | Array | false |  | Used to specify the NICs where to check the filewall profile. When not presented every nic which is active will be checked |

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
