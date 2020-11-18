# Upgrading Icinga PowerShell Plugins

Upgrading Icinga PowerShell Plugins is usually quite straightforward.

Specific version upgrades are described below. Please note that version updates are incremental.

## Upgrading to v1.3.0 (pending)

### Plugin Argument Changes <span style="color:#F6BE00">(Breaking Changes)

The following plugins received modifications to their existing arguments. Please keep in mind that updating to this version of the Icinga PowerShell Plugins, you **must** update your configuration to ensure everything is running properly **and** update all plugins on all systems.

#### Invoke-IcingaCheckScheduledTask

The `State` argument for `Invoke-IcingaCheckScheduledTask` has been changed from `String` to `Array`, which will now support providing multiple states a task can be into. In addition we modified the [Icinga PowerShell Framework](https://github.com/Icinga/icinga-powershell-framework) to properly support `ValidateSet` for array arguments, fixed in [#152](https://github.com/Icinga/icinga-powershell-framework/pull/152). Please ensure to upgrade to v1.3.0 before generating the new configuration and importing it, as the fix ensures that array arguments still can only contain fixed values.

## Upgrading to v1.2.0 (2020-08-28)

*No special steps required*

## Upgrading to v1.1.0 (2020-06-02)

### Icinga PowerShell Framework dependency

To use the Icinga PowerShell Plugins v1.1.0 you will require to upgrade the Icinga PowerShell Framework to v1.1.0 first. This new plugin release will **not** work with older Framework versions.

### New Plugins

We have added two new plugins you can add into your Icinga 2 configuration by creating a basket configuration for the Icinga Director. The new plugins are

* [Invoke-IcingaCheckICMP](https://icinga.com/docs/windows/latest/plugins/doc/plugins/08-Invoke-IcingaCheckICMP/)
* [Invoke-IcingaCheckCertificate](https://icinga.com/docs/windows/latest/plugins/doc/plugins/02-Invoke-IcingaCheckCertificate/)
