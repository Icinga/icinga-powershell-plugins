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

    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning '60%' -Critical '80%' -CheckUsedSpace
    [CRITICAL] Used Partition Space: 2 Critical 1 Ok [CRITICAL] Partition C: (85.43% (795.22GiB)), Partition G: (87.50% (1.59TiB))
    \_ [CRITICAL] Partition C: 85.43% (795.22GiB) is greater than threshold 80% (744.71GiB)
    \_ [CRITICAL] Partition G: 87.50% (1.59TiB) is greater than threshold 80% (1.46TiB)
    | 'used_space_partition_r'=326052500000B;2400460800000;3200614400000;0;4000768000000 'used_space_partition_g'=1750369000000B;1200228600000;1600304800000;0;2000381000000 'used_space_partition_c'=853859000000B;599716680000;799622240000;0;999527800000
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning '740GB' -Critical '800GB' -CheckUsedSpace
    [CRITICAL] Used Partition Space: 2 Critical 1 Ok [CRITICAL] Partition C: (795.23GiB), Partition G: (1.59TiB)
    \_ [CRITICAL] Partition C: 795.23GiB is greater than threshold 745.06GiB
    \_ [CRITICAL] Partition G: 1.59TiB is greater than threshold 745.06GiB
    | 'used_space_partition_r'=326052500000B;740000000000;800000000000;0;4000768000000 'used_space_partition_g'=1750369000000B;740000000000;800000000000;0;2000381000000 'used_space_partition_c'=853874000000B;740000000000;800000000000;0;999527800000
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning '300GB:' -Critical '200GB:'
    [CRITICAL] Free Partition Space: 1 Critical 1 Warning 1 Ok [CRITICAL] Partition C: (135.65GiB) [WARNING] Partition G: (232.84GiB)
    \_ [CRITICAL] Partition C: 135.65GiB is lower than threshold 186.26GiB
    \_ [WARNING] Partition G: 232.84GiB is lower than threshold 279.40GiB
    | 'free_space_partition_g'=250012600000B;300000000000:;200000000000:;0;2000381000000 'free_space_partition_r'=3674716000000B;300000000000:;200000000000:;0;4000768000000 'free_space_partition_c'=145653700000B;300000000000:;200000000000:;0;999527800000
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning '20%:' -Critical '10%:'
    [WARNING] Free Partition Space: 2 Warning 1 Ok [WARNING] Partition C: (14.57% (135.65GiB)), Partition G: (12.50% (232.84GiB))
    \_ [WARNING] Partition C: 14.57% (135.65GiB) is lower than threshold 20% (186.18GiB)
    \_ [WARNING] Partition G: 12.50% (232.84GiB) is lower than threshold 20% (372.60GiB)
    | 'free_space_partition_g'=250012600000B;400076200000:;200038100000:;0;2000381000000 'free_space_partition_r'=3674716000000B;800153600000:;400076800000:;0;4000768000000 'free_space_partition_c'=145656400000B;199905560000:;99952780000:;0;999527800000
.PARAMETER Warning
    Used to specify a Warning threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Critical
    Used to specify a Critical threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Exclude
    Used to specify an array of partitions to be excluded.
    e.g. 'C:','D:'
.PARAMETER Include
    Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.
    e.g. 'C:','D:'
.PARAMETER IgnoreEmptyChecks
    Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example).
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER SkipUnknown
    Allows to set Unknown partitions to Ok in case no metrics could be loaded.
