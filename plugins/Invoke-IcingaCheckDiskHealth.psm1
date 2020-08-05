<#

#>
function Invoke-IcingaCheckDiskHealth() 
{
    param
    (
        $DiskReadSecWarning       = $null,
        $DiskReadSecCritical      = $null,
        $DiskWriteSecWarning      = $null,
        $DiskWriteSecCritical     = $null,
        $DiskQueueLenWarning      = $null,
        $DiskQueueLenCritical     = $null,
        $DiskReadByteSecWarning   = $null,
        $DiskReadByteSecCritical  = $null,
        $DiskWriteByteSecWarning  = $null,
        $DiskWriteByteSecCritical = $null,
        $DiskAvgTransSecWarning   = $null,
        $DiskAvgTransSecCritical  = $null,
        $DiskAvgReadSecWarning    = $null,
        $DiskAvgReadSecCritical   = $null,
        $DiskAvgWriteSecWarning   = $null,
        $DiskAvgWriteSecCritical  = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity           = 0
    )

    $CheckPackage = New-IcingaCheckPackage `
        -Name 'Physicaldisk Package' `
        -OperatorAnd `
        -Verbose $Verbosity;
    $SortedDisks = Join-IcingaPhysicalDiskDataPerfCounter `
        '\PhysicalDisk(*)\disk read bytes/sec', `
        '\PhysicalDisk(*)\disk write bytes/sec', `
        '\PhysicalDisk(*)\disk reads/sec', `
        '\PhysicalDisk(*)\disk writes/sec', `
        '\PhysicalDisk(*)\avg. disk sec/read', `
        '\PhysicalDisk(*)\avg. disk sec/write', `
        '\PhysicalDisk(*)\avg. disk sec/transfer', `
        '\PhysicalDisk(*)\current disk queue length'; 
    
    foreach ($DiskPart in $SortedDisks.Keys) {
        $DiskObjects      = $SortedDisks[$DiskPart];
        if ($DiskPart -ne '_Total') {
            $PartCheckPackage = New-IcingaCheckPackage `
            -Name $DiskPart `
            -OperatorAnd `
            -Verbose $Verbosity;
            
        # Check for Disk Availability
        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} Availability', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.Availability  `
                -Translation $ProviderEnums.DeviceAvailabilityName `
                -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.DeviceAvailability.OffLine
            ).CritIfMatch(
                $ProviderEnums.DeviceAvailabilityName.PowerOff
            )
        );
    
        # Check for Disk Accessibility
        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} Accessibility', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.Access `
                -Translation $ProviderEnums.DeviceAccessName `
                -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.DeviceAccess.Unknown
            )
        );

        # Check for Disk HealthStatus
        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} Healthiness', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.HealthStatus `
                -NoPerfData
            )
        );
    
        # Check for Disk Status
        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} Status', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.Status `
                -NoPerfData
            ).WarnIfNotMatch(
                $ProviderEnums.DeviceStatus.OK
            )
        );

        # Check for Disk OperationalStatus
        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} OperationalStatus', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.OperationalStatus `
                -NoPerfData
            ).WarnIfMatch('Offline')
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} IsReadOnly', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.Data.IsReadOnly `
                -Translation $ProviderEnums.IsDeviceReadOnlyName `
                -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.IsDeviceReadOnly.True
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/read', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/read'].value
            ).WarnOutOfRange(
                $DiskAvgReadSecWarning
            ).CritOutOfRange(
                $DiskAvgReadSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/write', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/write'].value
            ).WarnOutOfRange(
                $DiskAvgWriteSecWarning
            ).CritOutOfRange(
                $DiskAvgWriteSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/transfer', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/transfer'].value
            ).WarnOutOfRange(
                $DiskAvgTransSecWarning
            ).CritOutOfRange(
                $DiskAvgTransSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} current disk queue length', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['current disk queue length'].value
            ).WarnOutOfRange(
                $DiskQueueLenWarning
            ).CritOutOfRange(
                $DiskQueueLenCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} disk read bytes/sec', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['disk read bytes/sec'].value
            ).WarnOutOfRange(
                $DiskReadByteSecWarning
            ).CritOutOfRange(
                $DiskReadByteSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} disk write bytes/sec', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['disk write bytes/sec'].value
            ).WarnOutOfRange(
                $DiskWriteByteSecWarning
            ).CritOutOfRange(
                $DiskWriteByteSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} disk reads/sec', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['disk reads/sec'].value
            ).WarnOutOfRange(
                $DiskReadSecWarning
            ).CritOutOfRange(
                $DiskReadSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} disk writes/sec', $DiskObjects.Data.DriveReference)) `
                -Value $DiskObjects.PerfCounter['disk writes/sec'].value
            ).WarnOutOfRange(
                $DiskWriteSecWarning
            ).CritOutOfRange(
                $DiskWriteSecCritical
            )
        );

        $CheckPackage.AddCheck($PartCheckPackage);
        }
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
