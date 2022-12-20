@{
    ModuleVersion     = '1.10.1'
    GUID              = 'e3e7850e-2f24-4173-8268-c2a29ec35750'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2021 Icinga GmbH | GPLv2'
    Description       = 'A collection of Icinga Plugins for general Windows checks for Icinga for Windows.'
    PowerShellVersion = '4.0'
    RequiredModules   = @(@{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.10.0' })
    NestedModules     = @(
        '.\compiled\icinga-powershell-plugins.ifw_compilation.psm1'
    )
    FunctionsToExport     = @(
        'Import-IcingaPowerShellComponentPlugins',
        'Invoke-IcingaCheckBiosSerial',
        'Invoke-IcingaCheckCertificate',
        'Invoke-IcingaCheckCheckSum',
        'Invoke-IcingaCheckCPU',
        'Invoke-IcingaCheckDirectory',
        'Invoke-IcingaCheckDiskHealth',
        'Invoke-IcingaCheckEventlog',
        'Invoke-IcingaCheckFirewall',
        'Invoke-IcingaCheckHttpJsonResponse',
        'Invoke-IcingaCheckHTTPStatus',
        'Invoke-IcingaCheckICMP',
        'Invoke-IcingaCheckMemory',
        'Invoke-IcingaCheckMPIO',
        'Invoke-IcingaCheckNetworkInterface',
        'Invoke-IcingaCheckNLA',
        'Invoke-IcingaCheckPerfCounter',
        'Invoke-IcingaCheckProcess',
        'Invoke-IcingaCheckProcessCount',
        'Invoke-IcingaCheckScheduledTask',
        'Invoke-IcingaCheckService',
        'Invoke-IcingaCheckStoragePool',
        'Invoke-IcingaCheckTCP',
        'Invoke-IcingaCheckTimeSync',
        'Invoke-IcingaCheckUNCPath',
        'Invoke-IcingaCheckUpdates',
        'Invoke-IcingaCheckUptime',
        'Invoke-IcingaCheckPartitionSpace',
        'Invoke-IcingaCheckUsedPartitionSpace',
        'Invoke-IcingaCheckUsers',
        'Get-IcingaBios',
        'Get-IcingaCPUs',
        'Get-IcingaCPUCount',
        'Get-IcingaPhysicalDiskInfo',
        'Get-IcingaDiskInformation',
        'Get-IcingaDiskPartitions',
        'Get-IcingaHttpResponse',
        'Get-IcingaMemoryPerformanceCounter',
        'Get-IcingaMemory',
        'Get-IcingaProcessData',
        'Get-IcingaServiceCheckName',
        'Get-IcingaUpdatesHotfix',
        'Get-IcingaUpdatesInstalled',
        'Get-IcingaWindowsUpdatesPending',
        'Get-IcingaUsers',
        'Get-IcingaWindows'
    )
    CmdletsToExport     = @(
    )
    VariablesToExport     = @(
        'ProviderEnums',
        'IcingaPluginExceptions'
    )
    AliasesToExport     = @(
    )
    PrivateData       = @{
        PSData   = @{
            Tags         = @( 'icinga', 'icinga2', 'monitoringplugins', 'icingaplugins', 'icinga2plugins', 'windowsplugins', 'icingawindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-plugins/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-plugins'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-plugins/releases'
        };
        Version  = 'v1.10.1';
        Name     = 'Windows Plugins';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-plugins'
}

