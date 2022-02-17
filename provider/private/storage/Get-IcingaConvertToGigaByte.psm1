function Get-IcingaConvertToGigaByte()
{
    param(
        [long]$ByteValues
    );

    if ([string]::IsNullOrEmpty($ByteValues) -eq $TRUE) {
        return 0;
    }

    $Result = ($ByteValues / [System.Math]::Pow(2, 30));
    $Result = [Math]::Round($Result, 2);

    return $Result;
}
