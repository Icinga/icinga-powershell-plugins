# Upgrading Icinga PowerShell Plugins

Upgrading Icinga PowerShell Plugins is usually quite straightforward.

Specific version upgrades are described below. Please note that version updates are incremental.

For upgrading plugins, please have a look on the [installation docs](02-Installation.md).

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
