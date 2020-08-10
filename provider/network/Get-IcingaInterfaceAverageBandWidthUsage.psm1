function Get-IcingaInterfaceAverageBandWidthUsage()
{
    param (
        [double]$AverageTrafficBytes,
        [long]$TotalBandwidth
    );

    if ($TotalBandwidth -eq 0) {
        return 0;
    }

    $ConvertToByte = ($TotalBandwidth / 8);
    $AverageUsage  = [Math]::Round(($AverageTrafficBytes * 100) / $ConvertToByte, 2);

    return $AverageUsage;
}
