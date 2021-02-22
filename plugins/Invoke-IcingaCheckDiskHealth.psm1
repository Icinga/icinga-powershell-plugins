<#
.SYNOPSIS
    Checks availability, state and utilization of the physical hard disk
.DESCRIPTION
    Checks the state, accessibility and usage of a physical disk. There are a total
    of 8 PerfCounter checks that represent the usage of a physical disk, and each of
    them has its own threshold value, i.e. you cannot use only one threshold value to check
    how fast a disk is writing and reading.
.ROLE
    ### WMI Permissions

    * root\cimv2
    * root\Microsoft\Windows\Storage

    ### Performance Counter

    * \PhysicalDisk(*)\disk read bytes/sec
    * \PhysicalDisk(*)\disk write bytes/sec
    * \PhysicalDisk(*)\disk reads/sec
    * \PhysicalDisk(*)\disk writes/sec
    * \PhysicalDisk(*)\avg. disk sec/read
    * \PhysicalDisk(*)\avg. disk sec/write
    * \PhysicalDisk(*)\avg. disk sec/transfer
    * \PhysicalDisk(*)\current disk queue length
    * \PhysicalDisk(*)\avg. disk queue length

    ### Required User Groups

    * Performance Monitor Users
.PARAMETER IncludeDisk
    Specify the index id of disks you want to include for checks. Example 0, 1
.PARAMETER ExcludeDisk
    Specify the index id of disks you want to exclude from checks. Example 0, 1
.PARAMETER IncludePartition
    Specify the partition drive letters for disks to include for checks. Example C:, D:
.PARAMETER ExcludePartition
    Specify the partition drive letters for disks to exclude from checks. Example C:, D:
.PARAMETER DiskReadSecWarning
    Warning threshold for disk Reads/sec is the rate of read operations on the disk.
.PARAMETER DiskReadSecCritical
    Critical threshold for disk Reads/sec is the rate of read operations on the disk.
.PARAMETER DiskWriteSecWarning
    Warning threshold for disk Writes/sec is the rate of write operations on the disk.
.PARAMETER DiskWriteSecCritical
    Critical threshold for disk Writes/sec is the rate of write operations on the disk.
.PARAMETER DiskQueueLenWarning
    Warning threshold for current Disk Queue Length is the number of requests outstanding on the disk at the time the performance data is collected.
    It also includes requests in service at the time of the collection. This is a instantaneous snapshot, not an average over the
    time interval. Multi-spindle disk devices can have multiple requests that are active at one time, but other concurrent requests
    are awaiting service. This counter might reflect a transitory high or low queue length, but if there is a sustained load on the
    disk drive, it is likely that this will be consistently high. Requests experience delays proportional to the length of this queue
    minus the number of spindles on the disks. For good performance, this difference should average less than two.
.PARAMETER DiskQueueLenCritical
    Critical threshold for current Disk Queue Length is the number of requests outstanding on the disk at the time the performance data is collected.
    It also includes requests in service at the time of the collection. This is a instantaneous snapshot, not an average over the
    time interval. Multi-spindle disk devices can have multiple requests that are active at one time, but other concurrent requests
    are awaiting service. This counter might reflect a transitory high or low queue length, but if there is a sustained load on the
    disk drive, it is likely that this will be consistently high. Requests experience delays proportional to the length of this queue
    minus the number of spindles on the disks. For good performance, this difference should average less than two.
.PARAMETER DiskQueueAvgLenWarning
    Warning threshold for Avg. Disk Queue Length is the average number of both read and write requests that were queued for the selected disk during the sample interval.
.PARAMETER DiskQueueAvgLenCritical
    Critical threshold for Avg. Disk Queue Length is the average number of both read and write requests that were queued for the selected disk during the sample interval.
.PARAMETER DiskReadByteSecWarning
    Warning threshold for disk Read Bytes/sec is the rate at which bytes are transferred from the disk during read operations.
.PARAMETER DiskReadByteSecCritical
    Critical threshold for disk Read Bytes/sec is the rate at which bytes are transferred from the disk during read operations.
.PARAMETER DiskWriteByteSecWarning
    Warning threshold for disk Write Bytes/sec is rate at which bytes are transferred to the disk during write operations.
.PARAMETER DiskWriteByteSecCritical
    Critical threshold for disk Write Bytes/sec is rate at which bytes are transferred to the disk during write operations.
