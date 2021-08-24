<#
.SYNOPSIS
   Will return if a specific physical disk is online, offline and set to read-only mode
.DESCRIPTION
   Will return if a specific physical disk is online, offline and set to read-only mode
.FUNCTIONALITY
   Will return if a specific physical disk is online, offline and set to read-only mode
.EXAMPLE
   PS>Get-IcingaDiskAttribute -DiskId '0';
.PARAMETER PhysicalDisk
   The id of the physical disk to check for with the index id. Example: 0
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://docs.microsoft.com/de-de/windows/win32/api/winioctl/ni-winioctl-ioctl_disk_get_disk_attributes
   https://docs.microsoft.com/de-de/windows/win32/api/winioctl/ns-winioctl-get_disk_attributes
#>

function Get-IcingaDiskAttributes()
{
    param (
        [string]$DiskId
    );

    if ([string]::IsNullOrEmpty($DiskId)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-DiskId"' -ExceptionType 'Custom' -InputString 'Missing argument for Get-IcingaDiskAttributes. You have to specify the index Id of a physical disk.';
    }

    $PhysicalDisk                   = [string]::Format('\\.\PHYSICALDRIVE{0}', $DiskId);
    $IOCTL_DISK_GET_DISK_ATTRIBUTES = 0x000700f0;
    $DISK_ATTRIBUTE_OFFLINE         = 0x0000000000000001;
    $DISK_ATTRIBUTE_READ_ONLY       = 0x0000000000000002;

    if ((Test-IcingaAddTypeExist -Type 'IcingaDiskAttributes') -eq $FALSE) {
        Add-Type -TypeDefinition @"
            using System;
            using System.IO;
            using System.Diagnostics;
            using System.Runtime.InteropServices;

            public static class IcingaDiskAttributes {
                [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern IntPtr CreateFile(
                    [MarshalAs(UnmanagedType.LPTStr)] string filename,
                    [MarshalAs(UnmanagedType.U4)] FileAccess access,
                    [MarshalAs(UnmanagedType.U4)] FileShare share,
                    IntPtr securityAttributes,
                    [MarshalAs(UnmanagedType.U4)] FileMode creationDisposition,
                    [MarshalAs(UnmanagedType.U4)] FileAttributes flagsAndAttributes,
                    IntPtr templateFile
                );

                public struct Icinga_Disk_Data {
                    [MarshalAs(UnmanagedType.U4)]public UInt32 Version;
                    [MarshalAs(UnmanagedType.U4)]public UInt32 Reserved1;
                    [MarshalAs(UnmanagedType.U8)]public UInt64 Attributes;
                }

                [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern bool DeviceIoControl(
                    IntPtr hDevice,
                    uint dwIoControlCode,
                    IntPtr lpInBuffer,
                    uint nInBufferSize,
                    out Icinga_Disk_Data lpOutBuffer,
                    uint nOutBufferSize,
                    out uint lpBytesReturned,
                    IntPtr lpOverlapped
                );

                [DllImport("kernel32.dll", SetLastError=true)]
                public static extern bool CloseHandle(IntPtr hObject);
            }
"@
    }

    [bool]$DiskOffline  = $FALSE;
    [bool]$DiskReadOnly = $FALSE;
    $KernelHandle       = [IcingaDiskAttributes]::CreateFile($PhysicalDisk, 0, [System.IO.FileShare]::ReadWrite, [System.IntPtr]::Zero, [System.IO.FileMode]::Open, 0, [System.IntPtr]::Zero);

    if ($KernelHandle) {
        $DiskData = New-Object -TypeName IcingaDiskAttributes+Icinga_Disk_Data;
        $Value    = New-Object -TypeName UInt32;
        $Result   = [IcingaDiskAttributes]::DeviceIoControl($KernelHandle, $IOCTL_DISK_GET_DISK_ATTRIBUTES, [System.IntPtr]::Zero, 0, [ref]$DiskData, [System.Runtime.InteropServices.Marshal]::SizeOf($DiskData), [ref]$Value, [System.IntPtr]::Zero);
        if ($Result) {
            if (($DiskData.attributes -band $DISK_ATTRIBUTE_OFFLINE) -eq $DISK_ATTRIBUTE_OFFLINE) {
                $DiskOffline = $TRUE;
            }
            if (($DiskData.attributes -band $DISK_ATTRIBUTE_READ_ONLY) -eq $DISK_ATTRIBUTE_READ_ONLY) {
                $DiskReadOnly = $TRUE;
            }
        }
        $Result = [IcingaDiskAttributes]::CloseHandle($KernelHandle);
    }

    return @{
        'Offline'  = $DiskOffline;
        'ReadOnly' = $DiskReadOnly
    }
}
