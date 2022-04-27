function Global:Get-IcingaUsers()
{
    param (
        [array]$Username
    );

    $UserData          = Get-LocalUser;
    [array]$UserOutput = @();

    foreach ($user in $UserData) {
        if ($Username.Count -ne 0) {
            if (-Not ($Username -Contains $user.Name)) {
                continue;
            }
        }

        $UserOutput += @{
            'AccountExpires'         = $user.AccountExpires;
            'Description'            = $user.Description;
            'Enabled'                = $user.Enabled;
            'FullName'               = $user.FullName;
            'PasswordChangeableDate' = $user.PasswordChangeableDate;
            'PasswordExpires'        = $user.PasswordExpires;
            'UserMayChangePassword'  = $user.UserMayChangePassword;
            'PasswordRequired'       = $user.PasswordRequired;
            'PasswordLastSet'        = $user.PasswordLastSet;
            'LastLogon'              = $user.LastLogon;
            'Name'                   = $user.Name;
            'SID'                    = @{
                'BinaryLength'     = $user.SID.BinaryLength;
                'AccountDomainSid' = @{
                    'BinaryLength' = $user.SID.AccountDomainSid.BinaryLength;
                    'Value'        = $user.SID.AccountDomainSid.Value;
                };
                'Value'            = $user.SID.Value;
            };
            'PrincipalSource'        = $user.PrincipalSource;
            'ObjectClass'            = $user.ObjectClass;
        }
    }

    return $UserOutput;
}
