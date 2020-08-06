<#
.SYNOPSIS
    Checks availability, state and utilization of the physical hard disk
.DESCRIPTION
    Checks the state, accessibility and usage of a physical disk. There are a total 
    of 8 PerfCounter checks that represent the usage of a physical disk, and each of 
    them has its own threshold value, i.e. you cannot use only one threshold value to check 
    how fast a disk is writing and reading.
.PARAMETER IncludeDisk
    Specify the index id of disks you want to include for checks. Example 0, 1
.PARAMETER ExcludeDisk
    Specify the index id of disks you want to exclude from checks. Example 0, 1
.PARAMETER IncludePartition
    Specify the partition drive letters for disks to include for checks. Example C:, D:
.PARAMETER ExcludePartition
    Specify the partition drive letters for disks to exclude from checks. Example C:, D:
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
    Used to specify a 'disk read bytes/sec' threshold in Warning status. Here no unit must be entered but the threshold value is always in Byte.
.PARAMETER DiskReadByteSecCritical
    Used to specify a 'disk read bytes/sec' threshold in Critical status. Here no unit must be entered but the threshold value is always in Byte.
.PARAMETER DiskWriteByteSecWarning
    Used to specify a 'disk write bytes/sec' threshold in Warning status. Here no unit must be entered but the threshold value is always in Byte.
.PARAMETER DiskWriteByteSecCritical 
    Used to specify a 'disk write bytes/sec' threshold in Critical status. Here no unit must be entered but the threshold value is always in Byte.
.PARAMETER DiskAvgTransSecWarning
    Used to specify a 'avg. disk sec/transfer' threshold in Warning status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER DiskAvgTransSecCritical
    Used to specify a 'avg. disk sec/transfer' threshold in Critical status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER DiskAvgReadSecWarning
    Used to specify a 'avg. disk sec/read' threshold in Warning status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER DiskAvgReadSecCritical
    Used to specify a 'avg. disk sec/read' threshold in Critical status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER DiskAvgWriteSecWarning
    Used to specify a 'avg. disk sec/write' threshold in Warning status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER DiskAvgWriteSecCritical
    Used to specify a 'avg. disk sec/write' threshold in Critical status. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h etc.)
.PARAMETER CheckLogicalOnly
    Set this to include only disks that have drive letters like C:, D:, amd so on assigned to them. Can be combined with include/exclude filters
.EXAMPLE
    PS> Invoke-IcingaCheckDiskHealth  -DiskReadSecWarning 0 -DiskReadSecCritical 1 -DiskAvgTransSecWarning 5s -DiskAvgTransSecCritical 10s -DiskReadByteSecWarning 3000 -DiskReadByteSecCritical 5000 -Verbosity 2
    [CRITICAL] Check package "Physicaldisk Package" (Match All) - [CRITICAL] C: F: disk read bytes/sec 
    \_ [CRITICAL] Check package "\\.\PHYSICALDRIVE0" (Match All)
       \_ [OK] C: F: avg. disk sec/read: 0s
       \_ [OK] C: F: avg. disk sec/transfer: 0s
       \_ [OK] C: F: avg. disk sec/write: 0s
       \_ [OK] C: F: current disk queue length: 0
       \_ [CRITICAL] C: F: disk read bytes/sec: Value "934031B" is greater than threshold "5000B"
       \_ [OK] C: F: disk reads/sec: 0
       \_ [OK] C: F: disk write bytes/sec: 0B
       \_ [OK] C: F: disk writes/sec: 0
       \_ [OK] C: F: IsOffline: False
       \_ [OK] C: F: IsReadOnly: False
       \_ [OK] C: F: Status: OK
    | 'c_f_disk_write_bytessec'=0B;; 'c_f_current_disk_queue_length'=0;; 'c_f_avg_disk_secread'=0s;; 'c_f_avg_disk_secwrite'=0s;; 'c_f_disk_read_bytessec'=934031;3000;5000 'c_f_avg_disk_sectransfer'=0S;5;10 'c_f_disk_writessec'=0;; 'c_f_disk_readssec'=0;0;1
    1
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://github.com/Icinga/icinga-powershell-plugins
   https://icinga.com/docs/windows/latest/doc/01-Introduction/
