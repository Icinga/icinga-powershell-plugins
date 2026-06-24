<#
.SYNOPSIS
    Monitors the number of paths for each MPIO driver on your system.
.DESCRIPTION
    Monitors the number of paths for each MPIO driver on your system.
.PARAMETER Warning
    This threshold is deprecated, please use NumberOfPathWarning instead.
.PARAMETER Critical
    This threshold is deprecated, please use NumberOfPathCritical instead.
.PARAMETER NumberOfPathWarning
    An array of specific Warning thresholds for the number of paths per MPIO device.
    Use the format "VolumeName=Threshold" e.g. "LUN001*=8", also supports Icinga thresholds like "LUN002*=8:"
.PARAMETER NumberOfPathCritical
    An array of specific Critical thresholds for the number of paths per MPIO device.
    Use the format "VolumeName=Threshold" e.g. "LUN001*=6", also supports Icinga thresholds like "LUN001*=6:"
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.ROLE
    ### WMI Permissions

    * Root\WMI
.EXAMPLE
    PS> Invoke-IcingaCheckMPIO -NumberOfPathWarning 'LUN002=9:','LUN003=4' -Verbosity 1;

    [WARNING] Multipath-IO Package: 1 Ok 3 Warning [WARNING] MPIO Disk 2 [WARNING] MPIO Disk 3 (All must be [OK])
    \_ [INFO] ROOT\MPIO\0000_0 Active: 1
    \_ [WARNING] ROOT\MPIO\0000_0 Drives Package (All must be [OK])
        \_ [WARNING] MPIO Disk 2 (All must be [OK])
            \_ [INFO] Assigned Letters: None
            \_ [INFO] Assigned Volumes: LUN002
            \_ [WARNING] Number Paths: Value 8c is lower than threshold 9
        \_ [WARNING] MPIO Disk 3 (All must be [OK])
            \_ [INFO] Assigned Letters: None
            \_ [INFO] Assigned Volumes: LUN003
            \_ [WARNING] Number Paths: Value 8c is greater than threshold 4
        | windows::ifw_mpio::numberofpaths=8c;;;; lun001::ifw_mpio::numberofpaths=4c;;;; lun002::ifw_mpio::numberofpaths=8c;9:;;; lun003::ifw_mpio::numberofpaths=8c;4:;;;