.PARAMETER CheckUsedSpace
    Switches the behaviour of the plugin from checking with threshold for the free space (default) to the remaining (used) space instead
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckPartitionSpace()
{
    param (
        $Warning                   = $null,
        $Critical                  = $null,
        [array]$Include            = @(),
        [array]$Exclude            = @(),
        [switch]$IgnoreEmptyChecks = $FALSE,
        [switch]$NoPerfData        = $FALSE,
        [switch]$SkipUnknown       = $FALSE,
        [switch]$CheckUsedSpace    = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $Disks       = Get-IcingaPartitionSpace;
    $DiskPackage = $null;

    if ($CheckUsedSpace) {
        $DiskPackage = New-IcingaCheckPackage -Name 'Used Partition Space' -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks -OperatorAnd -AddSummaryHeader;
    } else {
        $DiskPackage = New-IcingaCheckPackage -Name 'Free Partition Space' -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks -OperatorAnd -AddSummaryHeader;
    }

    foreach ($partition in $Disks.Keys) {
        $partition        = $Disks[$partition];
        $ProcessPartition = $TRUE;

        if ([string]::IsNullOrEmpty($partition.DriveLetter)) {
            continue;
        }

        $FormattedLetter = $partition.DriveLetter.Replace(':', '').ToLower();

        foreach ($entry in $Include) {
            $ProcessPartition = $FALSE;
            if ($entry.Replace(':', '').Replace('\', '').Replace('/', '').ToLower() -eq $FormattedLetter) {
                $ProcessPartition = $TRUE;
                break;
            }
        }
        foreach ($entry in $Exclude) {
            if ($entry.Replace(':', '').Replace('\', '').Replace('/', '').ToLower() -eq $FormattedLetter) {
                $ProcessPartition = $FALSE;
                break;
            }
        }

        if ($ProcessPartition -eq $FALSE) {
            continue;
        }

        $IcingaCheck = $null;

        if ($CheckUsedSpace) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Partition {0}', $partition.DriveLetter)) -Value $partition.UsedSpace -Unit 'B' -Minimum 0 -Maximum $partition.Size -LabelName ([string]::Format('used_space_partition_{0}', $FormattedLetter)) -NoPerfData:$SetUnknown -BaseValue $partition.Size;
        } else {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Partition {0}', $partition.DriveLetter)) -Value $partition.FreeSpace -Unit 'B' -Minimum 0 -Maximum $partition.Size -LabelName ([string]::Format('free_space_partition_{0}', $FormattedLetter)) -NoPerfData:$SetUnknown -BaseValue $partition.Size;
        }

        if ([string]::IsNullOrEmpty($partition.Size)) {
            if ($SkipUnknown -eq $FALSE) {
                $IcingaCheck.SetUnknown('No disk size available', $TRUE) | Out-Null;
            } else {
                $IcingaCheck.SetOk('No disk size available', $TRUE) | Out-Null;
            }
        } else {
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        }

        $DiskPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}

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

    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition C'=8,06204986572266%;60;;0;100 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Exclude "C:"
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
    PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Include "C:"
    [OK]: Check package "Used Partition Space" is [OK]
    | 'Partition C'=8,06204986572266%;60;;0;100
.PARAMETER Warning
    Used to specify a Warning threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Critical
    Used to specify a Critical threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Exclude
    Used to specify an array of partitions to be excluded.
    e.g. 'C:','D:'
.PARAMETER Include
    Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.
    e.g. 'C:','D:'
.PARAMETER IgnoreEmptyChecks
    Overrides the default behaviour of the plugin in case no check element is left for being checked (if all elements are filtered out for example).
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER SkipUnknown
    Allows to set Unknown partitions to Ok in case no metrics could be loaded.
.PARAMETER CheckUsedSpace
    Switches the behaviour of the plugin from checking with threshold for the free space (default) to the remaining (used) space instead
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
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
    param (
        $Warning                   = $null,
        $Critical                  = $null,
        [array]$Include            = @(),
        [array]$Exclude            = @(),
        [switch]$IgnoreEmptyChecks = $FALSE,
        [switch]$NoPerfData        = $FALSE,
        [switch]$SkipUnknown       = $FALSE,
        [switch]$CheckUsedSpace    = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    return (
        Invoke-IcingaCheckPartitionSpace `
            -Warning $Warning `
            -Critical $Critical `
            -Include $Include `
            -Exclude $Exclude `
            -IgnoreEmptyChecks:$IgnoreEmptyChecks `
            -NoPerfData:$NoPerfData `
            -SkipUnknown:$SkipUnknown `
            -CheckUsedSpace:$CheckUsedSpace `
            -Verbosity $Verbosity
    );
}
