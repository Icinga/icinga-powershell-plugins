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

* [Invoke-IcingaCheckBiosSerial](plugins/01-Invoke-IcingaCheckBiosSerial.md)
* [Invoke-IcingaCheckCertificate](plugins/02-Invoke-IcingaCheckCertificate.md)
* [Invoke-IcingaCheckCheckSum](plugins/03-Invoke-IcingaCheckCheckSum.md)
* [Invoke-IcingaCheckCPU](plugins/04-Invoke-IcingaCheckCPU.md)
* [Invoke-IcingaCheckDirectory](plugins/05-Invoke-IcingaCheckDirectory.md)
* [Invoke-IcingaCheckEventlog](plugins/06-Invoke-IcingaCheckEventlog.md)
* [Invoke-IcingaCheckFirewall](plugins/07-Invoke-IcingaCheckFirewall.md)
* [Invoke-IcingaCheckICMP](plugins/08-Invoke-IcingaCheckICMP.md)
* [Invoke-IcingaCheckMemory](plugins/09-Invoke-IcingaCheckMemory.md)
* [Invoke-IcingaCheckNLA](plugins/10-Invoke-IcingaCheckNLA.md)
* [Invoke-IcingaCheckPerfcounter](plugins/11-Invoke-IcingaCheckPerfcounter.md)
* [Invoke-IcingaCheckProcessCount](plugins/12-Invoke-IcingaCheckProcessCount.md)
* [Invoke-IcingaCheckService](plugins/13-Invoke-IcingaCheckService.md)
* [Invoke-IcingaCheckUpdates](plugins/14-Invoke-IcingaCheckUpdates.md)
* [Invoke-IcingaCheckUptime](plugins/15-Invoke-IcingaCheckUptime.md)
* [Invoke-IcingaCheckUsedPartitionSpace](plugins/16-Invoke-IcingaCheckUsedPartitionSpace.md)
* [Invoke-IcingaCheckUsers](plugins/17-Invoke-IcingaCheckUsers.md)