.PARAMETER DiskAvgTransSecWarning
    Warning threshold for avg. Disk sec/Transfer is the time, in seconds, of the average disk transfer. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER DiskAvgTransSecCritical
    Critical threshold for avg. Disk sec/Transfer is the time, in seconds, of the average disk transfer. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER DiskAvgReadSecWarning
    Warning threshold for avg. Disk sec/Read is the average time, in seconds, of a read of data from the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER DiskAvgReadSecCritical
    Critical threshold for avg. Disk sec/Read is the average time, in seconds, of a read of data from the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER DiskAvgWriteSecWarning
    Warning threshold for Avg. Disk sec/Write is the average time, in seconds, of a write of data to the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER DiskAvgWriteSecCritical
    Critical threshold for Avg. Disk sec/Write is the average time, in seconds, of a write of data to the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...)
.PARAMETER IgnoreOfflineDisks
    Ignores any disk which is having the state `Offline` and returns `Ok` instead of `Warning` for this specific state
.PARAMETER IgnoreReadOnlyDisks
    Ignores any disk which is having the state `Read Only` and returns `Ok` instead of `Warning` for this specific state
.PARAMETER CheckLogicalOnly
    Set this to include only disks that have drive letters like C:, D:, ..., assigned to them. Can be combined with include/exclude filters
.EXAMPLE
    PS> Invoke-IcingaCheckDiskHealth  -DiskReadSecWarning 0 -DiskReadSecCritical 1 -DiskAvgTransSecWarning 5s -DiskAvgTransSecCritical 10s -DiskReadByteSecWarning 3000 -DiskReadByteSecCritical 5000 -Verbosity 2
    [OK] Check package "Physical Disk Package" (Match All)
    \_ [OK] Check package "Disk #_Total" (Match All)
       \_ [OK] _Total avg. disk queue length: 0.001748%
       \_ [OK] _Total avg. disk sec/read: 0s
       \_ [OK] _Total avg. disk sec/transfer: 0.000315s
       \_ [OK] _Total avg. disk sec/write: 0.000315s
       \_ [OK] _Total disk read bytes/sec: 0B
       \_ [OK] _Total disk reads/sec: 0
       \_ [OK] _Total disk write bytes/sec: 125800.7B
       \_ [OK] _Total disk writes/sec: 5.025574
    \_ [OK] Check package "Disk #0" (Match All)
       \_ [OK] F: C: avg. disk queue length: 0.001751%
       \_ [OK] F: C: avg. disk sec/read: 0s
       \_ [OK] F: C: avg. disk sec/transfer: 0.000315s
       \_ [OK] F: C: avg. disk sec/write: 0.000315s
       \_ [OK] F: C: current disk queue length: 0
       \_ [OK] F: C: disk read bytes/sec: 0B
       \_ [OK] F: C: disk reads/sec: 0
       \_ [OK] F: C: disk write bytes/sec: 125814.7B
       \_ [OK] F: C: disk writes/sec: 5.018281
       \_ [OK] F: C: Is Offline: False
       \_ [OK] F: C: Is ReadOnly: False
       \_ [OK] F: C: Operational Status: OK
       \_ [OK] F: C: Status: OK
    | 'f_c_avg_disk_sectransfer'=0.000315s;5;10 'f_c_disk_write_bytessec'=125814.7B;; 'f_c_avg_disk_secwrite'=0.000315s;; 'f_c_disk_read_bytessec'=0B;3000;5000 'f_c_avg_disk_secread'=0s;; 'f_c_disk_readssec'=0;0;1 'f_c_avg_disk_queue_length'=0.001751%;;;0;100 'f_c_current_disk_queue_length'=0;; 'f_c_disk_writessec'=5.018281;; '_total_disk_readssec'=0;0;1 '_total_disk_write_bytessec'=125800.7B;; '_total_avg_disk_sectransfer'=0.000315s;5;10 '_total_disk_read_bytessec'=0B;3000;5000 '_total_avg_disk_queue_length'=0.001748%;;;0;100 '_total_avg_disk_secread'=0s;; '_total_disk_writessec'=5.025574;; '_total_current_disk_queue_length'=0;; '_total_avg_disk_secwrite'=0.000315s;;
    0
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://github.com/Icinga/icinga-powershell-plugins
   https://icinga.com/docs/windows/latest/doc/01-Introduction/
