<#
.SYNOPSIS
    Checks on memory usage
.DESCRIPTION
    Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g memory is currently at 60% usage, WARNING is set to 50, CRITICAL is set to 90. In this case the check will return WARNING.

    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check on memory usage.
    Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### Performance Counter

    * \Memory\% committed bytes in use
    * \Memory\Available Bytes
    * \Paging File(_Total)\% usage

    ### Required User Groups

    * Performance Monitor Users
.EXAMPLE
    PS>Invoke-IcingaCheckMemory -Verbosity 3 -Warning 60 -Critical 80
    [WARNING]: % Memory Check 78.74 is greater than 60
.EXAMPLE
    PS> Invoke-IcingaCheckMemory -WarningPercent 30 -CriticalPercent 50
    [WARNING] Check package "Memory Usage" - [WARNING] Memory Percent Used
    \_ [WARNING] Memory Percent Used: Value "48.07%" is greater than threshold "30%"
    | 'memory_percent_used'=48.07%;0:30;0:50;0;100 'used_bytes'=3.85GB;;;0;8
    1
.PARAMETER Warning
    Used to specify a Warning threshold. In this case an string value.
    The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"
    This is using the default Icinga threshold handling.
    It is possible to enter e.g. 10% as threshold value if you want a percentage comparison.
.PARAMETER Critical
    Used to specify a Critical threshold. In this case an string value.
    The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"
    This is using the default Icinga threshold handling.
    It is possible to enter e.g. 10% as threshold value if you want a percentage comparison.
.PARAMETER PageFileWarning
    Allows to check the used page file and compare it against a size value, like "200MB"
    This is using the default Icinga threshold handling.
     It is possible to enter e.g. 10% as threshold value if you want a percentage comparison.
.PARAMETER PageFileCritical
    Allows to check the used page file and compare it against a size value, like "200MB"
    This is using the default Icinga threshold handling.
    It is possible to enter e.g. 10% as threshold value if you want a percentage comparison.
.PARAMETER IncludePageFile
    Allows to filter for page files being included for the check
.PARAMETER ExcludePageFile
    Allows to filter for page files being excluded for the check
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckMemory()
{
    param(
        $Warning                = $null,
        $Critical               = $null,
        $PageFileWarning        = $null,
        $PageFileCritical       = $null,
        [array]$IncludePageFile = @(),
        [array]$ExcludePageFile = @(),
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity         = 0,
        [switch]$NoPerfData
    );

    $MemoryPackage   = New-IcingaCheckPackage -Name 'Memory Usage' -OperatorAnd -Verbose $Verbosity;
    $PageFilePackage = New-IcingaCheckPackage -Name 'PageFile Usage' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;
    $MemoryData      = Get-IcingaMemoryPerformanceCounter;

    $MemoryPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name 'Used Memory' `
                -Value $MemoryData['Memory Used Bytes'] `
                -BaseValue $MemoryData['Memory Total Bytes'] `
                -Minimum 0 `
                -Maximum $MemoryData['Memory Total Bytes'] `
                -Unit 'B'
        ).WarnOutOfRange(
            $Warning
        ).CritOutOfRange(
            $Critical
        )
    );

    foreach ($PageFile in $MemoryData.PageFile.Keys) {
        $PageFile        = $MemoryData.PageFile[$PageFile];
        $AddPageFile = $FALSE;

        if ($IncludePageFile.Count -ne 0) {
            foreach ($entry in $IncludePageFile) {
                if ($PageFile.Name -Like $entry) {
                    $AddPageFile = $TRUE;
                    break;
                }
            }
        } else {
            $AddPageFile = $TRUE;
        }

        foreach ($entry in $ExcludePageFile) {
            if ($PageFile.Name -Like $entry) {
                $AddPageFile = $FALSE;
                break;
            }
        }

        if ($AddPageFile -eq $FALSE) {
            continue;
        }

        $PageFilePackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name $PageFile.Name `
                    -Value $PageFile.Usage `
                    -BaseValue $PageFile.TotalSize `
                    -Minimum 0 `
                    -Maximum $PageFile.TotalSize `
                    -Unit 'MB' `
                    -LabelName ([string]::Format('pagefile_{0}', (Format-IcingaPerfDataLabel $PageFile.Name)))
            ).WarnOutOfRange(
                $PageFileWarning
            ).CritOutOfRange(
                $PageFileCritical
            )
        );
    }

    $MemoryPackage.AddCheck($PageFilePackage);

    return (New-IcingaCheckResult -Check $MemoryPackage -NoPerfData $NoPerfData -Compile);
}
