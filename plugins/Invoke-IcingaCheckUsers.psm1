<#
.SYNOPSIS
   Checks how many users are logged on to the host
.DESCRIPTION
   Invoke-IcingaCheckUsers returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g There are 13 users logged on, WARNING is set to 8, CRITICAL is set to 15. In this case the check will return WARNING.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to check how many users are loged onto a host. 
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.ROLE
    ### WMI Permissions

    * Root\Cimv2
.EXAMPLE
   PS> Invoke-IcingaCheckUsers -Warning 8 -Critical 15
   [WARNING] Check package "Users" - [WARNING] Logged On Users
   \_ [WARNING] Logged On Users: Value "13" is greater than threshold "8"
   | 'logged_on_users'=13;8;15 'logged_on_users_test'=5;; 'logged_on_users_umfd0'=1;; 'logged_on_users_dwm1'=2;; 'logged_on_users_system'=1;; 'logged_on_users_dwm2'=2;; 'logged_on_users_umfd1'=1;; 'logged_on_users_umfd2'=1;;
.EXAMPLE
   PS>  Invoke-IcingaCheckUsers -Username 'astoll' -Warning 8 -Critical 15
   [OK] Check package "Users"
   | 'logged_on_users_test'=5;8;15
   0
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Username
   Used to specify an array of usernames to match against.
   
   e.g 'Administrator', 'Icinga'
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckUsers()
{
    param (
        [array]$Username,
        $Warning             = $null,
        $Critical            = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity      = 0
   );

   $UsersPackage  = New-IcingaCheckPackage -Name 'Users' -OperatorAnd -Verbose $Verbosity;
   $LoggedOnUsers = Get-IcingaLoggedOnUsers -UserFilter $Username;

   if ($Username.Count -ne 0) {
      foreach ($User in $Username) {
         $IcingaCheck = $null;
         [int]$LoginCount = 0;

         if ($LoggedOnUsers.users.ContainsKey($User)) {
            $LoginCount = $LoggedOnUsers.users.$User.count;
         }

         $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Logged On Users "{0}"', $User)) -Value $LoginCount;
         $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
         $UsersPackage.AddCheck($IcingaCheck);
      }
   } else {
      foreach ($User in $LoggedOnUsers.users.Keys) {
         $UsersPackage.AddCheck(
            (New-IcingaCheck -Name ([string]::Format('Logged On Users "{0}"', $User)) -Value $LoggedOnUsers.users.$User.count)
         );
      }
      $IcingaCheck = New-IcingaCheck -Name 'Logged On Users' -Value $LoggedOnUsers.count;
      $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
      $UsersPackage.AddCheck($IcingaCheck)
   }
   
   return (New-IcingaCheckResult -Name 'Users' -Check $UsersPackage -NoPerfData $NoPerfData -Compile);
}
