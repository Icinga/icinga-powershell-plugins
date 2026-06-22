function Join-IcingaNetworkDeviceDataPerfCounter()
{
    param (
        [array]$NetworkDeviceCounter        = @(),
        [array]$ExcludeInterfaceTeam        = @(),
        [array]$IncludeInterfaceTeam        = @(),
        [array]$IncludeNetworkDevice        = @(),
        [array]$ExcludeNetworkDevice        = @(),
        [switch]$IncludeHiddenNetworkDevice = $FALSE
    );

    [hashtable]$NetworkDeviceData = @{};
    [hashtable]$CounterHashObject = @{};
    $GetNetworkDevice             = Get-IcingaNetworkDeviceInfo;
    $DeviceCounters               = New-IcingaPerformanceCounterArray $NetworkDeviceCounter;
    $SortedDevices                = New-IcingaPerformanceCounterStructure -CounterCategory 'Network Interface' -PerformanceCounterHash $DeviceCounters;

    foreach ($DeviceName in $SortedDevices.Keys) {
        $NetworkDeviceObject = $SortedDevices[$DeviceName];
        $DeviceData          = $null;
        $DeviceName          = $DeviceName.Replace('[', '(').Replace(']', ')');

        if ([regex]::Match($DeviceName, '_').success) {
            $TmpDeviceName = $DeviceName.Replace('_', '#');

            # Check if the device is found with a #
            if (($GetNetworkDevice.ContainsKey($TmpDeviceName))) {
                $DeviceName = $TmpDeviceName;
            } else {
                $TmpDeviceName = $DeviceName.Replace('_', '/');

                # If not, check if the device is found with a / in name
                if (($GetNetworkDevice.ContainsKey($TmpDeviceName))) {
                    $DeviceName = $TmpDeviceName;
                } elseif (($GetNetworkDevice.ContainsKey($DeviceName)) -eq $FALSE) {
                    # If all substitutions fail and the original name with _ is not found either, skip
                    continue;
                }
            }
        }

        if (($IncludeHiddenNetworkDevice -eq $False) -And $GetNetworkDevice[$DeviceName].Hidden -eq $TRUE) {
            continue;
        }

        if ((Test-IcingaArrayFilter -InputObject $GetNetworkDevice[$DeviceName].Name -Include $IncludeNetworkDevice -Exclude $ExcludeNetworkDevice) -eq $FALSE) {
            continue;
        }

        $DeviceData = $GetNetworkDevice[$DeviceName];

        if (([string]::IsNullOrEmpty($GetNetworkDevice['Team'].Values.Slave)) -eq $FALSE) {
            if (($GetNetworkDevice['Team'].Values.Slave.ContainsKey($GetNetworkDevice[$DeviceName].Name)) -eq $TRUE) { 
                foreach ($key in $NetworkDeviceObject.Keys) {
                    $CounterObject = $NetworkDeviceObject[$key];
                    if (($CounterHashObject.ContainsKey($key)) -eq $TRUE) {
                        $CounterHashObject[$key].value += $CounterObject.value;
                    } else {
                        $CounterHashObject.Add($key, $CounterObject);
                    }
                }

                continue;
            }
        }

        $NetworkDeviceData.Add(
            $DeviceName, @{
                'PerfCounter' = $NetworkDeviceObject;
                'Data'        = $DeviceData;
            }
        );
    }

    foreach ($Team in $GetNetworkDevice['Team'].Keys) {
        $TeamObjects = $GetNetworkDevice['Team'][$team];
        if ($IncludeInterfaceTeam.Count -ne 0) {
            if (($IncludeInterfaceTeam.Contains($Team)) -eq $False) {
                continue;
            }
        }

        if ($ExcludeInterfaceTeam.Count -ne 0) {
            if (($ExcludeInterfaceTeam.Contains($Team)) -eq $True) {
                continue;
            }
        }

        $NetworkDeviceData.Add(
            $Team, @{
                'PerfCounter' = $CounterHashObject;
                'Data'        = $TeamObjects;
            }
        );
    }

    return $NetworkDeviceData;
}
