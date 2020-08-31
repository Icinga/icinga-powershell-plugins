function Get-IcingaVolumeAvgCalculator()
{
    param(
        [long]$TotalSize,
        [long]$FreeSpace
    );

    if ([string]::IsNullOrEmpty($TotalSize) -eq $TRUE) {
        return 0;
    }

    $Result = ($FreeSpace * 100);
    $Result = [Math]::Round($Result / $TotalSize, 2);

    return $Result;
}