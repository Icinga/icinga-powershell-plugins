<#
.SYNOPSIS
    Checks how much space on a partition is used.
.DESCRIPTION
    Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g 'C:' is at 8% usage, WARNING is set to 60, CRITICAL is set to 80. In this case the check will return OK.

    The plugin will return `UNKNOWN` in case partition data (size and free space) can not be fetched. This is
    normally happening in case the user the plugin is running with does not have permissions to fetch this
    specific partition data.

    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check how much usage there is on an partition.
    Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.

    The plugin will return `UNKNOWN` in case partition data (size and free space) can not be fetched. This is
    normally happening in case the user the plugin is running with does not have permissions to fetch this
    specific partition data.
.ROLE
    ### WMI Permissions

    * Root\Cimv2

    ### Performance Counter

    * LogicalDisk(*)\% free space
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition C'=8,06204986572266%;60;;0;100 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Exclude "C:\"
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Include "C:\"
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition C'=8,06204986572266%;60;;0;100
.PARAMETER Warning
    Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
    Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Exclude
    Used to specify an array of partitions to be excluded.
    e.g. 'C:\','D:\'
.PARAMETER Include
    Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.
    e.g. 'C:\','D:\'
.PARAMETER IgnoreEmptyChecks
    Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example).
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER SkipUnknown
    Allows to set Unknown partitions to Ok in case no metrics could be loaded.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckUsedPartitionSpace()
{
    param(
        $Warning                   = $null,
        $Critical                  = $null,
        [array]$Include            = @(),
        [array]$Exclude            = @(),
        [switch]$IgnoreEmptyChecks = $FALSE,
        [switch]$NoPerfData        = $FALSE,
        [switch]$SkipUnknown       = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $DiskFree        = Get-IcingaDiskPartitions;
    $DiskPackage     = New-IcingaCheckPackage -Name 'Used Partition Space' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks;
    $DiskBytePackage = New-IcingaCheckPackage -Name 'Used Partition Space in Bytes' -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks -Hidden;

    foreach ($Letter in $DiskFree.Keys) {
        if ($Include.Count -ne 0) {
            $Include = $Include.trim(' :/\');
            if (-Not ($Include.Contains($Letter))) {
                continue;
            }
        }

        if ($Exclude.Count -ne 0) {
            $Exclude = $Exclude.trim(' :/\');
            if ($Exclude.Contains($Letter)) {
                continue;
            }
        }

        $SetUnknown = $FALSE;
        $CheckName  = [string]::Format('Partition {0}', $Letter);

        $Unit               = Get-UnitPrefixIEC $DiskFree.([string]::Format($Letter))."Size";
        $PerfUnit           = Get-UnitPrefixSI  $DiskFree.([string]::Format($Letter))."Size";
        $FreeSpace          = (100-($DiskFree.([string]::Format($Letter))."Free Space"));
        $Bytes              = [math]::Round(($DiskFree.([string]::Format($Letter))."Size") * $FreeSpace / 100);
        $ByteString         = [string]::Format('{0}B', $Bytes);
        $ByteValueConverted = Convert-Bytes -Value $ByteString -Unit $Unit;
        $DiskSizeBytes      = $DiskFree[$Letter]['Size'];

        if ([string]::IsNullOrEmpty($DiskFree.([string]::Format($Letter))."Size") -Or [string]::IsNullOrEmpty($DiskFree.([string]::Format($Letter))."Free Space")) {
            $SetUnknown = $TRUE;
            $CheckName  = [string]::Format('Partition {0}: No data available for calculation', $Letter);
            $FreeSpace  = $null;
        }

        if ($null -eq $DiskSizeBytes) {
            $DiskSizeBytes = 0;
        }
        $DiskSize           = Convert-Bytes -Value ([string]::Format('{0}B', $DiskSizeBytes)) -Unit $Unit;
        $DiskTotalWarning   = $null;
        $DiskTotalCritical  = $null;

        if ($null -ne $Warning -And $DiskSize.Value -ne 0) {
            $DiskTotalWarning = $DiskSize.Value / 100 * $Warning;
        }
        if ($null -ne $Critical -And $DiskSize.Value -ne 0) {
            $DiskTotalCritical = $DiskSize.Value / 100 * $Critical;
        }

        $IcingaCheckByte = New-IcingaCheck -Name ([string]::Format( 'Used Space Partition {0}', $Letter )) -Value $ByteValueConverted.Value -Unit $PerfUnit -Minimum 0 -Maximum $DiskSize.Value -NoPerfData:$SetUnknown;
        if ($SetUnknown -eq $FALSE) {
            $IcingaCheckByte.WarnOutOfRange($DiskTotalWarning).CritOutOfRange($DiskTotalCritical) | Out-Null;
        } else {
            if ($SkipUnknown -eq $FALSE) {
                $IcingaCheck.SetUnknown() | Out-Null;
            }
        }
        $DiskBytePackage.AddCheck($IcingaCheckByte);

        $IcingaCheck = New-IcingaCheck -Name $CheckName -Value $FreeSpace -Unit '%' -NoPerfData:$SetUnknown;
        if ($SetUnknown -eq $FALSE) {
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        } else {
            if ($SkipUnknown -eq $FALSE) {
                $IcingaCheck.SetUnknown() | Out-Null;
            }
        }
        $DiskPackage.AddCheck($IcingaCheck);

        $DiskPackage.AddCheck($DiskBytePackage);
    }

    return (New-IcingaCheckResult -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}
