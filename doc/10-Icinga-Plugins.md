# Icinga Plugins

Below you will find a documentation for every single available plugin provided by this repository. Most of the plugins allow the usage of default Icinga threshold range handling, which is defined as follows:

| Argument | Throws error on | Ok range                     |
| ---      | ---             | ---                          |
| 20       | < 0 or > 20     | 0 .. 20                      |
| 20:      | < 20            | between 20 .. ∞              |
| ~:20     | > 20            | between -∞ .. 20             |
| 30:40    | < 30 or > 40    | between {30 .. 40}           |
| `@30:40  | ≥ 30 and ≤ 40   | outside -∞ .. 29 and 41 .. ∞ |

Please ensure that you will escape the `@` if you are configuring it on the Icinga side. To do so, you will simply have to write an *\`* before the `@` symbol: \``@`

To test thresholds with different input values, you can use the Framework Cmdlet `Get-IcingaHelpThresholds`.

Each plugin ships with a constant Framework argument `-ThresholdInterval`. This can be used to modify the value your thresholds are compared against from the current, fetched value to one collected over time by the Icinga for Windows daemon. In case you [registered service checks](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/) for specific time intervals, you can for example set the argument to `15m` to get the average value of 15m as base for your monitoring values. Please note that in this example, you will require to have collected the `15m` average for `Invoke-IcingaCheckCPU`.

```powershell
icinga> icinga { Invoke-IcingaCheckCPU -Warning 20 -Critical 40 -Core _Total -ThresholdInterval 15m }

[WARNING] CPU Load: [WARNING] Core Total (29,14817700%)
\_ [WARNING] Core Total: 29,14817700% is greater than threshold 20% (15m avg.)
| 'core_total_1'=31.545677%;;;0;100 'core_total_15'=29.148177%;20;40;0;100 'core_total_5'=28.827410%;;;0;100 'core_total_20'=30.032942%;;;0;100 'core_total_3'=27.731669%;;;0;100 'core_total'=33.87817%;;;0;100
```
* [Invoke-IcingaCheckBiosSerial](plugins/01-Invoke-IcingaCheckBiosSerial.md)
* [Invoke-IcingaCheckCertificate](plugins/02-Invoke-IcingaCheckCertificate.md)
* [Invoke-IcingaCheckCheckSum](plugins/03-Invoke-IcingaCheckCheckSum.md)
* [Invoke-IcingaCheckCPU](plugins/04-Invoke-IcingaCheckCPU.md)
* [Invoke-IcingaCheckDirectory](plugins/05-Invoke-IcingaCheckDirectory.md)
* [Invoke-IcingaCheckDiskHealth](plugins/20-Invoke-IcingaCheckDiskHealth.md)
* [Invoke-IcingaCheckEventlog](plugins/06-Invoke-IcingaCheckEventlog.md)
* [Invoke-IcingaCheckFirewall](plugins/07-Invoke-IcingaCheckFirewall.md)
* [Invoke-IcingaCheckHTTPStatus](plugins/25-Invoke-IcingaCheckHTTPStatus.md)
* [Invoke-IcingaCheckICMP](plugins/08-Invoke-IcingaCheckICMP.md)
* [Invoke-IcingaCheckMemory](plugins/09-Invoke-IcingaCheckMemory.md)
* [Invoke-IcingaCheckMPIO](plugins/26-Invoke-IcingaCheckMPIO.md)
* [Invoke-IcingaCheckNetworkInterface](plugins/21-Invoke-IcingaCheckNetworkInterface.md)
* [Invoke-IcingaCheckNLA](plugins/10-Invoke-IcingaCheckNLA.md)
* [Invoke-IcingaCheckPerfcounter](plugins/11-Invoke-IcingaCheckPerfcounter.md)
* [Invoke-IcingaCheckProcess](plugins/27-Invoke-IcingaCheckProcess.md)
* [Invoke-IcingaCheckProcessCount](plugins/12-Invoke-IcingaCheckProcessCount.md)
* [Invoke-IcingaCheckScheduledTask](plugins/19-Invoke-IcingaCheckScheduledTask.md)
* [Invoke-IcingaCheckService](plugins/13-Invoke-IcingaCheckService.md)
* [Invoke-IcingaCheckStoragePool](plugins/21-Invoke-IcingaCheckStoragePool.md)
* [Invoke-IcingaCheckTCP](plugins/23-Invoke-IcingaCheckTCP.md)
* [Invoke-IcingaCheckTimeSync](plugins/18-Invoke-IcingaCheckTimeSync.md)
* [Invoke-IcingaCheckUNCPath](plugins/24-Invoke-IcingaCheckUNCPath.md)
* [Invoke-IcingaCheckUpdates](plugins/14-Invoke-IcingaCheckUpdates.md)
* [Invoke-IcingaCheckUptime](plugins/15-Invoke-IcingaCheckUptime.md)
* [Invoke-IcingaCheckUsedPartitionSpace](plugins/16-Invoke-IcingaCheckUsedPartitionSpace.md)
* [Invoke-IcingaCheckUsers](plugins/17-Invoke-IcingaCheckUsers.md)
