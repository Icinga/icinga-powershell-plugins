@{
    ModuleVersion     = '1.9.0'
    GUID              = 'e3e7850e-2f24-4173-8268-c2a29ec35750'
    RootModule        = 'icinga-powershell-plugins.psm1'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2021 Icinga GmbH | GPLv2'
    Description       = 'A collection of Icinga Plugins for general Windows checks for Icinga for Windows.'
    PowerShellVersion = '4.0'
    RequiredModules   = @(@{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.9.0' })
    NestedModules     = @(
        '.\plugins\Invoke-IcingaCheckBiosSerial.psm1',
        '.\plugins\Invoke-IcingaCheckCertificate.psm1',
        '.\plugins\Invoke-IcingaCheckCheckSum.psm1',
        '.\plugins\Invoke-IcingaCheckCPU.psm1',
        '.\plugins\Invoke-IcingaCheckDirectory.psm1',
        '.\plugins\Invoke-IcingaCheckDiskHealth.psm1',
        '.\plugins\Invoke-IcingaCheckEventlog.psm1',
        '.\plugins\Invoke-IcingaCheckFirewall.psm1',
        '.\plugins\Invoke-IcingaCheckHTTPStatus.psm1',
        '.\plugins\Invoke-IcingaCheckICMP.psm1',
        '.\plugins\Invoke-IcingaCheckMemory.psm1',
        '.\plugins\Invoke-IcingaCheckMPIO.psm1',
        '.\plugins\Invoke-IcingaCheckNetworkInterface.psm1',
        '.\plugins\Invoke-IcingaCheckNLA.psm1',
        '.\plugins\Invoke-IcingaCheckPerfcounter.psm1',
        '.\plugins\Invoke-IcingaCheckProcess.psm1',
        '.\plugins\Invoke-IcingaCheckProcessCount.psm1',
        '.\plugins\Invoke-IcingaCheckScheduledTask.psm1',
        '.\plugins\Invoke-IcingaCheckService.psm1',
        '.\plugins\Invoke-IcingaCheckStoragePool.psm1',
        '.\plugins\Invoke-IcingaCheckTCP.psm1',
        '.\plugins\Invoke-IcingaCheckTimeSync.psm1',
        '.\plugins\Invoke-IcingaCheckUNCPath.psm1',
        '.\plugins\Invoke-IcingaCheckUpdates.psm1',
        '.\plugins\Invoke-IcingaCheckUptime.psm1',
        '.\plugins\Invoke-IcingaCheckUsedPartitionSpace.psm1',
        '.\plugins\Invoke-IcingaCheckUsers.psm1',
        '.\provider\bios\Icinga_ProviderBios.psm1',
        '.\provider\bios\Show-IcingaBiosData.psm1',
        '.\provider\certificate\Icinga_ProviderCertificate.psm1',
        '.\provider\certificate\Test-IcingaCertificateExcludePattern.psm1',
        '.\provider\connection\Test-IcingaICMPConnection.psm1',
        '.\provider\cpu\Icinga_ProviderCpu.psm1',
        '.\provider\cpu\Show-IcingaCPUData.psm1',
        '.\provider\directory\Icinga_Provider_Directory.psm1',
        '.\provider\disks\Get-IcingaDiskAttributes.psm1',
        '.\provider\disks\Get-IcingaDiskPartitionAssignment.psm1',
        '.\provider\disks\Get-IcingaPartitionSpace.psm1',
        '.\provider\disks\Get-IcingaPhysicalDiskInfo.psm1',
        '.\provider\disks\Get-IcingaUNCPathSize.psm1',
        '.\provider\disks\Icinga_ProviderDisks.psm1',
        '.\provider\disks\Show-IcingaDiskData.psm1',
        '.\provider\enums\IcingaGeneralPlugins_Exceptions.psm1',
        '.\provider\enums\Icinga_ProviderEnums.psm1',
        '.\provider\eventlog\Get-IcingaEventLog.psm1',
        '.\provider\http\Get-IcingaCheckHTTPQuery.psm1',
        '.\provider\memory\Get-IcingaMemoryPerformanceCounter.psm1',
        '.\provider\memory\Get-IcingaMemoryUsage.psm1',
        '.\provider\memory\Icinga_ProviderMemory.psm1',
        '.\provider\memory\Show-IcingaMemoryData.psm1',
        '.\provider\mpio\Get-IcingaMPIOData.psm1',
        '.\provider\mpio\Test-IcingaMPIOInstalled.psm1',
        '.\provider\network\Get-IcingaNetworkDeviceInfo.psm1',
        '.\provider\network\Get-IcingaNetworkInterfaceTeamInfo.psm1',
        '.\provider\network\Get-IcingaNetworkSpeedChecks.psm1',
        '.\provider\network\Join-icingaNetworkDeviceDataPerfCounter.psm1',
        '.\provider\ntp\Get-IcingaNtpData.psm1',
        '.\provider\process\Icinga_ProviderProcess.psm1',
        '.\provider\services\Add-IcingaServiceSummary.psm1',
        '.\provider\services\ConvertTo-ServiceStatusCode.psm1',
        '.\provider\services\Get-IcingaServiceCheckName.psm1',
        '.\provider\services\New-IcingaWindowsServiceCheckObject.psm1',
        '.\provider\storage\Get-IcingaConvertToGigaByte.psm1',
        '.\provider\storage\Get-IcingaStoragePoolInfo.psm1',
        '.\provider\tasks\Get-IcingaScheduledTask.psm1',
        '.\provider\tasks\New-IcingaTaskObject.psm1',
        '.\provider\tcp\Measure-IcingaTCPConnection.psm1',
        '.\provider\updates\Get-IcingaUpdatesHotfix.psm1',
        '.\provider\updates\Get-IcingaUpdatesInstalled.psm1',
        '.\provider\updates\Get-IcingaWindowsUpdatesPending.psm1',
        '.\provider\users\Get-IcingaLoggedOnUsers.psm1',
        '.\provider\users\Get-IcingaUsers.psm1',
        '.\provider\windows\Icinga_ProviderWindows.psm1',
        '.\provider\windows\Show-IcingaWindowsData.psm1'
    )
    FunctionsToExport = @('*')
    CmdletsToExport   = @('*')
    VariablesToExport = '*'
    AliasesToExport   = @( '*' )
    PrivateData       = @{
        PSData   = @{
            Tags         = @( 'icinga', 'icinga2', 'monitoringplugins', 'icingaplugins', 'icinga2plugins', 'windowsplugins', 'icingawindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-plugins/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-plugins'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-plugins/releases'
        };
        Version  = 'v1.9.0';
        Name     = 'Windows Plugins';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-plugins'
}

