<#
.SYNOPSIS
    Checks how much space on a partition is used.
.DESCRIPTION
    Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g 'C:' is at 8% usage, WARNING is set to 60%, CRITICAL is set to 80%. In this case the check will return OK.
    Beside that the preset for percentage or unit measurement is now free to design, regardless of % values or GiB/TiB
    and so on.

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
    PS> Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Verbosity 3;

    [CRITICAL] Free Partition Space: 2 Critical 2 Ok [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\, Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\ (All must be [OK])
    \_ [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: Value 287.20MiB (95.73%) is greater than threshold 240.00MiB (80%)
    \_ [CRITICAL] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: Value 266.22MiB (89.94%) is greater than threshold 236.80MiB (80%)
    \_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB (16.05%)
    \_ [OK] Partition C: 30.23GiB (11.88%)
    | volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;188741220;251654960;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;186227100;248302800;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;453611520;604815360;0;756019200 c::ifw_partitionspace::free=32461880000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS> Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Exclude '*`\\?*' -Verbosity 3;

    [OK] Free Partition Space: 1 Ok (All must be [OK])
    \_ [OK] Partition C: 30.23GiB (11.87%)
    | c::ifw_partitionspace::free=32456160000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS>Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Include 'C:' -Verbosity 3;

    [OK] Free Partition Space: 1 Ok (All must be [OK])
    \_ [OK] Partition C: 29.22GiB (11.48%)
    | c::ifw_partitionspace::free=31376350000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS> Invoke-IcingaCheckUsedPartitionSpace -Warning '1TB' -Critical '1.5TB' -Verbosity 3;

    [OK] Free Partition Space: 4 Ok (All must be [OK])
    \_ [OK] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: 287.20MiB
    \_ [OK] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: 266.22MiB
    \_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB
    \_ [OK] Partition C: 29.22GiB
    | volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;1000000000000;1000000000000;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;1000000000000;1000000000000;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;1000000000000;1000000000000;0;756019200 c::ifw_partitionspace::free=31376350000B;1000000000000;1000000000000;0;273355400000
.PARAMETER Warning
    Used to specify a Warning threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Critical
    Used to specify a Critical threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Exclude
    Used to specify an array of partitions to be excluded.
    e.g. 'C:','D:', 'D:\SysDB\'

    If you want to only exclude partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard exclude filter with
    '*`\\?*'
.PARAMETER Include
    Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.
    e.g. 'C:','D:', 'D:\SysDB\'

    If you want to only include partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard include filter with
    '*`\\?*'
.PARAMETER RequiredPartition
    Allows to define a list of partitions which should be included in the check.
    e.g. 'C:','D:', 'D:\SysDB\'

    In case they are missing, the plugin will report CRITICAL
.PARAMETER IgnoreEmptyChecks
    Overrides the default behavior of the plugin in case no check element is left for being checked (if all elements are filtered out for example).
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER SkipUnknown
    Allows to set Unknown partitions to Ok in case no metrics could be loaded.
.PARAMETER CheckUsedSpace
    Switches the behavior of the plugin from checking with threshold for the free space (default) to the remaining (used) space instead
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
        [array]$RequiredPartition  = @(),
        [switch]$IgnoreEmptyChecks = $FALSE,
        [switch]$NoPerfData        = $FALSE,
        [switch]$SkipUnknown       = $FALSE,
        [switch]$CheckUsedSpace    = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity            = 0
    );

    $Disks                  = Get-IcingaPartitionSpace;
    $DiskPackage            = $null;
    [array]$KnownPartitions = @();

    if ($CheckUsedSpace) {
        $DiskPackage = New-IcingaCheckPackage -Name 'Used Partition Space' -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks -OperatorAnd -AddSummaryHeader;
    } else {
        $DiskPackage = New-IcingaCheckPackage -Name 'Free Partition Space' -Verbose $Verbosity -IgnoreEmptyPackage:$IgnoreEmptyChecks -OperatorAnd -AddSummaryHeader;
    }

    foreach ($partition in $Disks.Keys) {
        $partition          = $Disks[$partition];
        $ProcessPartition   = $TRUE;
        $PartitionMandatory = $FALSE;
        $PartitionName      = $partition.DriveLetter;

        $FormattedLetter = '';
        if ([string]::IsNullOrEmpty($partition.DriveLetter) -eq $FALSE) {
            $FormattedLetter  = $partition.DriveLetter.Replace(':', '').ToLower();
            $KnownPartitions += $FormattedLetter;
        } else {
            $PartitionName    = $partition.DriveName;
            $KnownPartitions += $PartitionName.ToLower();
        }

        foreach ($entry in $Include) {
            $ProcessPartition = $FALSE;

            if (($partition.HasLetter -and (Test-IcingaArrayFilter -InputObject $FormattedLetter -Include $entry.Replace(':', '').Replace('\', '').Replace('/', '').ToLower())) -or (-not $partition.HasLetter -and (Test-IcingaArrayFilter -InputObject $partition.DriveName.ToLower() -Include $entry.ToLower()))) {
                $ProcessPartition = $TRUE;
                break;
            }
        }
        foreach ($entry in $Exclude) {
            if (($partition.HasLetter -and (Test-IcingaArrayFilter -InputObject $FormattedLetter -Exclude $entry.Replace(':', '').Replace('\', '').Replace('/', '').ToLower()) -eq $FALSE) -or (-not $partition.HasLetter -and (Test-IcingaArrayFilter -InputObject $partition.DriveName.ToLower() -Exclude $entry.ToLower()) -eq $FALSE)) {
                $ProcessPartition = $FALSE;
                break;
            }
        }

        if ($ProcessPartition -eq $FALSE) {
            continue;
        }

        $IcingaCheck = $null;

        if ($CheckUsedSpace) {
            $IcingaCheck = New-IcingaCheck -MetricIndex $PartitionName -MetricName 'used' -Name ([string]::Format('Partition {0}', $PartitionName)) -Value $partition.UsedSpace -Unit 'B' -Minimum 0 -Maximum $partition.Size -LabelName ([string]::Format('used_space_partition_{0}', $FormattedLetter)) -NoPerfData:$SetUnknown -BaseValue $partition.Size;
        } else {
            $IcingaCheck = New-IcingaCheck -MetricIndex $PartitionName -MetricName 'free' -Name ([string]::Format('Partition {0}', $PartitionName)) -Value $partition.FreeSpace -Unit 'B' -Minimum 0 -Maximum $partition.Size -LabelName ([string]::Format('free_space_partition_{0}', $FormattedLetter)) -NoPerfData:$SetUnknown -BaseValue $partition.Size;
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

    foreach ($mandatoryPartition in $RequiredPartition) {
        $reqPartitionLetter = $mandatoryPartition.Replace(':', '').Replace('\', '').Replace('/', '').ToLower();

        if ($KnownPartitions.Contains($reqPartitionLetter) -eq $FALSE -and $KnownPartitions.Contains($mandatoryPartition.ToLower()) -eq $FALSE) {
            $IcingaCheck = (New-IcingaCheck -Name ([string]::Format('Partition {0}', $mandatoryPartition)) -Value 'Mandatory partition not found on host' -NoPerfData).SetCritical();
            $DiskPackage.AddCheck($IcingaCheck);
        }
    }

    return (New-IcingaCheckResult -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}

<#
.SYNOPSIS
    Checks how much space on a partition is used.
.DESCRIPTION
    Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g 'C:' is at 8% usage, WARNING is set to 60%, CRITICAL is set to 80%. In this case the check will return OK.
    Beside that the preset for percentage or unit measurement is now free to design, regardless of % values or GiB/TiB
    and so on.

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
    PS> Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Verbosity 3;

    [CRITICAL] Free Partition Space: 2 Critical 2 Ok [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\, Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\ (All must be [OK])
    \_ [CRITICAL] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: Value 287.20MiB (95.73%) is greater than threshold 240.00MiB (80%)
    \_ [CRITICAL] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: Value 266.22MiB (89.94%) is greater than threshold 236.80MiB (80%)
    \_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB (16.05%)
    \_ [OK] Partition C: 30.23GiB (11.88%)
    | volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;188741220;251654960;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;186227100;248302800;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;453611520;604815360;0;756019200 c::ifw_partitionspace::free=32461880000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS> Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Exclude '*`\\?*' -Verbosity 3;

    [OK] Free Partition Space: 1 Ok (All must be [OK])
    \_ [OK] Partition C: 30.23GiB (11.87%)
    | c::ifw_partitionspace::free=32456160000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS>Invoke-IcingaCheckPartitionSpace -Warning 60% -Critical 80% -Include 'C:' -Verbosity 3;

    [OK] Free Partition Space: 1 Ok (All must be [OK])
    \_ [OK] Partition C: 29.22GiB (11.48%)
    | c::ifw_partitionspace::free=31376350000B;164013240000;218684320000;0;273355400000
.EXAMPLE
    PS> Invoke-IcingaCheckUsedPartitionSpace -Warning '1TB' -Critical '1.5TB' -Verbosity 3;

    [OK] Free Partition Space: 4 Ok (All must be [OK])
    \_ [OK] Partition \\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\: 287.20MiB
    \_ [OK] Partition \\?\Volume{8acb585d-fd6a-4a7d-a0a1-33d6544b01b0}\: 266.22MiB
    \_ [OK] Partition \\?\Volume{ffad7660-2b91-4988-b8f6-dcb98d8992c1}\: 115.72MiB
    \_ [OK] Partition C: 29.22GiB
    | volume151b43fc3f7041b092ebdff7c419ccc0::ifw_partitionspace::free=301146100B;1000000000000;1000000000000;0;314568700 volume8acb585dfd6a4a7da0a133d6544b01b0::ifw_partitionspace::free=279154700B;1000000000000;1000000000000;0;310378500 volumeffad76602b914988b8f6dcb98d8992c1::ifw_partitionspace::free=121339900B;1000000000000;1000000000000;0;756019200 c::ifw_partitionspace::free=31376350000B;1000000000000;1000000000000;0;273355400000
.PARAMETER Warning
    Used to specify a Warning threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Critical
    Used to specify a Critical threshold. This can either be a byte-value type like '10GB'
    or a %-value, like '10%'
.PARAMETER Exclude
    Used to specify an array of partitions to be excluded.
    e.g. 'C:','D:', 'D:\SysDB\'

    If you want to only exclude partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard exclude filter with
    '*`\\?*'
.PARAMETER Include
    Used to specify an array of partitions to be included. If not set, the check expects that all not excluded partitions should be checked.
    e.g. 'C:','D:', 'D:\SysDB\'

    If you want to only include partitions from the system volume, like `\\?\Volume{151b43fc-3f70-41b0-92eb-dff7c419ccc0}\` you can define a wildcard include filter with
    '*`\\?*'
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
