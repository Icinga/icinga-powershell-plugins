function ConvertTo-ServiceStatusCode()
{
    param (
        $Status
    )

    if (Test-Numeric $Status) {
        return [int]$Status
    }

    return [int]($ProviderEnums.ServiceStatus.$Status);
}
