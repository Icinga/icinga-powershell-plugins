# Invoke-IcingaCheckCPU

## Description

Checks cpu usage of cores.

Invoke-IcingaCheckCPU returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
e.g A system has 4 cores, each running at 60% usage, WARNING is set to 50%, CRITICAL is set to 75%. In this case the check will return WARNING.
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Performance Counter

* \Processor Information(*)\% Processor Utility

### Required User Groups

* Performance Monitor Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | Used to specify a Warning threshold. In this case an integer value. |
| Critical | Object | false |  | Used to specify a Critical threshold. In this case an integer value. |
| Core | String | false | * | Used to specify a single core to check for. For the average load across all cores use `_Total` |
| SocketFilter | Array | false | @() | Allows to specify one or mutlitple sockets by using their socket id. Not matching socket id's will not be evaluated<br /> by the plugin. |
| OverallOnly | SwitchParameter | false | False | If this flag is set, the Warning and Critical thresholds will only apply to the `Overall Load` metric instead of all<br /> returned cores. Requires that the plugin either fetches all cores with `*` or `Total` for the -Core argument |
| OverallTotalAsSum | SwitchParameter | false | False | Changes the output of the overall total load to report the sum of all sockets combined instead of the default<br /> average of all sockets |
| DisableProcessList | SwitchParameter | false | False | Disables the reporting of the top 10 CPU consuming process list |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckCPU -Warning '60%' -Critical '80%';
```

### Example Output 1

```powershell
[OK] CPU Load
| '0_4::ifw_cpu::load'=9.149948%;60;80;0;100 '0_2::ifw_cpu::load'=9.431381%;60;80;0;100 '0_6::ifw_cpu::load'=24.89185%;60;80;0;100 'totalload::ifw_cpu::load'=10.823693%;60;80;0;100 '0_7::ifw_cpu::load'=9.531499%;60;80;0;100 '0_3::ifw_cpu::load'=8.603164%;60;80;0;100 '0_1::ifw_cpu::load'=6.57868%;60;80;0;100 '0_total::ifw_cpu::load'=10.823693%;60;80;0;100 '0_5::ifw_cpu::load'=8.502121%;60;80;0;100 '0_0::ifw_cpu::load'=9.900898%;60;80;0;100    
```

### Example Command 2

```powershell
Invoke-IcingaCheckCPU -Warning '60%' -Critical '80%' -Core 'Total';
```

### Example Output 2

```powershell
[OK] CPU Load
| 'totalload::ifw_cpu::load'=11.029226%;60;80;0;100 '0_total::ifw_cpu::load'=11.029226%;60;80;0;100    
```