#>
function Invoke-IcingaCheckMPIO()
{
    param (
        $Warning                     = $null,
        $Critical                    = $null,
        [array]$NumberOfPathWarning  = @(),
        [array]$NumberOfPathCritical = @(),
        [switch]$NoPerfData          = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                   = 0
    );

    $CheckPackage            = New-IcingaCheckPackage -Name 'Multipath-IO Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $DrivePackage            = $null;
    $DiskData                = Join-IcingaPhysicalDiskDataPerfCounter;
    [bool]$AddedBasePackages = $false;
    [bool]$FoundMpioData     = $false;

    foreach ($DiskPart in $DiskData.Keys) {
        $DiskObjects           = $DiskData[$DiskPart];

        if ($null -eq $DiskObjects.Data -or $DiskObjects.Data.DiskId -eq '_Total') {
            continue;
        }

        $MpioWarningThreshold  = $null;
        $MpioCriticalThreshold = $null;
        $VolumeNames           = 'None';
        $VolumeIndex           = [string]::Format('MPIO Disk {0}', $DiskObjects.Data.DiskId);
        $MpioInstance          = '';
        $DriveReferences       = 'None';

        # Don't add non-mpio disks to the check package, but continue with the next one, as there might be multiple disks and only some of them are MPIO enabled
        if ($null -eq $DiskObjects.Data.MPIO) {
            continue;
        }

        $FoundMpioData = $true;
        $MpioInstance  = $DiskObjects.Data.MPIO.InstanceName;

        if ($null -ne $DiskObjects.Data.VolumeNames -and $DiskObjects.Data.VolumeNames.Count -gt 0) {
            $VolumeIndex = $DiskObjects.Data.VolumeNames[0];
            $VolumeNames = $DiskObjects.Data.VolumeNames -join '; ';
        }

        if ($null -ne $DiskObjects.Data.DriveReference -and $DiskObjects.Data.DriveReference.Count -gt 0) {
            $DriveReferences = $DiskObjects.Data.DriveReference.Keys -join '; ';
        }

        # Only add these once, as the data is identical for every disk
        if (-not $AddedBasePackages) {
            $DrivePackage          = New-IcingaCheckPackage -Name ([string]::Format('{0} Drives Package', $MpioInstance)) -OperatorAnd -Verbose $Verbosity;

            $IsActive              = New-IcingaCheck `
                -Name ([string]::Format('{0} Active', $MpioInstance)) `
                -Value $DiskObjects.Data.MPIO.Active `
                -NoPerfData;

            $NumberOfDrives        = New-IcingaCheck `
                -Name ([string]::Format('{0} NumberDrives', $MpioInstance)) `
                -Value $DiskObjects.Data.MPIO.NumberDrives `
                -Unit 'c' `
                -MetricIndex $MpioInstance `
                -MetricName 'numberofdrives';

            $CheckPackage.AddCheck($IsActive);
            $CheckPackage.AddCheck($NumberOfDrives);
            $AddedBasePackages = $true;
        }

        foreach ($entry in $NumberOfPathWarning) {
            $parts             = $entry.Split('=', 2);
            [bool]$VolumeMatch = $false;

            foreach ($assignedVolume in $DiskObjects.Data.VolumeNames) {
                if ($assignedVolume -like $parts[0]) {
                    $MpioWarningThreshold = $parts[1];
                    $VolumeMatch          = $true;
                    break;
                }
            }

            if ($VolumeMatch) {
                break;
            }
        }

        foreach ($entry in $NumberOfPathCritical) {
            $parts             = $entry.Split('=', 2);
            [bool]$VolumeMatch = $false;

            foreach ($assignedVolume in $DiskObjects.Data.VolumeNames) {
                if ($assignedVolume -like $parts[0]) {
                    $MpioCriticalThreshold = $parts[1];
                    $VolumeMatch           = $true;
                    break;
                }
            }

            if ($VolumeMatch) {
                break;
            }
        }

        $MPIODiskPackage = New-IcingaCheckPackage -Name ([string]::Format('MPIO Disk {0}', $DiskObjects.Data.DiskId)) -OperatorAnd -Verbose $Verbosity;

        $MpioDrive = New-IcingaCheck `
            -Name 'Number Paths' `
            -Value $DiskObjects.Data.MPIO.NumberPaths `
            -Unit 'c' `
            -MetricIndex $VolumeIndex `
            -MetricName 'numberofpaths';

        $MpioDrive.WarnOutOfRange($MpioWarningThreshold).CritOutOfRange($MpioCriticalThreshold) | Out-Null;

        $MpioVolumes = New-IcingaCheck `
            -Name 'Assigned Volumes' `
            -Value $VolumeNames `
            -NoPerfData;

        $MpioLetters = New-IcingaCheck `
            -Name 'Assigned Letters' `
            -Value $DriveReferences `
            -NoPerfData;

        $MpioPartitions      = New-IcingaCheckPackage -Name 'Partitions' -IsNoticePackage -Verbose $Verbosity;
        [bool]$HasPartitions = $false;

        foreach ($entry in $DiskObjects.Data.PartitionLayout.Keys) {
            $PartitionInfo = $DiskObjects.Data.PartitionLayout[$entry];

            if ($null -eq $PartitionInfo.FileSystem) {
                continue;
            }

            $HasPartitions = $true;

            $MpioPartitionData = New-IcingaCheck `
                -Name ([string]::Format('Filesystem on Partition {0}', $entry)) `
                -Value $PartitionInfo.FileSystem `
                -NoPerfData;

            $MpioPartitions.AddCheck($MpioPartitionData);
        }

        $MPIODiskPackage.AddCheck($MpioDrive);
        $MPIODiskPackage.AddCheck($MpioVolumes);
        $MPIODiskPackage.AddCheck($MpioLetters);

        if ($HasPartitions) {
            $MPIODiskPackage.AddCheck($MpioPartitions);
        }

        $DrivePackage.AddCheck($MPIODiskPackage);
    }

    if (-not $FoundMpioData) {
        $Check = New-IcingaCheck -Name 'MultiPath-IO Check Status' -NoPerfData;
        $Check.SetCritical('No MPIO devices were found on this machine', $TRUE) | Out-Null;
        # Enforce the checks to critical in case we get an exception
        $CheckPackage.AddCheck($Check);
    } else {
        $CheckPackage.AddCheck($DrivePackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
