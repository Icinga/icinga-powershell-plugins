@{
    ModuleVersion     = '1.14.0'
    GUID              = 'e3e7850e-2f24-4173-8268-c2a29ec35750'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2021 Icinga GmbH | GPLv2'
    Description       = 'A collection of Icinga Plugins for general Windows checks for Icinga for Windows.'
    PowerShellVersion = '4.0'
    RequiredModules   = @(@{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.13.0' })
    NestedModules     = @(
        '.\compiled\icinga-powershell-plugins.ifw_compilation.psm1'
    )
    FunctionsToExport     = @(
        'Import-IcingaPowerShellComponentPlugins',
        'Invoke-IcingaCheckPartitionSpace',
        'Invoke-IcingaCheckUsedPartitionSpace',
        'Invoke-IcingaCheckScheduledTask',
        'Invoke-IcingaCheckBiosSerial',
        'Invoke-IcingaCheckEventlog',
        'Invoke-IcingaCheckHttpJsonResponse',
        'Invoke-IcingaCheckNetworkInterface',
        'Invoke-IcingaCheckProcessCount',
        'Invoke-IcingaCheckUsers',
        'Invoke-IcingaCheckService',
        'Invoke-IcingaCheckCPU',
        'Invoke-IcingaCheckUNCPath',
        'Invoke-IcingaCheckUpdates',
        'Invoke-IcingaCheckTimeSync',
        'Invoke-IcingaCheckDiskHealth',
        'Invoke-IcingaCheckTCP',
        'Invoke-IcingaCheckHTTPStatus',
        'Invoke-IcingaCheckFirewall',
        'Invoke-IcingaCheckPerfCounter',
        'Invoke-IcingaCheckMemory',
        'Invoke-IcingaCheckUptime',
        'Invoke-IcingaCheckCheckSum',
        'Invoke-IcingaCheckMPIO',
        'Invoke-IcingaCheckNLA',
        'Invoke-IcingaCheckICMP',
        'Invoke-IcingaCheckCertificate',
        'Invoke-IcingaCheckStoragePool',
        'Invoke-IcingaCheckDirectory',
        'Invoke-IcingaCheckProcess',
        'Get-IcingaMemoryPerformanceCounter',
        'Get-IcingaMemory',
        'Get-IcingaCPUs',
        'Get-IcingaCPUCount',
        'Get-IcingaWindowsUpdatesPending',
        'Get-IcingaUpdatesHotfix',
        'Get-IcingaUpdatesInstalled',
        'Get-IcingaUsers',
        'Get-IcingaWindows',
        'Get-IcingaServiceCheckName',
        'Get-IcingaProcessData',
        'Get-IcingaPhysicalDiskInfo',
        'Get-IcingaDiskInformation',
        'Get-IcingaDiskPartitions',
        'Get-IcingaHttpResponse',
        'Get-IcingaBios'
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
        Version  = 'v1.14.0';
        Name     = 'Windows Plugins';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-plugins'
}

