# Icinga PowerShell Plugins CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/plugins/doc/30-Upgrading-Plugins)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-plugins/milestones?state=closed).

## 1.6.0 (pending)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/8?closed=1)

### Bugfixes

[#187](https://github.com/Icinga/icinga-powershell-plugins/issues/187) Fixes `Invoke-IcingaCheckUsedPartitionSpace` in case mirrored disks are used within the system, causing an exception on duplicate partition id's

## 1.5.0 (2021-06-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/7?closed=1)

### New Plugins

#### Invoke-IcingaCheckHTTPStatus

[#163](https://github.com/Icinga/icinga-powershell-plugins/issues/163) Checks the response time, the return code and content of HTTP requests.

#### Invoke-IcingaCheckMPIO

[#172](https://github.com/Icinga/icinga-powershell-plugins/pull/172) Checks the number of paths for each MPIO driver on your system.

### Reworked Plugins

Please have a look on the [upgrading docs](30-Upgrading-Plugins) for these plugins

* Invoke-IcingaCheckNetworkInterface
* Invoke-IcingaCheckMemory
* Invoke-IcingaCheckUsedPartitionSpace

### Enhancements

* [#14](https://github.com/Icinga/icinga-powershell-plugins/issues/14) Rework of `Invoke-IcingaCheckMemory` to use new features from 1.5.0 for % handling and added page file check content including arguments. Please have a look on the [upgrading docs](30-Upgrading-Plugins.md)
* [#71](https://github.com/Icinga/icinga-powershell-plugins/pull/71) Rework `Invoke-IcingaCheckUsedPartitionSpace` to properly use Framework v1.5.0 functionality and resolve upper/lower case drive filtering
* [#156](https://github.com/Icinga/icinga-powershell-plugins/issues/156) Adds feature to modify the output status of `Invoke-IcingaCheckCertificate` from `UNKNOWN` to `OK` in case no certificate was found by setting the new argument `-IgnoreEmpty`
* [#159](https://github.com/Icinga/icinga-powershell-plugins/issues/159) Replaces the deprecated function `Get-EventLog` with `Get-WinEvent`. In addition, the plugin received a new argument `-MaxEntries` to allow additional filtering for the number of events fetched to improve performance in addition. The EventLog now also supports an array with list items, allowing easier filtering for severities which are allowed inside the EventLog.
* [#167](https://github.com/Icinga/icinga-powershell-plugins/issues/167) Upgrades plugin configuration files to Framework version 1.5.0. Please have a look on the [upgrading docs](30-Upgrading-Plugins)
* [#181](https://github.com/Icinga/icinga-powershell-plugins/pull/181) Improves the handling for the Network Interface plugin and moves the `Get-IcingaNetworkInterfaceUnits` from the plugin repository into the Framework

### Bugfixes

* [#144](https://github.com/Icinga/icinga-powershell-plugins/pull/144) Fixes filtering for `Invoke-IcingaCheckEventLog` which resulted in wrong results, depending on the plugin configuration
* [#147](https://github.com/Icinga/icinga-powershell-plugins/pull/147) Fixes wrong comparison for file size on `Get-IcingaDirectorySizeSmallerThan`, used by `Invoke-IcingaCheckDirectory`
* [#148](https://github.com/Icinga/icinga-powershell-plugins/issues/148) Fixes exception on `Invoke-CheckNetworkInterface` while two team interfaces with the identical name are present on the system
* [#154](https://github.com/Icinga/icinga-powershell-plugins/issues/154) Fixes `Invoke-IcingaCheckDirectory` by setting `-FileNames` argument to `*` as default for allowing to fetch all files for a given directory by default
* [#160](https://github.com/Icinga/icinga-powershell-plugins/issues/160) While filtering for certain services with `Get-IcingaServices`, there were some attributes missing from the collection. These are now added resulting in always correct output data.
* [#161](https://github.com/Icinga/icinga-powershell-plugins/issues/161) Fixes a copy & paste error on `Invoke-IcingaCheckUsedPartitionSpace`, as a wrong check variable was used for forcing `Unknown` results
* [#171](https://github.com/Icinga/icinga-powershell-plugins/issues/171) Fixes wrong OK states for `Invoke-IcingaCheckPerfCounter`, in case counters for categories with instances were not present
* [#176](https://github.com/Icinga/icinga-powershell-plugins/issues/176) Fixes offset calculation for `Invoke-IcingaCheckTimeSync`, to allow negative offset as well
* [#178](https://github.com/Icinga/icinga-powershell-plugins/pull/178) Fixes exception handling for `Invoke-IcingaCheckNLA` to properly handle errors while checking for connection profiles
* [#185](https://github.com/Icinga/icinga-powershell-plugins/pull/185) Fixes Network interface percent for teams not working
* [#186](https://github.com/Icinga/icinga-powershell-plugins/pull/186) Fixes possible exception on Icinga for Windows installation, if plugins were removed, no new shell session was created and therefor plugins are not able to load

## 1.4.0 (2021-03-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/5?closed=1)

### Breaking changes

If you are going to install this plugin release, please have a look on the [upgrading docs](30-Upgrading-Plugins.md) before!

### Enhancements

* [#114](https://github.com/Icinga/icinga-powershell-plugins/pull/114) Adds possibility to exclude certificates matching a certain pattern
* [#134](https://github.com/Icinga/icinga-powershell-plugins/pull/134) Adds autoloading for plugin information to standardize the development and projects and fixes plenty of spelling/code styling errors
* [#135](https://github.com/Icinga/icinga-powershell-plugins/pull/135) Adds new check plugin `Invoke-IcingaCheckTCP`
* [#137](https://github.com/Icinga/icinga-powershell-plugins/pull/137) Adds new configuration for Icinga for Windows v1.4.0 to make future configuration changes unnecessary. Please read the [upgrading docs](30-Upgrading-Plugins.md) before upgrading!
* [#139](https://github.com/Icinga/icinga-powershell-plugins/pull/139) Adds check note for the last boot time for `Invoke-IcingaCheckUptime` which is being displayed by using `-Verbosity 2` on the check configuration
* [#140](https://github.com/Icinga/icinga-powershell-plugins/pull/140) Adds new plugin `Invoke-IcingaCheckUNCPath` to test for network share paths or other volumes to fetch the size and free space from them
* [#141](https://github.com/Icinga/icinga-powershell-plugins/pull/141) Update Icinga Director and Icinga 2 conf files with new DSL parser for array elements to properly escape string values with single quotes. Please read the [upgrading docs](30-Upgrading-Plugins.md)

### Bugfixes

* [#136](https://github.com/Icinga/icinga-powershell-plugins/pull/136) Improves `Invoke-IcingaCheckEventLog` time filter by allowing simple input like `-After 5h` and fixes issue on filtering by formatting the time data into required format `yyyy/MM/dd HH:mm:ss`

## 1.3.1 (2021-02-04)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/6?closed=1)

### Bugfixes

* [#123](https://github.com/Icinga/icinga-powershell-plugins/pull/123) Fixes wrong documented user group for accessing Performance Counter objects which should be `Performance Monitor Users`
* [#124](https://github.com/Icinga/icinga-powershell-plugins/pull/124) Fixes crash on `Invoke-IcingaCheckService` if an automatic service is not running
* [#126](https://github.com/Icinga/icinga-powershell-plugins/pull/126) Fixes code base for `Invoke-IcingaCheckService` by preferring to fetch the startup type of services by using WMI instead of `Get-Services`, as the result of `Get-Services` might be empty in some cases
* [#128](https://github.com/Icinga/icinga-powershell-plugins/pull/128) Fixes invalid Icinga 2 configuration files due to special characters, invalid attributes and wrong boolean values

## 1.3.0 (2020-12-01)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/4?closed=1)

### New Plugins

This release adds the following new plugin:

* [Invoke-IcingaCheckNetworkInterface](https://icinga.com/docs/windows/latest/plugins/doc/plugins/21-Invoke-IcingaCheckNetworkInterface/): Checks availability, state and Usage of Network interfaces and Interface Teams
* [Invoke-IcingaCheckStoragePool](https://icinga.com/docs/windows/latest/plugins/doc/plugins/21-Invoke-IcingaCheckStoragePool/): Checks availability, utilization and state of a StoragePool

### Breaking changes

If you are going to install this plugin release, please have a look on the [upgrading docs](https://icinga.com/docs/windows/latest/plugins/doc/30-Upgrading-Plugins/) to not run into issues!

### Enhancements

* [#61](https://github.com/Icinga/icinga-powershell-plugins/issues/61) Adds exception handling in case permissions to access Windows Updates are missing on the system
* [#73](https://github.com/Icinga/icinga-powershell-plugins/issues/73) Improves plugin creation Cmdlet to write a new permission section and to create the `plugins` doc folder in case it does not exist
* [#74](https://github.com/Icinga/icinga-powershell-plugins/pull/74) Adds `avg. disk queue length` metric for monitoring and performance data to `Invoke-IcingaCheckDiskHealth`
* [#78](https://github.com/Icinga/icinga-powershell-plugins/issues/78) Improves the documentation and output for `Invoke-IcingaCheckService` by adding metrics for all found services configured to run `Automatic` and adds service output on Verbosity 1 to show a list of all found services including their current state
* [#85](https://github.com/Icinga/icinga-powershell-plugins/issues/85) Adds support on `Invoke-IcingaCheckUsedPartitionSpace` to ignore a `Unknown` in case all checks are filtered out. This will then return `Ok` instead if argument `-IgnoreEmptyChecks` is set. In addition you can now use `-SkipUnknown` which will transform an `Unknown` of partitions without data to `Ok`. Reworks [#84](https://github.com/Icinga/icinga-powershell-plugins/issues/84)
* [#90](https://github.com/Icinga/icinga-powershell-plugins/issues/90) Adds support to ignore read only/offline disks on `Invoke-IcingaCheckDiskHealth`
* [#101](https://github.com/Icinga/icinga-powershell-plugins/pull/101) Improves `Invoke-IcingaCheckScheduledTask` by changing the `State` argument from `String` to `Array`, allowing the comparison against multiple states. **Important:** Please have a look on the [upgrading docs!](https://icinga.com/docs/windows/latest/plugins/doc/30-Upgrading-Plugins/)
* [#104](https://github.com/Icinga/icinga-powershell-plugins/pull/104) Adds plugin configuration files for Icinga Director and Icinga 2 within the [config directory](https://github.com/Icinga/icinga-powershell-plugins/tree/master/config)
* [#109](https://github.com/Icinga/icinga-powershell-plugins/pull/109) Adds exception handling in case `-Path` argument is not set or not directing a file (including invalid path)

### Bugfixes

* [#75](https://github.com/Icinga/icinga-powershell-plugins/issues/75) Fixes unhandled arguments `FileSizeGreaterThan` and `FileSizeSmallerThan` for `Invoke-IcingaCheckDirectory`
* [#77](https://github.com/Icinga/icinga-powershell-plugins/issues/77) Fix wrong filtering for EventIds for `Invoke-IcingaCheckEventLog` and improve the output by adding the EventLog messages on severity 1. In addition we now allow the filtering for message sources and increase performance by fetching EventLog data for new checks from the last 2 hours only
* [#79](https://github.com/Icinga/icinga-powershell-plugins/issues/79) Fixes service check to exclude provided service names in case they contain the wildcard symbol '*' which causes the check to always return unknown
* [#86](https://github.com/Icinga/icinga-powershell-plugins/pull/86) Fixes `Get-IcingaCPUCount` returns wrong count on empty arguments
* [#97](https://github.com/Icinga/icinga-powershell-plugins/issues/97), [#98](https://github.com/Icinga/icinga-powershell-plugins/pull/98) Fixes invalid performance data output for `Invoke-IcingaCheckScheduledTask`
* [#102](https://github.com/Icinga/icinga-powershell-plugins/pull/102), [#103](https://github.com/Icinga/icinga-powershell-plugins/pull/103) Fixes `Invoke-IcingaCheckNetworkInterface` plugins arguments being too long for Icinga Director
* [#110](https://github.com/Icinga/icinga-powershell-plugins/pull/110) Fixes `Invoke-IcingaCheckEventLog` plugin throwing an unknown for valid arguments

## 1.2.0 (2020-08-28)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-plugins/milestone/3?closed=1)

### New Plugins

This release adds the following new plugins:

* [Invoke-IcingaCheckTimeSync](https://icinga.com/docs/windows/latest/plugins/doc/plugins/18-Invoke-IcingaChecTimeSync/): Allows to compare local machine time with a time server to check for possible time missmatch
* [Invoke-IcingaCheckScheduledTask](https://icinga.com/docs/windows/latest/plugins/doc/plugins/19-Invoke-IcingaCheckScheduledTask/): Allows to check the current state for a list of provided scheduled tasks
* [Invoke-IcingaCheckDiskHealth](https://icinga.com/docs/windows/latest/plugins/doc/plugins/20-Invoke-IcingaCheckDiskHealth/): Allows to check for several disk Performance Counters and the disk health in general

### Notes

* [#34](https://github.com/Icinga/icinga-powershell-plugins/issues/34) Replaces plugin CIM/WMI calls for new Framework wrapper function `Get-IcingaWindowsInformation` to properly handle config/permission errors

### Enhancements

* [#32](https://github.com/Icinga/icinga-powershell-plugins/issues/32) Improves plugin doc generate to update existing .md files and create new ones only if required
* [#28](https://github.com/Icinga/icinga-powershell-plugins/issues/28) Adds unknown state for each included service during a service check which was not found on the host
* [#33](https://github.com/Icinga/icinga-powershell-plugins/issues/33) Adds support to generate plugin docs for different plugin module repos
* [#38](https://github.com/Icinga/icinga-powershell-plugins/issues/38) Adds new plugin `Invoke-IcingaCheckDiskHealth`
* [#39](https://github.com/Icinga/icinga-powershell-plugins/issues/39) Fixes Performance Counters check plugin to throw error in case Performance Counter do not exist or a simply not present
* [#42](https://github.com/Icinga/icinga-powershell-plugins/issues/42) Improves performance of `Invoke-IcingaCheckCPU` for multi socket systems and optimises the code
* [#44](https://github.com/Icinga/icinga-powershell-plugins/issues/44) Adds check for Performance Counter categories 'Memory' and 'Processor' if they are present on a system, throwing an 'Unknown' if not

### Bugfixes

* [#30](https://github.com/Icinga/icinga-powershell-plugins/issues/30) Fixes $null input value for certificate check, causing the Director import to fail
* [#36](https://github.com/Icinga/icinga-powershell-plugins/issues/36) Fixes Ok return value for Invoke-IcingaCheckDirectory while -Path argument is not set
* [#37](https://github.com/Icinga/icinga-powershell-plugins/issues/37) Fixes `-FileNames` argument being ignored for Invoke-IcingaCheckDirectory while not using the `-Recurse` argument
* [#40](https://github.com/Icinga/icinga-powershell-plugins/issues/40) Fixes `Get-TimeZone` Cmdlet not known for `Invoke-IcingaCheckTimeSync` on Windows 2012 R2 and older
* [#50](https://github.com/Icinga/icinga-powershell-plugins/issues/50), [#51](https://github.com/Icinga/icinga-powershell-plugins/issues/51) Fixes possible crash/artifacts on plugin output for EventLog check while filters do not match any entry

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
