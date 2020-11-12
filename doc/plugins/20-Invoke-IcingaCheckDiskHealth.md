
# Invoke-IcingaCheckDiskHealth

## Description

Checks availability, state and utilization of the physical hard disk

Checks the state, accessibility and usage of a physical disk. There are a total
of 8 PerfCounter checks that represent the usage of a physical disk, and each of
them has its own threshold value, i.e. you cannot use only one threshold value to check
how fast a disk is writing and reading.

## Permissions

To execute this plugin you will require to grant the following user permissions.

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

* Performance Log Users

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeDisk | Array | false | @() | Specify the index id of disks you want to include for checks. Example 0, 1 |
| ExcludeDisk | Array | false | @() | Specify the index id of disks you want to exclude from checks. Example 0, 1 |
| IncludePartition | Array | false | @() | Specify the partition drive letters for disks to include for checks. Example C:, D: |
| ExcludePartition | Array | false | @() | Specify the partition drive letters for disks to exclude from checks. Example C:, D: |
| DiskReadSecWarning | Object | false |  | Warning threshold for disk Reads/sec is the rate of read operations on the disk. |
| DiskReadSecCritical | Object | false |  | Critical treshold for disk Reads/sec is the rate of read operations on the disk. |
| DiskWriteSecWarning | Object | false |  | Warning theeshold for disk Writes/sec is the rate of write operations on the disk. |
| DiskWriteSecCritical | Object | false |  | Critical threshold for disk Writes/sec is the rate of write operations on the disk. |
| DiskQueueLenWarning | Object | false |  | Warning threshold for current Disk Queue Length is the number of requests outstanding on the disk at the time the performance data is collected. It also includes requests in service at the time of the collection. This is a instantaneous snapshot, not an average over the time interval. Multi-spindle disk devices can have multiple requests that are active at one time, but other concurrent requests are awaiting service. This counter might reflect a transitory high or low queue length, but if there is a sustained load on the disk drive, it is likely that this will be consistently high. Requests experience delays proportional to the length of this queue minus the number of spindles on the disks. For good performance, this difference should average less than two. |
| DiskQueueLenCritical | Object | false |  | Critical threshold for current Disk Queue Length is the number of requests outstanding on the disk at the time the performance data is collected. It also includes requests in service at the time of the collection. This is a instantaneous snapshot, not an average over the time interval. Multi-spindle disk devices can have multiple requests that are active at one time, but other concurrent requests are awaiting service. This counter might reflect a transitory high or low queue length, but if there is a sustained load on the disk drive, it is likely that this will be consistently high. Requests experience delays proportional to the length of this queue minus the number of spindles on the disks. For good performance, this difference should average less than two. |
| DiskQueueAvgLenWarning | Object | false |  | Warning threshold for Avg. Disk Queue Length is the average number of both read and write requests that were queued for the selected disk during the sample interval. |
| DiskQueueAvgLenCritical | Object | false |  | Critical threshold for Avg. Disk Queue Length is the average number of both read and write requests that were queued for the selected disk during the sample interval. |
| DiskReadByteSecWarning | Object | false |  | Warning threshold for disk Read Bytes/sec is the rate at which bytes are transferred from the disk during read operations. |
| DiskReadByteSecCritical | Object | false |  | Critical threshold for disk Read Bytes/sec is the rate at which bytes are transferred from the disk during read operations. |
| DiskWriteByteSecWarning | Object | false |  | Warning threshold for disk Write Bytes/sec is rate at which bytes are transferred to the disk during write operations. |
| DiskWriteByteSecCritical | Object | false |  | Critical threshold for disk Write Bytes/sec is rate at which bytes are transferred to the disk during write operations. |
| DiskAvgTransSecWarning | Object | false |  | Warning threshold for avg. Disk sec/Transfer is the time, in seconds, of the average disk transfer. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| DiskAvgTransSecCritical | Object | false |  | Critical threshold for avg. Disk sec/Transfer is the time, in seconds, of the average disk transfer. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| DiskAvgReadSecWarning | Object | false |  | Warning threshold for avg. Disk sec/Read is the average time, in seconds, of a read of data from the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| DiskAvgReadSecCritical | Object | false |  | Critical threshold for avg. Disk sec/Read is the average time, in seconds, of a read of data from the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| DiskAvgWriteSecWarning | Object | false |  | Warning threshold for Avg. Disk sec/Write is the average time, in seconds, of a write of data to the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| DiskAvgWriteSecCritical | Object | false |  | Critical threshold for Avg. Disk sec/Write is the average time, in seconds, of a write of data to the disk. If the threshold values are not in seconds, please enter a unit such as (ms, s, m, h, ...) |
| CheckLogicalOnly | SwitchParameter | false | False | Set this to include only disks that have drive letters like C:, D:, ..., assigned to them. Can be combined with include/exclude filters |
| NoPerfData | SwitchParameter | false | False |  |
| Verbosity | Int32 | false | 0 |  |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckDiskHealth  -DiskReadSecWarning 0 -DiskReadSecCritical 1 -DiskAvgTransSecWarning 5s -DiskAvgTransSecCritical 10s -DiskReadByteSecWarning 3000 -DiskReadByteSecCritical 5000 -Verbosity 2
```

### Example Output 1

```powershell
[OK] Check package "Physical Disk Package" (Match All)\_ [OK] Check package "Disk #_Total" (Match All) \_ [OK] _Total avg. disk queue length: 0.001748% \_ [OK] _Total avg. disk sec/read: 0s \_ [OK] _Total avg. disk sec/transfer: 0.000315s \_ [OK] _Total avg. disk sec/write: 0.000315s \_ [OK] _Total disk read bytes/sec: 0B \_ [OK] _Total disk reads/sec: 0 \_ [OK] _Total disk write bytes/sec: 125800.7B \_ [OK] _Total disk writes/sec: 5.025574\_ [OK] Check package "Disk #0" (Match All) \_ [OK] F: C: avg. disk queue length: 0.001751% \_ [OK] F: C: avg. disk sec/read: 0s \_ [OK] F: C: avg. disk sec/transfer: 0.000315s \_ [OK] F: C: avg. disk sec/write: 0.000315s \_ [OK] F: C: current disk queue length: 0 \_ [OK] F: C: disk read bytes/sec: 0B \_ [OK] F: C: disk reads/sec: 0 \_ [OK] F: C: disk write bytes/sec: 125814.7B \_ [OK] F: C: disk writes/sec: 5.018281 \_ [OK] F: C: Is Offline: False \_ [OK] F: C: Is ReadOnly: False \_ [OK] F: C: Operational Status: OK \_ [OK] F: C: Status: OK| 'f_c_avg_disk_sectransfer'=0.000315s;5;10 'f_c_disk_write_bytessec'=125814.7B;; 'f_c_avg_disk_secwrite'=0.000315s;; 'f_c_disk_read_bytessec'=0B;3000;5000 'f_c_avg_disk_secread'=0s;; 'f_c_disk_readssec'=0;0;1 'f_c_avg_disk_queue_length'=0.001751%;;;0;100 'f_c_current_disk_queue_length'=0;; 'f_c_disk_writessec'=5.018281;; '_total_disk_readssec'=0;0;1 '_total_disk_write_bytessec'=125800.7B;; '_total_avg_disk_sectransfer'=0.000315s;5;10 '_total_disk_read_bytessec'=0B;3000;5000 '_total_avg_disk_queue_length'=0.001748%;;;0;100 '_total_avg_disk_secread'=0s;; '_total_disk_writessec'=5.025574;; '_total_current_disk_queue_length'=0;; '_total_avg_disk_secwrite'=0.000315s;;0
```