#>
function Invoke-IcingaCheckDiskHealth()
{
    param
    (
        [array]$IncludeDisk          = @(),
        [array]$ExcludeDisk          = @(),
        [array]$IncludePartition     = @(),
        [array]$ExcludePartition     = @(),
        $DiskReadSecWarning          = $null,
        $DiskReadSecCritical         = $null,
        $DiskWriteSecWarning         = $null,
        $DiskWriteSecCritical        = $null,
        $DiskQueueLenWarning         = $null,
        $DiskQueueLenCritical        = $null,
        $DiskQueueAvgLenWarning      = $null,
        $DiskQueueAvgLenCritical     = $null,
        $DiskReadByteSecWarning      = $null,
        $DiskReadByteSecCritical     = $null,
        $DiskWriteByteSecWarning     = $null,
        $DiskWriteByteSecCritical    = $null,
        $DiskAvgTransSecWarning      = $null,
        $DiskAvgTransSecCritical     = $null,
        $DiskAvgReadSecWarning       = $null,
        $DiskAvgReadSecCritical      = $null,
        $DiskAvgWriteSecWarning      = $null,
        $DiskAvgWriteSecCritical     = $null,
        [switch]$IgnoreOfflineDisks  = $FALSE,
        [switch]$IgnoreReadOnlyDisks = $FALSE,
        [switch]$CheckLogicalOnly    = $FALSE,
        [switch]$NoPerfData          = $FALSE,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity             = 0
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
        '\PhysicalDisk(*)\current disk queue length',
        '\PhysicalDisk(*)\avg. disk queue length'
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
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0} Operational Status', $Partition)) `
                            -Value 'OK' `
                            -NoPerfData
                    )
                )
            } else {
                $PartCheckPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0} Operational Status', $Partition)) `
                            -Value ([string]::Join(',', $OperationalStatus.Values)) `
                            -NoPerfData
                    ).SetCritical()
                )
            }

            # Check for Disk Status
            $PartCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} Status', $Partition)) `
                        -Value $DiskObjects.Data.Status `
                        -NoPerfData
                ).WarnIfNotMatch(
                    $ProviderEnums.DeviceStatus.OK
                )
            );

            $DiskOfflineCheck  = New-IcingaCheck `
                -Name ([string]::Format('{0} Is Offline', $Partition)) `
                -Value $DiskObjects.Data.IsOffline `
                -NoPerfData;

            if ($IgnoreOfflineDisks -eq $FALSE) {
                $DiskOfflineCheck.WarnIfMatch('True') | Out-Null;
            }

            $DiskReadOnlyCheck = New-IcingaCheck `
                -Name ([string]::Format('{0} Is ReadOnly', $Partition)) `
                -Value $DiskObjects.Data.IsReadOnly `
                -NoPerfData;

            if ($IgnoreReadOnlyDisks -eq $FALSE) {
                $DiskReadOnlyCheck.WarnIfMatch('True') | Out-Null;
            }

            # Check for Disk OperationalStatus
            $PartCheckPackage.AddCheck($DiskOfflineCheck);
            $PartCheckPackage.AddCheck($DiskReadOnlyCheck);
        } else {
            if ($CheckLogicalOnly) {
                continue;
            }
        }

        $PartCheckPackage.AddCheck(
            (
                New-IcingaCheck `
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
            (
                New-IcingaCheck `
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
            (
                New-IcingaCheck `
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
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} current disk queue length', $Partition)) `
                    -Value $DiskObjects.PerfCounter['current disk queue length'].value
            ).WarnOutOfRange(
                $DiskQueueLenWarning
            ).CritOutOfRange(
                $DiskQueueLenCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} avg. disk queue length', $Partition)) `
                    -Value $DiskObjects.PerfCounter['avg. disk queue length'].value `
                    -Unit '%'
            ).WarnOutOfRange(
                $DiskQueueAvgLenWarning
            ).CritOutOfRange(
                $DiskQueueAvgLenCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (
                New-IcingaCheck `
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
            (
                New-IcingaCheck `
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
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} disk reads/sec', $Partition)) `
                    -Value $DiskObjects.PerfCounter['disk reads/sec'].value
            ).WarnOutOfRange(
                $DiskReadSecWarning
            ).CritOutOfRange(
                $DiskReadSecCritical
            )
        );

        $PartCheckPackage.AddCheck(
            (
                New-IcingaCheck `
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

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
