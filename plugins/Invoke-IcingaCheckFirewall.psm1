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
.PARAMETER Profile
   Used to specify an array of profiles to check. Available profiles are 'Domain', 'Public', 'Private'

.PARAMETER Enabled
   Used to specify whether the firewall profiles should be enabled or disabled.

   -Enabled $TRUE
   translates to enabled, while
   not being specified
   translates to disabled.
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
      [array]$Profile,
      [switch]$Enabled    = $FALSE,
      [switch]$NoPerfData,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0
   );

   $FirewallPackage = New-IcingaCheckPackage -Name 'Firewall profiles' -OperatorAnd -Verbos $Verbosity;

   foreach ($singleprofile in $Profile) {
      $FirewallData = (Get-NetFirewallProfile -Name $singleprofile -ErrorAction SilentlyContinue);
      $FirewallCheck = New-IcingaCheck -Name "Firewall Profile $singleprofile" -Value $FirewallData.Enabled -ObjectExists $FirewallData -Translation @{ 'true' = 'Enabled'; 'false' = 'Disabled'};
      $FirewallCheck.CritIfNotMatch([string]$Enabled) | Out-Null;
      $FirewallPackage.AddCheck($FirewallCheck)
   }

   return (New-IcingaCheckResult -Check $FirewallPackage -NoPerfData $NoPerfData -Compile);
}