#>
function Invoke-IcingaCheckDiskHealth() 
{
    param
    (
        [array]$IncludeDisk       = @(),
        [array]$ExcludeDisk       = @(),
        [array]$IncludePartition  = @(),
        [array]$ExcludePartition  = @(),
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
        [switch]$CheckLogicalOnly = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity           = 0
    )

    $CheckPackage = New-IcingaCheckPackage `
        -Name 'Physical Disk Package' `
        -OperatorAnd `
        -Verbose $Verbosity;
    $SortedDisks = Join-IcingaPhysicalDiskDataPerfCounter -DiskCounter @(
            '\PhysicalDisk(*)\disk read bytes/sec',
            '\PhysicalDisk(*)\disk write bytes/sec',
            '\PhysicalDisk(*)\disk reads/sec',
            '\PhysicalDisk(*)\disk writes/sec',
            '\PhysicalDisk(*)\avg. disk sec/read',
            '\PhysicalDisk(*)\avg. disk sec/write',
            '\PhysicalDisk(*)\avg. disk sec/transfer',
            '\PhysicalDisk(*)\current disk queue length'
        ) `
        -IncludeDisk $IncludeDisk `
        -ExcludeDisk $ExcludeDisk `
        -IncludePartition $IncludePartition `
        -ExcludePartition $ExcludePartition;

    $DiskAvgReadSecWarning   = ConvertTo-SecondsFromIcingaThresholds $DiskAvgReadSecWarning;
    $DiskAvgReadSecCritical  = ConvertTo-SecondsFromIcingaThresholds $DiskAvgReadSecCritical;
    $DiskAvgWriteSecWarning  = ConvertTo-SecondsFromIcingaThresholds $DiskAvgWriteSecWarning;
    $DiskAvgWriteSecCritical = ConvertTo-SecondsFromIcingaThresholds $DiskAvgWriteSecCritical;
    $DiskAvgTransSecWarning  = ConvertTo-SecondsFromIcingaThresholds $DiskAvgTransSecWarning;
    $DiskAvgTransSecCritical = ConvertTo-SecondsFromIcingaThresholds $DiskAvgTransSecCritical;

    foreach ($DiskPart in $SortedDisks.Keys) {
        $DiskObjects      = $SortedDisks[$DiskPart];

        $PartCheckPackage = New-IcingaCheckPackage `
            -Name ([string]::Format('Disk #{0}', $DiskPart)) `
            -OperatorAnd `
            -Verbose $Verbosity;

        [string]$Partition = $DiskPart;

        if ($null -ne $DiskObjects.Data) {
            # Check for Disk Availability
            if ($DiskObjects.Data.DriveReference.Count -ne 0) {
                $Partition = $DiskObjects.Data.DriveReference.Keys;
            }
            $OperationalStatus = $DiskObjects.Data.OperationalStatus;
            $OperCount = $OperationalStatus.Count;

            if (($OperCount -eq 1 -And $OperationalStatus.ContainsKey($ProviderEnums.DiskOperationalStatusName.Ok)) -or ($OperCount -eq 1 -And $OperationalStatus.ContainsKey($ProviderEnums.DiskOperationalStatusName.Online))) {
                $PartCheckPackage.AddCheck(
                    (New-IcingaCheck `
                        -Name ([string]::Format('{0} Operational Status', $Partition)) `
                        -Value 'OK' `
                        -NoPerfData
                    )
                )
            } else {
                $PartCheckPackage.AddCheck(
                    (New-IcingaCheck `
                        -Name ([string]::Format('{0} Operational Status', $Partition)) `
                        -Value ([string]::Join(',', $OperationalStatus.Values)) `
                        -NoPerfData
                    ).SetCritical()
                )
            }

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
                    -Name ([string]::Format('{0} Is Offline', $Partition)) `
                    -Value $DiskObjects.Data.IsOffline `
                    -NoPerfData
                ).WarnIfMatch('True')
            );

            $PartCheckPackage.AddCheck(
                (New-IcingaCheck `
                    -Name ([string]::Format('{0} Is ReadOnly', $Partition)) `
                    -Value $DiskObjects.Data.IsReadOnly `
                    -NoPerfData
                ).WarnIfMatch('True')
            );
        } else {
            if ($CheckLogicalOnly) {
                continue;
            }
        }

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/read', $Partition)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/read'].value `
                -Unit 's'
            ).WarnOutOfRange(
                $DiskAvgReadSecWarning
            ).CritOutOfRange(
                $DiskAvgReadSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/write', $Partition)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/write'].value `
                -Unit 's'
            ).WarnOutOfRange(
                $DiskAvgWriteSecWarning
            ).CritOutOfRange(
                $DiskAvgWriteSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} avg. disk sec/transfer', $Partition)) `
                -Value $DiskObjects.PerfCounter['avg. disk sec/transfer'].value `
                -Unit 's'
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
                -Value $DiskObjects.PerfCounter['disk read bytes/sec'].value `
                -Unit 'B'
            ).WarnOutOfRange(
                $DiskReadByteSecWarning
            ).CritOutOfRange(
                $DiskReadByteSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (New-IcingaCheck `
                -Name ([string]::Format('{0} disk write bytes/sec', $Partition)) `
                -Value $DiskObjects.PerfCounter['disk write bytes/sec'].value `
                -Unit 'B'
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

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
