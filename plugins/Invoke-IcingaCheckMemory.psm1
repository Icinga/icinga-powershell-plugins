<#
.SYNOPSIS
    Checks on memory usage
.DESCRIPTION
    Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g memory is currently at 60% usage, WARNING is set to 50%, CRITICAL is set to 90%. In this case the check will return WARNING.

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
    PS> Invoke-IcingaCheckMemory -Verbosity 3 -Warning '60%' -Critical '80%'
    [OK] Memory Usage (All must be [OK])
    \_ [OK] PageFile Usage (All must be [OK])
        \_ [OK] C:\pagefile.sys: 278MB
    \_ [OK] Used Memory: 36.13% (23.10GiB)
    | 'used_memory'=24800540000B;41181786000;54909048000;0;68636310000 'pagefile_cpagefilesys'=278000000B;;;0;17408000000
.EXAMPLE
    PS> Invoke-IcingaCheckMemory -Verbosity 3 -Warning '50GB' -Critical '60GB'
    [OK] Memory Usage (All must be [OK])
    \_ [OK] PageFile Usage (All must be [OK])
        \_ [OK] C:\pagefile.sys: 278MB
    \_ [OK] Used Memory: 22.92GiB
    | 'used_memory'=24605630000B;50000000000;60000000000;0;68636310000 'pagefile_cpagefilesys'=278000000B;;;0;17408000000
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
