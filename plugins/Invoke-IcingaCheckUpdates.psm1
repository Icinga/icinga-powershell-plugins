<#
.SYNOPSIS
    Checks how many updates are to be applied
.DESCRIPTION
    Invoke-IcingaCheckUpdates returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
    e.g 'C:\Users\Icinga\Backup' 10 updates are pending, WARNING is set to 20, CRITICAL is set to 50. In this case the check will return OK.
    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check how many updates are to be applied and thereby currently pending
    Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### COM-Objects

    * Microsoft.Update.Session
.EXAMPLE
    PS> Invoke-IcingaCheckUpdates -Verbosity 1 -WarningDefender 0;

    [WARNING] Windows Updates: 1 Warning 4 Ok [WARNING] Microsoft Defender
    \_ [WARNING] Microsoft Defender
        \_ [OK] Security Intelligence-Update für Microsoft Defender Antivirus - KB2267602 (Version 1.355.2366.0) [23.01.2022 00:00:00]: 0
        \_ [WARNING] Update Count: 1c is greater than threshold 0c
    \_ [OK] Total Pending Updates: 1c
    | 'total_pending_updates'=1c;; 'security_update_count'=0c;; 'rollups_update_count'=0c;; 'other_update_count'=0c;; 'defender_update_count'=1c;0;
.EXAMPLE
    PS> Invoke-IcingaCheckUpdates -Verbosity 1 -Warning 0 -UpdateFilter '*Intelligence-Update*';

    [WARNING] Windows Updates: 1 Warning 4 Ok [WARNING] Total Pending Updates (1c)
    \_ [WARNING] Total Pending Updates: 1c is greater than threshold 0c
    | 'total_pending_updates'=1c;0; 'security_update_count'=0c;; 'rollups_update_count'=0c;; 'other_update_count'=0c;; 'defender_update_count'=1c;;
.PARAMETER UpdateFilter
    Allows to filter for names of updates being included in the total update count, allowing a specific monitoring and filtering of certain updates
    beyond the provided categories
.PARAMETER Warning
    The warning threshold for the total pending update count on the Windows machine
.PARAMETER Critical
    The critical threshold for the total pending update count on the Windows machine
.PARAMETER WarningSecurity
    The warning threshold for the security update count on the Windows machine
.PARAMETER CriticalSecurity
    The critical threshold for the security update count on the Windows machine
.PARAMETER WarningRollups
    The warning threshold for the rollup update count on the Windows machine
.PARAMETER CriticalRollups
    The critical threshold for the rollup update count on the Windows machine
.PARAMETER WarningDefender
    The warning threshold for the Microsoft Defender update count on the Windows machine
.PARAMETER CriticalDefender
    The critical threshold for the Microsoft Defender update count on the Windows machine
.PARAMETER WarningOther
    The warning threshold for all other updates on the Windows machine
.PARAMETER CriticalOther
    The critical threshold for all other updates on the Windows machine
.PARAMETER WarnOnReboot
    Checks if there is a pending reboot on the system to finalize Windows Updates and returns
    warning if one is pending
.PARAMETER CritOnReboot
    Checks if there is a pending reboot on the system to finalize Windows Updates and returns
    critical if one is pending
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
     https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckUpdates()
{
    param (
        [array]$UpdateFilter  = @(),
        $Warning              = $null,
        $Critical             = $null,
        $WarningSecurity      = $null,
        $CriticalSecurity     = $null,
        $WarningRollups       = $null,
        $CriticalRollups      = $null,
        $WarningDefender      = $null,
        $CriticalDefender     = $null,
        $WarningOther         = $null,
        $CriticalOther        = $null,
        [switch]$WarnOnReboot = $FALSE,
        [switch]$CritOnReboot = $FALSE,
        [switch]$NoPerfData   = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity       = 0
    );

    $PendingUpdates      = Get-IcingaWindowsUpdatesPending -UpdateFilter $UpdateFilter;
    $WindowsUpdates      = New-IcingaCheckPackage -Name 'Windows Updates' -OperatorAnd -AddSummaryHeader -Verbose $Verbosity;
    $TotalPendingUpdates = New-IcingaCheck -Name 'Total Pending Updates' -Value $PendingUpdates.count -Unit 'c' -MetricIndex 'summary' -MetricName 'count';
    $RebootPending       = New-IcingaCheck -Name 'Reboot Pending' -Value ([int]$PendingUpdates.RebootPending) -Translation @{ 0 = 'No'; 1 = 'Yes' } -MetricIndex 'reboot' -MetricName 'required';

    if ($WarnOnReboot) {
        $RebootPending.WarnIfMatch([int][bool]$WarnOnReboot) | Out-Null;
    }
    if ($CritOnReboot) {
        $RebootPending.CritIfMatch([int][bool]$CritOnReboot) | Out-Null;
    }

    $TotalPendingUpdates.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
    $WindowsUpdates.AddCheck($TotalPendingUpdates);
    $WindowsUpdates.AddCheck($RebootPending);

    $SecurityUpdates = New-IcingaCheckPackage -Name 'Security Updates' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;
    $RollupUpdates   = New-IcingaCheckPackage -Name 'Update Rollups' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;
    $DefenderUpdates = New-IcingaCheckPackage -Name 'Microsoft Defender' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;
    $OtherUpdates    = New-IcingaCheckPackage -Name 'Other' -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;

    foreach ($category in $PendingUpdates.updates.Keys) {
        $UpdateCategories = $PendingUpdates.updates[$category];
        $CategoryPackage  = $OtherUpdates;
        $CategoryWarning  = $WarningOther;
        $CategoryCritical = $CriticalOther;
        $PerfDataLabel    = [string]::Format('{0}_update_count', $category);

        switch ($category) {
            'security' {
                $CategoryWarning  = $WarningSecurity;
                $CategoryCritical = $CriticalSecurity;
                $CategoryPackage  = $SecurityUpdates;
                break;
            };
            'rollups' {
                $CategoryWarning  = $WarningRollups;
                $CategoryCritical = $CriticalRollups;
                $CategoryPackage  = $RollupUpdates;
                break;
            };
            'defender' {
                $CategoryWarning  = $WarningDefender;
                $CategoryCritical = $CriticalDefender;
                $CategoryPackage  = $DefenderUpdates;
                break;
            };
        }

        foreach ($pendingUpdate in $UpdateCategories.Keys) {
            $UpdateName = New-IcingaCheck -Name $pendingUpdate -NoPerfData;
            $CategoryPackage.AddCheck($UpdateName);
        }

        $UpdateCount = New-IcingaCheck -Name 'Update Count' -Value $UpdateCategories.Count -Unit 'c' -LabelName $PerfDataLabel -MetricIndex $category -MetricName 'count';
        $UpdateCount.WarnOutOfRange($CategoryWarning).CritOutOfRange($CategoryCritical) | Out-Null;
        $CategoryPackage.AddCheck($UpdateCount);
    }

    $WindowsUpdates.AddCheck($SecurityUpdates);
    $WindowsUpdates.AddCheck($RollupUpdates);
    $WindowsUpdates.AddCheck($DefenderUpdates);
    $WindowsUpdates.AddCheck($OtherUpdates);

    if ($PendingUpdates.ContainsKey('error')) {
        $UpdateError = New-IcingaCheck -Name 'Windows Update Error';
        $UpdateError.SetUnknown($PendingUpdates.error, $TRUE) | Out-Null;
        $WindowsUpdates.AddCheck($UpdateError);
    }

    return (New-IcingaCheckResult -Check $WindowsUpdates -NoPerfData $NoPerfData -Compile);
}
