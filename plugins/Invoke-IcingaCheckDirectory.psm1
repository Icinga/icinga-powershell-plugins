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
    PS> Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3;

    [CRITICAL] Directory Check: "C:\Users\Icinga\Downloads": 1 Critical 5 Ok [CRITICAL] File Count (33) (All must be [OK])
    \_ [OK] Average File Size: 76.94MiB
    \_ [CRITICAL] File Count: 33 is greater than threshold 30
    \_ [OK] Folder Count: 1
    \_ [OK] Largest File Size: 1.07GiB
    \_ [OK] Smallest File Size: 0B
    \_ [OK] Total Size: 2.48GiB
    | 'average_file_size'=80677000B;; 'folder_count'=1;; 'total_size'=2662341000B;; 'largest_file_size'=1149023000B;; 'file_count'=33;20;30 'smallest_file_size'=0B;;
.EXAMPLE
    PS> Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThan 5d;

    [WARNING] Directory Check: "C:\Users\Icinga\Downloads": 1 Warning 5 Ok [WARNING] File Count (22) (All must be [OK])
    \_ [OK] Average File Size: 738.29KiB
    \_ [WARNING] File Count: 22 is greater than threshold 20
    \_ [OK] Folder Count: 0
    \_ [OK] Largest File Size: 4.23MiB
    \_ [OK] Smallest File Size: 0B
    \_ [OK] Total Size: 15.86MiB
    | 'average_file_size'=756008B;; 'folder_count'=0;; 'total_size'=16632180B;; 'largest_file_size'=4439043B;; 'file_count'=22;20;30 'smallest_file_size'=0B;;
.EXAMPLE
    PS> Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeOlderThan 10d;

    [OK] Directory Check: "C:\Users\Icinga\Downloads": 6 Ok (All must be [OK])
    \_ [OK] Average File Size: 359.40MiB
    \_ [OK] File Count: 7
    \_ [OK] Folder Count: 1
    \_ [OK] Largest File Size: 1.07GiB
    \_ [OK] Smallest File Size: 0B
    \_ [OK] Total Size: 2.46GiB
    | 'average_file_size'=376853700B;; 'folder_count'=1;; 'total_size'=2637976000B;; 'largest_file_size'=1149023000B;; 'file_count'=7;20;30 'smallest_file_size'=0B;;
.EXAMPLE
    PS> Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -Verbosity 3 -FileNames '*.exe', '*.zip';

    [OK] Directory Check: "C:\Users\Icinga\Downloads": 6 Ok (All must be [OK])
    \_ [OK] Average File Size: 210.57MiB
    \_ [OK] File Count: 12
    \_ [OK] Folder Count: 0
    \_ [OK] Largest File Size: 1.07GiB
    \_ [OK] Smallest File Size: 0B
    \_ [OK] Total Size: 2.47GiB
    | 'average_file_size'=220801200B;; 'folder_count'=0;; 'total_size'=2649615000B;; 'largest_file_size'=1149023000B;; 'file_count'=12;20;30 'smallest_file_size'=0B;;
.EXAMPLE
    PS> Invoke-IcingaCheckDirectory -Path 'C:\Users\Icinga\Downloads' -Warning 20 -Critical 30 -WarningTotalSize '2GiB';

    [CRITICAL] Directory Check: "C:\Users\Icinga\Downloads": 1 Critical 1 Warning 4 Ok [CRITICAL] File Count (33) [WARNING] Total Size (2.48GiB)
    \_ [CRITICAL] File Count: 33 is greater than threshold 30
    \_ [WARNING] Total Size: 2.48GiB is greater than threshold 2.00GiB
    | 'average_file_size'=80677000B;; 'folder_count'=1;; 'total_size'=2662341000B;2147484000; 'largest_file_size'=1149023000B;; 'file_count'=33;20;30 'smallest_file_size'=0B;;
.PARAMETER Warning
    Checks the resulting file count of the provided filters and input and returns warning for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER Critical
    Checks the resulting file count of the provided filters and input and returns critical for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER WarningTotalSize
    Checks the total folder size of all files of the provided filters and input and returns warning for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER CriticalTotalSize
    Checks the total folder size of all files of the provided filters and input and returns critical for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER WarningSmallestFile
    Checks the smallest file size found for the given filters and input and returns warning for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER CriticalSmallestFile
    Checks the smallest file size found for the given filters and input and returns critical for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER WarningLargestFile
    Checks the largest file size found for the given filters and input and returns warning for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER CriticalLargestFile
    Checks the largest file size found for the given filters and input and returns critical for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER WarningAverageFile
    Checks the average file size found for the given filters and input and returns warning for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER CriticalAverageFile
    Checks the average file size found for the given filters and input and returns critical for the provided threshold.

    Follows the Icinga plugin threshold guidelines.
.PARAMETER Path
    Used to specify a path.
    e.g. 'C:\Users\Icinga\Downloads'
.PARAMETER CountFolderAsFile
    Will add the count of folders on top of the file count, allowing to include it within the threshold check.
