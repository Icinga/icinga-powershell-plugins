function Get-IcingaUNCPathSize()
{
    param (
        [string]$Path
    );

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

        public static class IcingaUNCPath {
            [DllImport("kernel32.dll", PreserveSig = true, CharSet = CharSet.Auto)]

            public static extern int GetDiskFreeSpaceEx(
                IntPtr lpDirectoryName,           // UNC Path for share
                out long lpFreeBytesAvailable,    // Free Bytes available on path
                out long lpTotalNumberOfBytes,    // Bytes available on target disk / path
                out long lpTotalNumberOfFreeBytes // Total available space on target disk / path
            );
        }
"@

    # Setup variables as object which we can use to reference data into
    $ShareFree = New-Object -TypeName long;
    $ShareSize = New-Object -TypeName long;
    $TotalFree = New-Object -TypeName long;

    # Create a pointer object to our share
    [System.IntPtr]$ptrPath = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($Path);

    # Call our function we registered within the Add-IcingaAddTypeLib definition
    [IcingaUNCPath]::GetDiskFreeSpaceEx($ptrPath, [ref]$ShareFree, [ref]$ShareSize, [ref]$TotalFree) | Out-Null;
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
