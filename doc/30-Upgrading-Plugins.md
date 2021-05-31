# Upgrading Icinga PowerShell Plugins

Upgrading Icinga PowerShell Plugins is usually quite straightforward.

Specific version upgrades are described below. Please note that version updates are incremental.

For upgrading plugins, please have a look on the [installation docs](02-Installation.md).

## Upgrading to v1.5.0 (2021-06-02)

### Reworked plugins and removed arguments

Please note that in general plugins should no longer ship % values performance data and only the actually values including thresholds and min/max input. With the new Icinga for Windows Framework, you can use your graphing solution to properly calculate % values there on your own for display context. Monitoring is for most plugins possible, by simply adding a % sign behind your threshold.

In case the plugin does not support this input for this specify argument, you will receive a `UNKNOWN` output.

#### Invoke-IcingaCheckNetworkInterface

The following arguments have been removed from the plugin and are no longer usable:

* IncomingAvgBandUsageWarn
* IncomingAvgBandUsageCrit
* OutboundAvgBandUsageWarn
* OutboundAvgBandUsageCrit

These arguments were a % value based on the link speed and the current traffic of the interface. With the new argument handling for % values with Icinga for Windows v1.5.0, you can achieve the same result with the following, already present arguments:

* DeviceTotalBytesSecWarn
* DeviceTotalBytesSecCrit
* DeviceSentBytesSecWarn
* DeviceSentBytesSecCrit
* DeviceReceivedBytesSecWarn
* DeviceReceivedBytesSecCrit

#### Invoke-IcingaCheckMemory

We entirely reworked the plugin and added the same % value shipping with Icinga for Windows v1.5.0, which means we removed the following arguments:

* PercentWarning
* PercentCritical

In addition we added page file monitoring capabilities to the plugin with additional arguments

#### Invoke-IcingaCheckUsedPartitionSpace

As for both previous plugins, we reworked used partition space with changes for % values with Icinga for Windows 1.5.0 and fixed minor issues from the ground up.

#### Invoke-IcingaCheckPerfCounter

We fixed a spelling issue on the command itself, which was `Invoke-IcingaCheckPerfcounter` before and now properly displays `Invoke-IcingaCheckPerfCounter`. For that reason your current plugin configuration will change.
To resolve this beforehand, rename the custom variable within your Icinga Director to match the new uppercase `C` for `Counter`, before importing new configuration baskets.

## Upgrading to v1.4.0 (2021-03-02)

### Plugin Configuration <span style="color:#F6BE00">(Breaking Changes)</span>

The new package of the Icinga PowerShell Plugins is shipping with pre-compiled configuration for the Icinga Director and Icinga 2, which **only work with Icinga PowerShell Framework v1.4.0** or later. Please update your entire infrastructure to *Icinga for Windows v1.4.0* **before** using the pre-compiled configuration or configuration files created by the new *Icinga for Windows v1.4.0* config generator.

### Invoke-IcingaCheckEventLog

We made some slight adjustments to `Invoke-IcingaCheckEventLog` for the `-After` and `-Before` argument, which will now not only allow a fixed time stamp, like `2021/01/30`, but also threshold inputs like `5h` (to go back 5 hours), `1d` (to go back 1 day), and so on. There should be no impact on current implementations but you might wanna have a look on your checks and results after uprading.

## Upgrading to v1.3.0 (2020-12-01)

### Plugin Argument Changes <span style="color:#F6BE00">(Breaking Changes)</span>

The following plugins received modifications to their existing arguments. Please keep in mind that updating to this version of the Icinga PowerShell Plugins, you **must** update your configuration to ensure everything is running properly **and** update all plugins on all systems. As for the Icinga Director, you have to import the new basket for these plugins to apply the configuration. How ever, <span style="color:#F6BE00">current values assigned to these arguments will no longer apply and have to be reconfigured!</span>

#### Invoke-IcingaCheckScheduledTask

The `State` argument for `Invoke-IcingaCheckScheduledTask` has been changed from `String` to `Array`, which will now support providing multiple states a task can be into. In addition we modified the [Icinga PowerShell Framework](https://github.com/Icinga/icinga-powershell-framework) to properly support `ValidateSet` for array arguments, fixed in [#152](https://github.com/Icinga/icinga-powershell-framework/pull/152). Please ensure to upgrade to v1.3.0 before generating the new configuration and importing it, as the fix ensures that array arguments still can only contain fixed values.

#### Invoke-IcingaCheckNetworkInterface

The arguments used before were too long for importing into the Icinga Director. For that reason many arguments have been shorted with their name. Please ensure to import the latest version of the configuration file for this plugin and update your Icinga and check configuration to use the new arguments instead. Only applies if you used this plugin from previous snapshots.

## Upgrading to v1.2.0 (2020-08-28)

*No special steps required*

## Upgrading to v1.1.0 (2020-06-02)

### Icinga PowerShell Framework dependency

To use the Icinga PowerShell Plugins v1.1.0 you will require to upgrade the Icinga PowerShell Framework to v1.1.0 first. This new plugin release will **not** work with older Framework versions.

### New Plugins

We have added two new plugins you can add into your Icinga 2 configuration by creating a basket configuration for the Icinga Director. The new plugins are

* [Invoke-IcingaCheckICMP](https://icinga.com/docs/windows/latest/plugins/doc/plugins/08-Invoke-IcingaCheckICMP/)
* [Invoke-IcingaCheckCertificate](https://icinga.com/docs/windows/latest/plugins/doc/plugins/02-Invoke-IcingaCheckCertificate/)
