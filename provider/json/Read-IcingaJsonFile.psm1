function Read-IcingaJsonFile()
{
    param (
        [string]$Path = ''
    );

    $JsonContent       = $null;
    [string]$ReadError = '';

    try {
        $FileStream = [System.IO.File]::Open(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::ReadWrite
        );

        try {
            $StreamReader        = New-Object System.IO.StreamReader($FileStream, [System.Text.Encoding]::UTF8, $TRUE);
            [string]$FileContent = $StreamReader.ReadToEnd();
        } finally {
            $FileStream.Dispose();
        }

        $JsonContent = ConvertFrom-Json -InputObject $FileContent -ErrorAction Stop;

        if ($null -eq $JsonContent) {
            $ReadError = 'The file does not contain any JSON content';
        }
    } catch {
        $ReadError = $_.Exception.Message;

        if ($null -ne $_.Exception.InnerException) {
            $ReadError = $_.Exception.InnerException.Message;
        }
    }

    return @{
        'Content' = $JsonContent;
        'Error'   = $ReadError;
    };
}
