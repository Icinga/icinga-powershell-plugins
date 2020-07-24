# Icinga PowerShell Plugins CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/plugins/doc/30-Upgrading-Plugins)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-plugins/milestones?state=closed).

## 1.2.0 (pending)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/3?closed=1)

* [#32](https://github.com/Icinga/icinga-powershell-plugins/issues/32) Improves plugin doc generate to update existing .md files and create new ones only if required
* [#28](https://github.com/Icinga/icinga-powershell-plugins/issues/28) Adds unknown state for each included service during a service check which was not found on the host
* [#33](https://github.com/Icinga/icinga-powershell-plugins/issues/33) Adds support to generate plugin docs for different plugin module repos
* [#30](https://github.com/Icinga/icinga-powershell-plugins/issues/30) Fixes $null input value for certificate check, causing the Director import to fail

## 1.1.0 (2020-06-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/2?closed=1)

### Notes

This release adds two new plugins to the collection:

* [Invoke-IcingaCheckICMP](https://icinga.com/docs/windows/latest/plugins/doc/plugins/08-Invoke-IcingaCheckICMP/): Allows to execute ping checks from the Windows Agent to other hosts
* [Invoke-IcingaCheckCertificate](https://icinga.com/docs/windows/latest/plugins/doc/plugins/02-Invoke-IcingaCheckCertificate/): Allows to check certificates on disk or inside the Windows Cert Store

### Enhancements

* [#26](https://github.com/Icinga/icinga-powershell-plugins/issues/26) Fixes Invoke-IcingaCheckEventLog to use EventIds instead of InstanceIds for filtering and output

### Bugfixes

* [#19](https://github.com/Icinga/icinga-powershell-plugins/issues/19) Fixes exclude of EventLog ids for Invoke-IcingaCheckEventLog
* [#27](https://github.com/Icinga/icinga-powershell-plugins/issues/27) Fixes User provider to prevent almost infinite loop on AccountDomainSid resolving

## 1.0.0 (2020-02-19)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/1?closed=1)

### Notes

This release fixed several smaller design and documentation issues as well as improving the general output of the plugins.

### Breaking changes

If you installed the previous RC versions of the Framework or the Plugins, you will have to generate the Icinga Director Basket configuration again and re-import the newly generated JSON file. Please be aware that because of possible changes your old custom variables containing arguments and thresholds might not apply due to new custom variable naming and handling. Please ensure to have a backup of your Icinga Director before applying any changes

### Enhancements

* [#5](https://github.com/Icinga/icinga-powershell-plugins/issues/5) Used partition space will now output usage in bytes as well (formatted to MB/GB/TB depending on size)
* [#9](https://github.com/Icinga/icinga-powershell-plugins/issues/9) The memory plugin is now calculating the missing thresholds

### Bugfixes

* [#4](https://github.com/Icinga/icinga-powershell-plugins/issues/4) Fixes unused partition space plugin not working on Windows 7 or older
* [#8](https://github.com/Icinga/icinga-powershell-plugins/issues/8) Fixes unit auto detection for memory plugin

## 1.0.0 RC1 (2019-11-04)

### Notes

* Initial release candidate for the new Icinga PowerShell Plugins
