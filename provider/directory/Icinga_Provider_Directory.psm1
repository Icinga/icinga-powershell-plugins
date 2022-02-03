Import-IcingaLib core\tools;

function Get-IcingaDirectoryAll()
{
    param(
        [string]$Path                = $null,
        [array]$FileNames            = @( '*' ),
        [switch]$Recurse             = $FALSE,
        [string]$ChangeTimeEqual,
        [string]$ChangeYoungerThan,
        [string]$ChangeOlderThan,
        [string]$CreationTimeEqual,
        [string]$CreationOlderThan,
        [string]$CreationYoungerThan,
        [string]$FileSizeGreaterThan,
        [string]$FileSizeSmallerThan
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-Path"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
        return;
    }

    [hashtable]$DirectoryCollector = @{
        'FileList'     = $null;
        'FileCount'    = 0;
        'FolderCount'  = 0;
        'TotalCount'   = 0;
        'TotalSize'    = 0;
        'LargestFile'  = 0;
        'SmallestFile' = 0;
        'AverageSize'  = 0;
    }

    if ($Recurse) {
        $DirectoryData = Get-IcingaDirectoryRecurse -Path $Path -FileNames $FileNames;
    } else {
        $DirectoryData = Get-IcingaDirectory -Path $Path -FileNames $FileNames;
    }

    if ([string]::IsNullOrEmpty($ChangeTimeEqual) -eq $FALSE) {
        $DirectoryData = Get-IcingaDirectoryChangeTimeEqual -ChangeTimeEqual $ChangeTimeEqual -DirectoryData $DirectoryData;
    }

    if ([string]::IsNullOrEmpty($CreationTimeEqual) -eq $FALSE) {
        $DirectoryData = Get-IcingaDirectoryCreationTimeEqual -CreationTimeEqual $CreationTimeEqual -DirectoryData $DirectoryData;
    }

    If ([string]::IsNullOrEmpty($ChangeTimeEqual) -eq $TRUE -Or [string]::IsNullOrEmpty($CreationTimeEqual) -eq $TRUE) {
        if ([string]::IsNullOrEmpty($ChangeOlderThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryChangeOlderThan -ChangeOlderThan $ChangeOlderThan -DirectoryData $DirectoryData;
        }
        if ([string]::IsNullOrEmpty($ChangeYoungerThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryChangeYoungerThan -ChangeYoungerThan $ChangeYoungerThan -DirectoryData $DirectoryData;
        }
        if ([string]::IsNullOrEmpty($CreationOlderThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryCreationOlderThan -CreationOlderThan $CreationOlderThan -DirectoryData $DirectoryData;
        }
        if ([string]::IsNullOrEmpty($CreationYoungerThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryCreationYoungerThan -CreationYoungerThan $CreationYoungerThan -DirectoryData $DirectoryData;
        }
    }
    if ([string]::IsNullOrEmpty($FileSizeGreaterThan) -eq $FALSE) {
        $DirectoryData = (Get-IcingaDirectorySizeGreaterThan -FileSizeGreaterThan $FileSizeGreaterThan -DirectoryData $DirectoryData);
    }
    if ([string]::IsNullOrEmpty($FileSizeSmallerThan) -eq $FALSE) {
        $DirectoryData = (Get-IcingaDirectorySizeSmallerThan -FileSizeSmallerThan $FileSizeSmallerThan -DirectoryData $DirectoryData);
    }

    foreach ($entry in $DirectoryData) {
        if ((Get-Item $entry.FullName) -Is [System.IO.DirectoryInfo]) {
            $DirectoryCollector.FolderCount += 1;
        } else {
            $DirectoryCollector.FileCount += 1;

            if ($DirectoryCollector.LargestFile -lt $entry.Length) {
                $DirectoryCollector.LargestFile = $entry.Length;
            }
            if ($DirectoryCollector.SmallestFile -gt $entry.Length) {
                $DirectoryCollector.SmallestFile = $entry.Length;
            }
        }

        $DirectoryCollector.TotalSize += $entry.Length;
    }

    if ($DirectoryCollector.FileCount -ne 0) {
        $DirectoryCollector.AverageSize = [Math]::Round(($DirectoryCollector.TotalSize / $DirectoryCollector.FileCount), 2);
    }

    $DirectoryCollector.TotalCount = $DirectoryCollector.FolderCount + $DirectoryCollector.FileCount;
    $DirectoryCollector.FileList   = $DirectoryData;

    return $DirectoryCollector;
}

# RECURSE

function Get-IcingaDirectory()
{
    param(
        [string]$Path,
        [array]$FileNames
    );

    if ((Test-Path $Path) -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Input' -CustomMessage 'Path not found' -ExceptionThrown 'Plugin execution failed because the defined -Path does not exist on this system' -Force;
        return @();
    }

    try {
        $DirectoryData = Get-ChildItem -Path $Path -ErrorAction Stop |
            Where-Object {
                foreach ($element in $FileNames) {
                    if ($_.Name -like $element) {
                        return $_.Name
                    }
                }
            }
    }  catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsoleNotice $_.CategoryInfo;
        Exit-IcingaThrowException `
            -InputString $_.CategoryInfo `
            -StringPattern 'PermissionDenied' `
            -ExceptionType 'Input' `
            -ExceptionThrown $IcingaPluginExceptions.FileSystem.PermissionDenied;

        Exit-IcingaThrowException -ExceptionType 'Input' -CustomMessage 'Filesystem Exception' -ExceptionThrown $ExMsg -Force;
    }

    return $DirectoryData;
}

function Get-IcingaDirectoryRecurse()
{
    param(
        [string]$Path,
        [array]$FileNames
    );

    if ((Test-Path $Path) -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Input' -CustomMessage 'Path not found' -ExceptionThrown 'Plugin execution failed because the defined -Path does not exist on this system' -Force;
        return @();
    }

    try {
        $DirectoryData = Get-ChildItem -Recurse -Include $FileNames -Path $Path -ErrorAction Stop;
    } catch {
        $ExMsg = $_.Exception.Message;
        Exit-IcingaThrowException `
            -InputString $_.CategoryInfo `
            -StringPattern 'PermissionDenied' `
            -ExceptionType 'Input' `
            -ExceptionThrown $IcingaPluginExceptions.FileSystem.PermissionDenied;

        Exit-IcingaThrowException -ExceptionType 'Input' -CustomMessage 'Filesystem Exception' -ExceptionThrown $ExMsg -Force;
    }

    return $DirectoryData;
}

# FILE SIZE

function Get-IcingaDirectorySizeGreaterThan()
{
    param(
        [string]$FileSizeGreaterThan,
        $DirectoryData
    );
    $FileSizeGreaterThanValue = (Convert-Bytes $FileSizeGreaterThan -Unit B).value
    $DirectoryData = ($DirectoryData | Where-Object {$_.Length -gt $FileSizeGreaterThanValue})

    return $DirectoryData;
}

function Get-IcingaDirectorySizeSmallerThan()
{
    param(
        [string]$FileSizeSmallerThan,
        $DirectoryData
    );
    $FileSizeSmallerThanValue = (Convert-Bytes $FileSizeSmallerThan -Unit B).value
    $DirectoryData = ($DirectoryData | Where-Object {$_.Length -lt $FileSizeSmallerThanValue})

    return $DirectoryData;
}

# TIME BASED CHANGE

function Get-IcingaDirectoryChangeOlderThan()
{
    param (
        [string]$ChangeOlderThan,
        $DirectoryData
    )
    $ChangeOlderThan = Set-NumericNegative (ConvertTo-Seconds $ChangeOlderThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($ChangeOlderThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryChangeYoungerThan()
{
    param (
        [string]$ChangeYoungerThan,
        $DirectoryData
    )
    $ChangeYoungerThan = Set-NumericNegative (ConvertTo-Seconds $ChangeYoungerThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt (Get-Date).AddSeconds($ChangeYoungerThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryChangeTimeEqual()
{
    param (
        [string]$ChangeTimeEqual,
        $DirectoryData
    )
    $ChangeTimeEqual = Set-NumericNegative (ConvertTo-Seconds $ChangeTimeEqual);
    $ChangeTimeEqual = (Get-Date).AddSeconds($ChangeTimeEqual);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime.Day -eq $ChangeTimeEqual.Day -And $_.LastWriteTime.Month -eq $ChangeTimeEqual.Month -And $_.LastWriteTime.Year -eq $ChangeTimeEqual.Year})

    return $DirectoryData;
}

# TIME BASED CREATION

function Get-IcingaDirectoryCreationYoungerThan()
{
    param (
        [string]$CreationYoungerThan,
        $DirectoryData
    )
    $CreationYoungerThan = Set-NumericNegative (ConvertTo-Seconds $CreationYoungerThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime -gt (Get-Date).AddSeconds($CreationYoungerThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryCreationOlderThan()
{
    param (
        [string]$CreationOlderThan,
        $DirectoryData
    )
    $CreationOlderThan = Set-NumericNegative (ConvertTo-Seconds $CreationOlderThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime -lt (Get-Date).AddSeconds($CreationOlderThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryCreationTimeEqual()
{
    param (
        [string]$CreationTimeEqual,
        $DirectoryData
    )
    $CreationTimeEqual = Set-NumericNegative (ConvertTo-Seconds $CreationTimeEqual);
    $CreationTimeEqual = (Get-Date).AddSeconds($CreationTimeEqual);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime.Day -eq $CreationTimeEqual.Day -And $_.CreationTime.Month -eq $CreationTimeEqual.Month -And $_.CreationTime.Year -eq $CreationTimeEqual.Year})

    return $DirectoryData;
}
