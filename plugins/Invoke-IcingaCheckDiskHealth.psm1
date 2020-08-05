<#
.SYNOPSIS
    Checks availability, state and utilization of the physical hard disk
.DESCRIPTION
    Checks the state, accessibility and usage of a physical disk. There are a total 
    of 8 PerfCounter checks that represent the usage of a physical disk, and each of 
    them has its own threshold value, i.e. you cannot use only one threshold value to check 
    how fast a disk is writing and reading.
.PARAMETER DiskReadSecWarning
    Used to specify a 'disk read/sec' threshold in Warning status
.PARAMETER DiskReadSecCritical
    Used to specify a 'disk read/sec' threshold in Critical status
.PARAMETER DiskWriteSecWarning
    Used to specify a 'disk write/sec' threshold in Warning status
.PARAMETER DiskWriteSecCritical
    Used to specify a 'disk write/sec' threshold in Critical status
.PARAMETER DiskQueueLenWarning
    Used to specify a 'current disk queue length' threshold in Warning status
.PARAMETER DiskQueueLenCritical
    Used to specify a 'current disk queue length' threshold in Critical status
.PARAMETER DiskReadByteSecWarning
    Used to specify a 'disk read bytes/sec' threshold in Warning status
.PARAMETER DiskReadByteSecCritical
    Used to specify a 'disk read bytes/sec' threshold in Critical status
.PARAMETER DiskWriteByteSecWarning
    Used to specify a 'disk write bytes/sec' threshold in Warning status
.PARAMETER DiskWriteByteSecCritical 
    Used to specify a 'disk write bytes/sec' threshold in Critical status
.PARAMETER DiskAvgTransSecWarning
    Used to specify a 'avg. disk sec/transfer' threshold in Warning status
.PARAMETER DiskAvgTransSecCritical
    Used to specify a 'avg. disk sec/transfer' threshold in Critical status
.PARAMETER DiskAvgReadSecWarning
    Used to specify a 'avg. disk sec/read' threshold in Warning status
.PARAMETER DiskAvgReadSecCritical
    Used to specify a 'avg. disk sec/read' threshold in Critical status
.PARAMETER DiskAvgWriteSecWarning
    Used to specify a 'avg. disk sec/write' threshold in Warning status
.PARAMETER DiskAvgWriteSecCritical
    Used to specify a 'avg. disk sec/write' threshold in Critical status
