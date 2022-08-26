<#
.SYNOPSIS
    Checks hash against file hash of a file
.DESCRIPTION
    Invoke-IcingaCheckCheckSum returns either 'OK' or 'CRITICAL', whether the check matches or not.

    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    This module is intended to be used to check a hash against a file hash of a file, to determine whether changes have occurred.
    Based on the match result the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
    PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt"
    [OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B
.EXAMPLE
    PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B
    [OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B|
.EXAMPLE
    PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D
    [CRITICAL] CheckSum C:\Users\Icinga\Downloads\test.txt 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B is not matching 008FB84A017F5DFDAF038DB2FDD6934E6E5D
.PARAMETER WarningBytes
    Used to specify a string to the path of a file, which will be checked.

    The string has to be like "C:\Users\Icinga\test.txt"

.PARAMETER Algorithm
    Used to specify a string, which contains the algorithm to be used.

    Allowed algorithms: 'SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5'
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

function Invoke-IcingaCheckCheckSum()
{
    param (
        [string]$Path       = $null,
        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        [string]$Algorithm  = 'SHA256',
        [string]$Hash       = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-Path"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ((Test-Path $Path) -eq $FALSE -Or (Get-Item $Path) -Is [System.IO.DirectoryInfo]) {
        Exit-IcingaThrowException -Force -CustomMessage '"-Path" is not directing to a file' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentConflict;
    }

    [string]$FileHash = (Get-IcingaFileHash $Path -Algorithm $Algorithm).Hash
    $CheckSumCheck    = New-IcingaCheck -Name "CheckSum $Path" -Value $FileHash -NoPerfData;

    If (([string]::IsNullOrEmpty($Hash)) -eq $FALSE) {
        $CheckSumCheck.CritIfNotMatch($Hash) | Out-Null;
    }

    return (New-IcingaCheckResult -Check $CheckSumCheck -NoPerfData $NoPerfData -Compile);
}
