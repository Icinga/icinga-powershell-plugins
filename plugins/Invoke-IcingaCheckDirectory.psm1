<#
.SYNOPSIS
   Checks for amount of files within a directory depending on the set filters
.DESCRIPTION
   Invoke-IcingaCheckDirectory will check within a specific directory for files matching the set filter criteria.
   It allows to filter for files with a specific size, modification date, name or file ending.
   By using the Warning or Critical threshold you can then set on when the check will be set to 'WARNING' or 'CRITICAL'.

   Based on the provided filters, the plugin will return the amount of files found matching those filters.
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check how many files and directories are within are specified path.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 19
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
   [WARNING]: Check package "C:\Users\Icinga\Downloads" is [WARNING] (Match All)
    \_ [WARNING]: C:\Users\Icinga\Downloads is 24
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThan 20d
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 1
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeOlderThan 100d
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 19
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -FileNames "*.txt","*.sql" -Warning 20 -Critical 30 -Verbosity 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 4
.PARAMETER Warning
   Used to specify a Warning threshold. Follows the Icinga plugin threshold
.PARAMETER Critical
   Used to specify a Critical threshold. Follows the Icinga plugin threshold
.PARAMETER Path
   Used to specify a path.
   e.g. 'C:\Users\Icinga\Downloads'
.PARAMETER FileNames
   Used to specify an array of filenames or expressions to match against results to filter for specific files.

   e.g '*.txt', '*.sql', finds all files ending with .txt and .sql
.PARAMETER Recurse
   A switch, which can be set to search through directories recursively.
.PARAMETER ChangeYoungerThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a change date younger then 20 days are considered within the check.
.PARAMETER ChangeOlderThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a change date older then 20 days are considered within the check.
.PARAMETER CreationYoungerThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a creation date younger then 20 days are considered within the check.
.PARAMETER CreationOlderThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a creation date older then 20 days are considered within the check.
.PARAMETER ChangeTimeEqual
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have been changed 20 days ago are considered within the check.
.PARAMETER CreationTimeEqual
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have been created 20 days ago are considered within the check.
.PARAMETER FileSizeGreaterThan
   String that expects input format like "20MB", which translates to the filze size 20 MB. Allowed units: B, KB, MB, GB, TB.

   Thereby all files with a size of 20 MB or larger are considered within the check.
.PARAMETER FileSizeSmallerThan
   String that expects input format like "5MB", which translates to the filze size 5 MB. Allowed units: B, KB, MB, GB, TB.

   Thereby all files with a size of 5 MB or less are considered within the check.
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

function Invoke-IcingaCheckDirectory()
{
    param(
        [string]$Path,
        [array]$FileNames   = @( '*' ),
        [switch]$Recurse    = $FALSE,
        $Critical           = $null,
        $Warning            = $null,
        [string]$ChangeTimeEqual,
        [string]$ChangeYoungerThan,
        [string]$ChangeOlderThan,
        [string]$CreationTimeEqual,
        [string]$CreationOlderThan,
        [string]$CreationYoungerThan,
        [string]$FileSizeGreaterThan,
        [string]$FileSizeSmallerThan,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0,
        [switch]$NoPerfData
    );

    $DirectoryData  = Get-IcingaDirectoryAll -Path $Path -FileNames $FileNames -Recurse $Recurse `
        -ChangeYoungerThan $ChangeYoungerThan -ChangeOlderThan $ChangeOlderThan `
        -CreationYoungerThan $CreationYoungerThan -CreationOlderThan $CreationOlderThan `
        -CreationTimeEqual $CreationTimeEqual -ChangeTimeEqual $ChangeTimeEqual `
        -FileSizeGreaterThan $FileSizeGreaterThan -FileSizeSmallerThan $FileSizeSmallerThan;
    $DirectoryCheck = New-IcingaCheck -Name 'File Count' -Value $DirectoryData.Count;

    $DirectoryCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    $DirectoryPackage = New-IcingaCheckPackage -Name $Path -OperatorAnd -Checks $DirectoryCheck -Verbose $Verbosity -AddSummaryHeader;

    return (New-IcingaCheckResult -Check $DirectoryPackage -NoPerfData $NoPerfData -Compile);
}
