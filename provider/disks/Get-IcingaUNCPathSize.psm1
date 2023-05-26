function Get-IcingaUNCPathSize()
{
    param (
        [string]$Path           = '',
        [string]$User           = '',
        [SecureString]$Password = $null
    );

    [string]$Username = '';
    [string]$Domain   = '';

    if ($User.Contains('@')) {
        $UserData = $User.Split('@');
        $Username = $UserData[0];
        $Domain   = $UserData[1];
    } elseif ($User.Contains('\') -eq $FALSE) {
        $Username = $User;
    } else {
        $UserData = $User.Split('\');
        $Username = $UserData[1];
        $Domain   = $UserData[0];
    }

    # Lets ensure our path does actually exist
    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Configuration' `
            -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing `
            -CustomMessage 'Plugin argument "-Path" is either empty or does not exist' `
            -Force;
    }

    # Register our kernel32.dll Windows API function call
    Add-IcingaAddTypeLib -TypeName 'IcingaUNCPath' -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        using System.Security.Principal;

        public static class IcingaUNCPath {
            [DllImport("kernel32.dll", PreserveSig = true, CharSet = CharSet.Auto)]
            public static extern int GetDiskFreeSpaceEx(
                IntPtr lpDirectoryName,           // UNC Path for share
                out long lpFreeBytesAvailable,    // Free Bytes available on path
                out long lpTotalNumberOfBytes,    // Bytes available on target disk / path
                out long lpTotalNumberOfFreeBytes // Total available space on target disk / path
            );

            [DllImport("advapi32.dll", SetLastError = true)]
            public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

            public static void GetIcingaDiskFreeSpace(IntPtr authToken, IntPtr lpDirectoryName, out long lpFreeBytesAvailable, out long lpTotalNumberOfBytes, out long lpTotalNumberOfFreeBytes) {
                // Run without authentication
                if (authToken == IntPtr.Zero) {
                    GetDiskFreeSpaceEx(lpDirectoryName, out lpFreeBytesAvailable, out lpTotalNumberOfBytes, out lpTotalNumberOfFreeBytes);
                } else {
                    // Run with authentication
                    using (WindowsImpersonationContext impersonatedUser = WindowsIdentity.Impersonate(authToken))
                    {
                        GetDiskFreeSpaceEx(lpDirectoryName, out lpFreeBytesAvailable, out lpTotalNumberOfBytes, out lpTotalNumberOfFreeBytes);
                    }
                }
            }
        }
"@

    # Setup variables as object which we can use to reference data into
    $ShareFree                = New-Object -TypeName long;
    $ShareSize                = New-Object -TypeName long;
    $TotalFree                = New-Object -TypeName long;
    [System.IntPtr]$authToken = New-Object IntPtr;

    if ([string]::IsNullOrEmpty($Username) -eq $FALSE -And $null -ne $Password) {
        # LOGON32_LOGON_INTERACTIVE = 2
        # LOGON32_PROVIDER_DEFAULT  = 0
        $Result = [IcingaUNCPath]::LogonUser($Username, $Domain, (ConvertFrom-IcingaSecureString -SecureString $Password), 2, 0, [ref]$authToken);

        if ($Result -eq $FALSE) {
            Exit-IcingaThrowException -Force -CustomMessage 'Authentication for UNC-Check failed' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.WindowsAuthentication;
        }
    }

    # Create a pointer object to our share
    [System.IntPtr]$ptrPath = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($Path);

    # Call our function we registered within the Add-IcingaAddTypeLib definition
    [IcingaUNCPath]::GetIcingaDiskFreeSpace($authToken, $ptrPath, [ref]$ShareFree, [ref]$ShareSize, [ref]$TotalFree) | Out-Null;
    $ShareFreePercent = 0;

    if ($ShareSize -ne 0) {
        $ShareFreePercent = ([math]::round(($ShareFree / $ShareSize * 100), 2));
    }

    return @{
        'ShareFree'        = $ShareFree;
        'ShareSize'        = $ShareSize;
        'ShareUsed'        = ($ShareSize - $ShareFree);
        'ShareFreePercent' = $ShareFreePercent;
        'TotalFree'        = $TotalFree;
    };
}
