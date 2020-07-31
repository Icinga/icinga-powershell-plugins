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
        [switch]$NetworkDevice    = $False,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity           = 0
    )

    $CheckPackage = New-IcingaCheckPackage `
        -Name 'Physicaldisk Package' `
        -OperatorAnd `
        -Verbose $Verbosity;
    $GetDisk = Show-IcingaDiskData;
    $Counters = New-IcingaPerformanceCounterArray `
        '\PhysicalDisk(*)\disk read bytes/sec', `
        '\PhysicalDisk(*)\disk write bytes/sec', `
        '\PhysicalDisk(*)\disk reads/sec', `
        '\PhysicalDisk(*)\disk writes/sec', `
        '\PhysicalDisk(*)\avg. disk sec/read', `
        '\PhysicalDisk(*)\avg. disk sec/write', `
        '\PhysicalDisk(*)\avg. disk sec/transfer', `
        '\PhysicalDisk(*)\current disk queue length'; 
    $SortedDisks = New-IcingaPerformanceCounterStructure -CounterCategory 'PhysicalDisk' -PerformanceCounterHash $Counters;
    
    for ($i = 0; $i -lt $GetDisk.Count; $i++) {
        if ($GetDisk.Values.DriveType[$i] -eq 4 -And $NetworkDevice -eq $False) {
            continue;
        }
        # Check for Disk Availability
        $CheckAvial = New-IcingaCheck `
            -Name ([string]::Format('{0} Availability', $GetDisk.Values.DeviceId[$i])) `
            -Value $GetDisk.Values.Availability[$i]  `
            -Translation $ProviderEnums.DeviceAvailabilityName `
            -NoPerfData;

        $CheckAvial.WarnIfMatch($ProviderEnums.DeviceAvailability.OffLine).CritIfMatch($ProviderEnums.DeviceAvailabilityName.PowerOff) | Out-Null;
        $CheckPackage.AddCheck($CheckAvial);

        # Check for Disk Accessibility
        $CheckAccess = New-IcingaCheck `
            -Name ([string]::Format('{0} Accessibility', $GetDisk.Values.DeviceId[$i])) `
            -Value $GetDisk.Values.Access[$i] `
            -Translation $ProviderEnums.DeviceAccessName `
            -NoPerfData;

        $CheckAccess.WarnIfMatch($ProviderEnums.DeviceAccess.Unknown) | Out-Null;
        $CheckPackage.AddCheck($CheckAccess);

        # Check for Disk MediaType
        $CheckMType = New-IcingaCheck `
            -Name ([string]::Format('{0} MediaType', $GetDisk.Values.DeviceId[$i])) `
            -Value $GetDisk.Values.MediaType[$i] `
            -Translation $ProviderEnums.MediaTypeName `
            -NoPerfData;

        $CheckMType.WarnIfMatch($ProviderEnums.MediaType.FormatIsUnknown) | Out-Null;
        $CheckPackage.AddCheck($CheckMType);

        # Check for Drive Type
        $DriveCheck = New-IcingaCheck `
            -Name ([string]::Format('{0} DriveType', $GetDisk.Values.DeviceId[$i])) `
            -Value $GetDisk.Values.DriveType[$i] `
            -Translation $ProviderEnums.DeviceTypeName `
            -NoPerfData;

        $DriveCheck.WarnIfMatch($ProviderEnums.DeviceType.Unknown) | Out-Null;
        $CheckPackage.AddCheck($DriveCheck);

        # Check for Disk Status
        $StatusCheck = New-IcingaCheck `
            -Name ([string]::Format('{0} FileSystem', $GetDisk.Values.DeviceId[$i])) `
            -Value $GetDisk.Values.FileSystem[$i] `
            -NoPerfData;

        $CheckPackage.AddCheck($StatusCheck);

        foreach ($Disk in $SortedDisks.Keys) {
            $DiskObjects = $SortedDisks[$Disk];
            $Disk = $Disk -Replace '0 ', '';
            foreach ($Counter in $DiskObjects.Keys) {
                $DiskObject = $DiskObjects[$Counter];
                if ($Disk -eq $GetDisk.Values.DeviceId[$i] -And $i -eq ($GetDisk.Count - 1)) {
                    $PerfCheck = New-IcingaCheck `
                        -Name ([string]::Format('{0} {1}', $GetDisk.Values.DeviceId[$i], $Counter)) `
                        -Value $DiskObject.value;

                    if ($Counter -eq 'avg. disk sec/read') {
                        $PerfCheck.WarnOutOfRange($DiskAvgReadSecWarning).CritOutOfRange($DiskAvgReadSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'avg. disk sec/write') {
                        $PerfCheck.WarnOutOfRange($DiskAvgWriteSecWarning).CritOutOfRange($DiskAvgWriteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'avg. disk sec/transfer') {
                        $PerfCheck.WarnOutOfRange($DiskAvgTransSecWarning).CritOutOfRange($DiskAvgTransSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'current disk queue length') {
                        $PerfCheck.WarnOutOfRange($DiskQueueLenWarning).CritOutOfRange($DiskQueueLenCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk read bytes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskReadByteSecWarning).CritOutOfRange($DiskReadByteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk write bytes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskWriteByteSecWarning).CritOutOfRange($DiskWriteByteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk reads/sec') {
                        $PerfCheck.WarnOutOfRange($DiskReadSecWarning).CritOutOfRange($DiskReadSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk writes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskWriteSecWarning).CritOutOfRange($DiskWriteSecCritical) | Out-Null;
                    }
                    
                    $CheckPackage.AddCheck($PerfCheck);
                } elseif ($Disk -ne $GetDisk.Values.DeviceId[$i] -And $i -eq ($GetDisk.Count - 1)) {
                    $PerfCheck = New-IcingaCheck `
                        -Name ([string]::Format('{0} {1}', $Disk, $Counter)) `
                        -Value $DiskObject.value;

                    if ($Counter -eq 'avg. disk sec/read') {
                        $PerfCheck.WarnOutOfRange($DiskAvgReadSecWarning).CritOutOfRange($DiskAvgReadSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'avg. disk sec/write') {
                        $PerfCheck.WarnOutOfRange($DiskAvgWriteSecWarning).CritOutOfRange($DiskAvgWriteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'avg. disk sec/transfer') {
                        $PerfCheck.WarnOutOfRange($DiskAvgTransSecWarning).CritOutOfRange($DiskAvgTransSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'current disk queue length') {
                        $PerfCheck.WarnOutOfRange($DiskQueueLenWarning).CritOutOfRange($DiskQueueLenCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk read bytes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskReadByteSecWarning).CritOutOfRange($DiskReadByteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk write bytes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskWriteByteSecWarning).CritOutOfRange($DiskWriteByteSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk reads/sec') {
                        $PerfCheck.WarnOutOfRange($DiskReadSecWarning).CritOutOfRange($DiskReadSecCritical) | Out-Null;
                    } elseif ($Counter -eq 'disk writes/sec') {
                        $PerfCheck.WarnOutOfRange($DiskWriteSecWarning).CritOutOfRange($DiskWriteSecCritical) | Out-Null;
                    }

                    $CheckPackage.AddCheck($PerfCheck);
                }
            }
        }
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
