function Get-IcingaServiceCheckName()
{
    param (
        [string]$ServiceInput,
        $Service
    );

    if ($null -eq $Service) {
        return [string]::Format(
            'Service "{0}"',
            $ServiceInput
        );
    }

    return [string]::Format(
        'Service "{0} ({1})"',
        $Service.metadata.DisplayName,
        $Service.metadata.ServiceName
    );
}