.PARAMETER ShowFileList
    Allows to add the file list to the plugin output. Beware that this will cause your database to grow and
    performance might be slower on huge directories!
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
    param (
        [string]$Path                = '',
        [array]$FileNames            = @( '*' ),
        [switch]$Recurse             = $FALSE,
        $Critical                    = $null,
        $Warning                     = $null,
        $WarningTotalSize            = $null,
        $CriticalTotalSize           = $null,
        $WarningSmallestFile         = $null,
        $CriticalSmallestFile        = $null,
        $WarningLargestFile          = $null,
        $CriticalLargestFile         = $null,
        $WarningAverageFile          = $null,
        $CriticalAverageFile         = $null,
        [switch]$CountFolderAsFile   = $FALSE,
        [switch]$ShowFileList        = $FALSE,
        [string]$ChangeTimeEqual,
        [string]$ChangeYoungerThan,
        [string]$ChangeOlderThan,
        [string]$CreationTimeEqual,
        [string]$CreationOlderThan,
        [string]$CreationYoungerThan,
        [string]$FileSizeGreaterThan,
        [string]$FileSizeSmallerThan,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity              = 0,
        [switch]$NoPerfData          = $FALSE
    );

    $DirectoryData = Get-IcingaDirectoryAll -Path $Path -FileNames $FileNames -Recurse:$Recurse `
        -ChangeYoungerThan $ChangeYoungerThan -ChangeOlderThan $ChangeOlderThan `
        -CreationYoungerThan $CreationYoungerThan -CreationOlderThan $CreationOlderThan `
        -CreationTimeEqual $CreationTimeEqual -ChangeTimeEqual $ChangeTimeEqual `
        -FileSizeGreaterThan $FileSizeGreaterThan -FileSizeSmallerThan $FileSizeSmallerThan;

    $DirectoryCheck = New-IcingaCheckPackage -Name ([string]::Format('Directory Check: "{0}"', $Path)) -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    if ($ShowFileList) {
        $DirectoryFileList = New-IcingaCheckPackage -Name 'File List' -IsNoticePackage -OperatorAnd -Verbose 3;

        foreach ($entry in $DirectoryData.FileList) {
            $FileDetailPackage = New-IcingaCheckPackage -Name $entry.FullName -IsNoticePackage -OperatorAnd -Verbose 3;

            $FileDetailPackage.AddCheck(
                (New-IcingaCheck -Name 'File Size' -Value $entry.Length -Unit 'B' -NoPerfData).SetNotice()
            );

            $DirectoryFileList.AddCheck($FileDetailPackage);
        }

        $DirectoryCheck.AddCheck($DirectoryFileList);
    }

    [int]$FileCount = $DirectoryData.FileCount;

    if ($CountFolderAsFile) {
        $FileCount += $DirectoryData.FolderCount;
    }

    $MetricIndex      = $Path.Replace('\', '').Replace(':', '').Replace('/', '');

    $FolderCountCheck = New-IcingaCheck -Name 'Folder Count' -Value $DirectoryData.FolderCount -MetricIndex $MetricIndex -MetricName 'folders';

    $FileCountCheck   = New-IcingaCheck -Name 'File Count' -Value $FileCount -MetricIndex $MetricIndex -MetricName 'files';
    $FileCountCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    $TotalSizeCheck   = New-IcingaCheck -Name 'Total Size' -Value $DirectoryData.TotalSize -Unit 'B' -MetricIndex $MetricIndex -MetricName 'totalsize';
    $TotalSizeCheck.WarnOutOfRange($WarningTotalSize).CritOutOfRange($CriticalTotalSize) | Out-Null;

    $SmallestFileSize = New-IcingaCheck -Name 'Smallest File Size' -Value $DirectoryData.SmallestFile -Unit 'B' -MetricIndex $MetricIndex -MetricName 'smallestfile';
    $SmallestFileSize.WarnOutOfRange($WarningSmallestFile).CritOutOfRange($CriticalSmallestFile) | Out-Null;

    $LargestFileSize  = New-IcingaCheck -Name 'Largest File Size' -Value $DirectoryData.LargestFile -Unit 'B' -MetricIndex $MetricIndex -MetricName 'largestfile';
    $LargestFileSize.WarnOutOfRange($WarningLargestFile).CritOutOfRange($CriticalLargestFile) | Out-Null;

    $AverageFileSize  = New-IcingaCheck -Name 'Average File Size' -Value $DirectoryData.AverageSize -Unit 'B' -MetricIndex $MetricIndex -MetricName 'averagefile';
    $AverageFileSize.WarnOutOfRange($WarningAverageFile).CritOutOfRange($CriticalAverageFile) | Out-Null;

    $DirectoryCheck.AddCheck($FileCountCheck);
    $DirectoryCheck.AddCheck($FolderCountCheck);
    $DirectoryCheck.AddCheck($TotalSizeCheck);
    $DirectoryCheck.AddCheck($SmallestFileSize);
    $DirectoryCheck.AddCheck($LargestFileSize);
    $DirectoryCheck.AddCheck($AverageFileSize);

    return (New-IcingaCheckResult -Check $DirectoryCheck -NoPerfData $NoPerfData -Compile);
}
