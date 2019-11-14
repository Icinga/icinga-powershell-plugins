<#
.SYNOPSIS
   Checks whether the network location awareness(NLA) found the rigth firewall profile for a given network adapter
.DESCRIPTION
   Invoke-IcingaCheckNLA returns either 'OK' or 'CRITICAL', whether the check matches or not.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check the status of the firewall profile for a given network adapter.
   Based on the match result the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckNLA -Profile "DomainAuthenticated" -Verbosity 3
   [CRITICAL] Check package "NLA" (Match All) - [CRITICAL] NLA for vEthernet (DockerNAT)
   \_ [OK] NLA for Ethernet 4: DomainAuthenticated
   \_ [CRITICAL] NLA for vEthernet (DockerNAT): Value "Public" is not matching threshold "DomainAuthenticated"
   | 'nla_for_ethernet_4'=DomainAuthenticated;; 'nla_for_vethernet_dockernat'=Public;;DomainAuthenticated
.EXAMPLE
   PS> Invoke-IcingaCheckNLA -Profile "DomainAuthenticated" -NICs "Ethernet 1" -Verbosity 1}
   [OK] Check package "NLA" (Match All)
   | 'nla_for_ethernet_4'=DomainAuthenticated;;
.PARAMETER Profile
   Used to specify the profile to check. Available profiles are 'DomainAuthenticated', 'Public', 'Private'
.PARAMETER NICs
   Used to specify the NICs where to check the filewall profile. When not presented every nic with is active will be checked
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckNLA()
{
   param(
      [string]$Profile,
      [switch]$NoPerfData,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0,
      [array]$NICs
   );

   $NLAPackage = New-IcingaCheckPackage -Name 'NLA' -OperatorAnd -Verbos $Verbosity;
   
   if($NICs.Count -eq 0) 
   {
      foreach ($NLAData in Get-NetConnectionProfile) {
          $NLAName = $NLAData.InterfaceAlias;
          $NLACheck = New-IcingaCheck -Name "NLA for $NLAName" $NLAData.NetworkCategory -ObjectExists $NLAData;
          $NLACheck.CritIfNotMatch([string]$Profile) | Out-Null;
          $NLAPackage.AddCheck($NLACheck);
      }
   } 
   else 
   {
      foreach ($NIC in $NICs) {
          $NLAData = (Get-NetConnectionProfile -InterfaceAlias $NIC);
          $NLACheck = New-IcingaCheck -Name "NLA for $NIC" -Value $NLAData.NetworkCategory -ObjectExists $NLAData;
          $NLACheck.CritIfNotMatch([string]$Profile) | Out-Null;
          $NLAPackage.AddCheck($NLACheck);
      }
   }

   return (New-IcingaCheckResult -Check $NLAPackage -NoPerfData $NoPerfData -Compile);
}
