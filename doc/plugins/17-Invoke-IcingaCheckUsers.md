
# Invoke-IcingaCheckUsers

## Description

Checks how many users are logged on to the host

Invoke-IcingaCheckUsers returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g There are 13 users logged on, WARNING is set to 8, CRITICAL is set to 15. In this case the check will return WARNING.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Cimv2

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Username | Array | false |  | Used to specify an array of usernames to match against. e.g 'Administrator', 'Icinga' |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckUsers -Warning 8 -Critical 15
```

### Example Output 1

```powershell
[WARNING] Check package "Users" - [WARNING] Logged On Users\_ [WARNING] Logged On Users: Value "13" is greater than threshold "8"| 'logged_on_users'=13;8;15 'logged_on_users_test'=5;; 'logged_on_users_umfd0'=1;; 'logged_on_users_dwm1'=2;; 'logged_on_users_system'=1;; 'logged_on_users_dwm2'=2;; 'logged_on_users_umfd1'=1;; 'logged_on_users_umfd2'=1;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckUsers -Username 'astoll' -Warning 8 -Critical 15
```

### Example Output 2

```powershell
[OK] Check package "Users"| 'logged_on_users_test'=5;8;150
```
