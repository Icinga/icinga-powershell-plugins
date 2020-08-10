function Get-IcingaNetworkInterfaceUnits()
{
    param (
        [long]$Value
    );

    $result = ($Value / [Math]::Pow(10, 6));

    if ($result -ge 1000) {
        $result = ([string]::Format('{0} {1}', ($result / 1000), 'GBit'));
    } else {
        $result = ([string]::Format('{0} {1}', $result, 'MBit'));
    }

    return $result;
}
