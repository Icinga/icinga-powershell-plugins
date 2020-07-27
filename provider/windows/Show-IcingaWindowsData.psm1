function Show-IcingaWindowsData()
{
    $WindowsInformations = Get-IcingaWindowsInformation Win32_OperatingSystem;

    $windows_datails = @{};
    foreach($cpu_core in $WindowsInformations.CimInstanceProperties) {
        $windows_datails.Add($cpu_core.Name, $cpu_core.Value);
    }

    return $windows_datails;
}