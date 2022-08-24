<#
.SYNOPSIS
   Checks whether a firewall module is enabled or not
.DESCRIPTION
   Invoke-IcingaCheckFirewall returns either 'OK' or 'CRITICAL', whether the check matches or not.

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check the status of a firewall profile.
   Based on the match result the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckFirewall -Profile "Domain" -Verbosity 3
   [OK] Check package "Firewall profiles" (Match All)
   \_ [OK] Firewall Profile Domain is True
   | 'firewall_profile_domain'=True;;
.EXAMPLE
   PS> Invoke-IcingaCheckFirewall -Profile "Domain", "Private" -Verbosity 1}
   [OK] Check package "Firewall profiles" (Match All)
   | 'firewall_profile_domain'=True;; 'firewall_profile_private'=True;;
.PARAMETER FirewallProfile
   Used to specify an array of profiles to check. Available profiles are 'Domain', 'Public', 'Private'

.PARAMETER Enabled
   Used to specify whether the firewall profiles should be enabled or disabled.

   -Enabled $TRUE translates to enabled, while not being specified translates to disabled.
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

function Invoke-IcingaCheckFirewall()
{
    param(
        [Alias("Profile")][Array]$FirewallProfile,
        [switch]$Enabled    = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

    $FirewallPackage = New-IcingaCheckPackage -Name 'Firewall profiles' -OperatorAnd -Verbose $Verbosity;

    foreach ($singleprofile in $FirewallProfile) {
        $FirewallData = (Get-NetFirewallProfile -Name $singleprofile -ErrorAction SilentlyContinue);
        $FirewallCheck = New-IcingaCheck `
            -Name "Firewall Profile $singleprofile" `
            -Value $FirewallData.Enabled `
            -ObjectExists $FirewallData `
            -Translation @{ 'true' = 'Enabled'; 'false' = 'Disabled'} `
            -MetricIndex $singleprofile `
            -MetricName 'enabled';
        $FirewallCheck.CritIfNotMatch([string]$Enabled) | Out-Null;
        $FirewallPackage.AddCheck($FirewallCheck)
    }

    return (New-IcingaCheckResult -Check $FirewallPackage -NoPerfData $NoPerfData -Compile);
}