.EXAMPLE
    PS> Invoke-IcingaCheckDiskHealth  -DiskReadSecWarning 0 -DiskReadSecCritical 1 -DiskAvgTransSecWarning 5 -DiskAvgTransSecCritical 10 -DiskReadByteSecWarning 3000 -DiskReadByteSecCritical 5000 -Verbosity 2
    [CRITICAL] Check package "Physicaldisk Package" (Match All) - [CRITICAL] C: F: disk read bytes/sec [WARNING] C: F: Accessibility 
    \_ [CRITICAL] Check package "C: F:" (Match All)
       \_ [WARNING] C: F: Accessibility: Value "Unknown" is matching threshold "Unknown"
       \_ [OK] C: F: Availability: Unknown
       \_ [OK] C: F: avg. disk sec/read: 0
       \_ [OK] C: F: avg. disk sec/transfer: 0
       \_ [OK] C: F: avg. disk sec/write: 0
       \_ [OK] C: F: current disk queue length: 0
       \_ [CRITICAL] C: F: disk read bytes/sec: Value "934031" is greater than threshold "5000"
       \_ [OK] C: F: disk reads/sec: 0
       \_ [OK] C: F: disk write bytes/sec: 0
       \_ [OK] C: F: disk writes/sec: 0
       \_ [OK] C: F: IsOffline: False
       \_ [OK] C: F: IsReadOnly: False
       \_ [OK] C: F: Status: OK
    | 'c_f_disk_write_bytessec'=0;; 'c_f_current_disk_queue_length'=0;; 'c_f_avg_disk_secread'=0;; 'c_f_avg_disk_secwrite'=0;; 'c_f_disk_read_bytessec'=934031;3000;5000 'c_f_avg_disk_sectransfer'=0;5;10 'c_f_disk_writessec'=0;; 'c_f_disk_readssec'=0;0;1
    2
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
            -Name $DiskObjects.Data.DriveReference `
            -OperatorAnd `
            -Verbose $Verbosity;
            
            # Check for Disk Availability
            $Partition = [string]$DiskObjects.Data.DriveReference;
            if ([string]::IsNullOrEmpty($DiskObjects.Data.Availability)) {
                $DiskObjects.Data.Availability = $ProviderEnums.DeviceAvailability.Unknown;
            }
            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} Availability', $Partition)) `
                    -Value $DiskObjects.Data.Availability  `
                    -Translation $ProviderEnums.DeviceAvailabilityName `
                    -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.DeviceAvailability.OffLine
                ).CritIfMatch(
                    $ProviderEnums.DeviceAvailability.PowerOff
                )
            );
    
            # Check for Disk Accessibility
            if ([string]::IsNullOrEmpty($DiskObjects.Data.Access)) {
                $DiskObjects.Data.Access = $ProviderEnums.DeviceAccess.Unknown;
            }
            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} Accessibility', $Partition)) `
                    -Value $DiskObjects.Data.Access `
                    -Translation $ProviderEnums.DeviceAccessName `
                    -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.DeviceAccess.Unknown
                )
            );
    
            # Check for Disk Status
            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} Status', $Partition)) `
                    -Value $DiskObjects.Data.Status `
                    -NoPerfData
                ).WarnIfNotMatch(
                    $ProviderEnums.DeviceStatus.OK
                )
            );

            # Check for Disk OperationalStatus
            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} IsOffline', $Partition)) `
                    -Value $DiskObjects.Data.IsOffline `
                    -NoPerfData
                ).WarnIfMatch('True')
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} IsReadOnly', $Partition)) `
                    -Value $DiskObjects.Data.IsReadOnly `
                    -NoPerfData
                ).WarnIfMatch('True')
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} avg. disk sec/read', $Partition)) `
                    -Value $DiskObjects.PerfCounter['avg. disk sec/read'].value
                ).WarnOutOfRange(
                    $DiskAvgReadSecWarning
                ).CritOutOfRange(
                    $DiskAvgReadSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} avg. disk sec/write', $Partition)) `
                    -Value $DiskObjects.PerfCounter['avg. disk sec/write'].value
                ).WarnOutOfRange(
                    $DiskAvgWriteSecWarning
                ).CritOutOfRange(
                    $DiskAvgWriteSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} avg. disk sec/transfer', $Partition)) `
                    -Value $DiskObjects.PerfCounter['avg. disk sec/transfer'].value
                ).WarnOutOfRange(
                    $DiskAvgTransSecWarning
                ).CritOutOfRange(
                    $DiskAvgTransSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} current disk queue length', $Partition)) `
                    -Value $DiskObjects.PerfCounter['current disk queue length'].value
                ).WarnOutOfRange(
                    $DiskQueueLenWarning
                ).CritOutOfRange(
                    $DiskQueueLenCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} disk read bytes/sec', $Partition)) `
                    -Value $DiskObjects.PerfCounter['disk read bytes/sec'].value
                ).WarnOutOfRange(
                    $DiskReadByteSecWarning
                ).CritOutOfRange(
                    $DiskReadByteSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} disk write bytes/sec', $Partition)) `
                    -Value $DiskObjects.PerfCounter['disk write bytes/sec'].value
                ).WarnOutOfRange(
                    $DiskWriteByteSecWarning
                ).CritOutOfRange(
                    $DiskWriteByteSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} disk reads/sec', $Partition)) `
                    -Value $DiskObjects.PerfCounter['disk reads/sec'].value
                ).WarnOutOfRange(
                    $DiskReadSecWarning
                ).CritOutOfRange(
                    $DiskReadSecCritical
                )
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} disk writes/sec', $Partition)) `
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
