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

Each plugin ships with a constant Framework argument `-ThresholdInterval`. This can be used to modify the value your thresholds are compared against from the current, fetched value to one collected over time by the Icinga for Windows daemon. In case you [Collect Metrics Over Time](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/) for specific time intervals, you can for example set the argument to `15m` to get the average value of 15m as base for your monitoring values. Please note that in this example, you will require to have collected the `15m` average for `Invoke-IcingaCheckCPU`.

```powershell
icinga> icinga { Invoke-IcingaCheckCPU -Warning 20 -Critical 40 -Core _Total -ThresholdInterval 15m }

[WARNING] CPU Load: [WARNING] Core Total (29,14817700%)
\_ [WARNING] Core Total: 29,14817700% is greater than threshold 20% (15m avg.)
| 'core_total_1'=31.545677%;;;0;100 'core_total_15'=29.148177%;20;40;0;100 'core_total_5'=28.827410%;;;0;100 'core_total_20'=30.032942%;;;0;100 'core_total_3'=27.731669%;;;0;100 'core_total'=33.87817%;;;0;100
```

| Plugin Name | Description |
| ---         | --- |
| [Invoke-IcingaCheckBiosSerial](plugins/01-Invoke-IcingaCheckBiosSerial.md) | Finds out the Bios Serial |
| [Invoke-IcingaCheckCertificate](plugins/02-Invoke-IcingaCheckCertificate.md) | Check whether a certificate is still trusted and when it runs out or starts. |
| [Invoke-IcingaCheckCheckSum](plugins/03-Invoke-IcingaCheckCheckSum.md) | Checks hash against file hash of a file |
| [Invoke-IcingaCheckCPU](plugins/04-Invoke-IcingaCheckCPU.md) | Checks cpu usage of cores. |
| [Invoke-IcingaCheckDirectory](plugins/05-Invoke-IcingaCheckDirectory.md) | Checks for amount of files within a directory depending on the set filters |
| [Invoke-IcingaCheckDiskHealth](plugins/20-Invoke-IcingaCheckDiskHealth.md) | Checks availability, state and utilization of the physical hard disk |
| [Invoke-IcingaCheckEventlog](plugins/06-Invoke-IcingaCheckEventlog.md) | Checks how many eventlog occurrences of a given type there are. |
| [Invoke-IcingaCheckFirewall](plugins/07-Invoke-IcingaCheckFirewall.md) | Checks whether a firewall module is enabled or not |
| [Invoke-IcingaCheckHttpJsonResponse](plugins/28-Invoke-IcingaCheckHttpJsonResponse.md) | Retrieves a JSON-Object via Request and performs desired checks |
| [Invoke-IcingaCheckHTTPStatus](plugins/25-Invoke-IcingaCheckHTTPStatus.md) | Checks the response time, the return code and content of HTTP requests. |
| [Invoke-IcingaCheckICMP](plugins/08-Invoke-IcingaCheckICMP.md) | Checks via ICMP requests to a target destination for response time and availability |
| [Invoke-IcingaCheckMemory](plugins/09-Invoke-IcingaCheckMemory.md) | Checks on memory usage |
| [Invoke-IcingaCheckMPIO](plugins/26-Invoke-IcingaCheckMPIO.md) | Monitors the number of paths for each MPIO driver on your system. |
| [Invoke-IcingaCheckNetworkInterface](plugins/21-Invoke-IcingaCheckNetworkInterface.md) | Checks availability, state and Usage of Network interfaces and Interface Teams |
| [Invoke-IcingaCheckNLA](plugins/10-Invoke-IcingaCheckNLA.md) | Checks whether the network location awareness(NLA) found the correct firewall profile for a given network adapter |
| [Invoke-IcingaCheckPerfcounter](plugins/11-Invoke-IcingaCheckPerfcounter.md) | Performs checks on various performance counter |
| [Invoke-IcingaCheckProcess](plugins/27-Invoke-IcingaCheckProcess.md) | A plugin to check thread, cpu, memory and pagefile usage for each single process |
| [Invoke-IcingaCheckProcessCount](plugins/12-Invoke-IcingaCheckProcessCount.md) | Checks how many processes of a process exist. |
| [Invoke-IcingaCheckScheduledTask](plugins/19-Invoke-IcingaCheckScheduledTask.md) | Checks the current state for a list of specified tasks based on their name and prints the result |
| [Invoke-IcingaCheckService](plugins/13-Invoke-IcingaCheckService.md) | Checks if defined services have a specific status or checks for all automatic services and if they are running and have not been terminated with exit code 0 |
| [Invoke-IcingaCheckStoragePool](plugins/21-Invoke-IcingaCheckStoragePool.md) | Checks availability, utilization and state of a StoragePool. |
| [Invoke-IcingaCheckTCP](plugins/23-Invoke-IcingaCheckTCP.md) | Checks the connection for an address and a range of ports and fetches the connection status including the time require to connect. |
| [Invoke-IcingaCheckTimeSync](plugins/18-Invoke-IcingaCheckTimeSync.md) | Gets Network Time Protocol time(SMTP/NTP) from a specified server |
| [Invoke-IcingaCheckUNCPath](plugins/24-Invoke-IcingaCheckUNCPath.md) | Checks a given path / unc path and determines the size of the volume including free space |
| [Invoke-IcingaCheckUpdates](plugins/14-Invoke-IcingaCheckUpdates.md) | Checks how many updates are to be applied |
| [Invoke-IcingaCheckUptime](plugins/15-Invoke-IcingaCheckUptime.md) | Checks how long a Windows system has been up for. |
| [Invoke-IcingaCheckUsedPartitionSpace](plugins/16-Invoke-IcingaCheckUsedPartitionSpace.md) | Checks how much space on a partition is used. |
| [Invoke-IcingaCheckUsers](plugins/17-Invoke-IcingaCheckUsers.md) | Checks how many users are logged on to the host |

