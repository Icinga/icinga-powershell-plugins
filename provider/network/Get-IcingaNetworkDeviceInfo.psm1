function Get-IcingaNetworkDeviceInfo()
{
    # Get a standard information about the drivers using wmi classes
    $GetNetworkDevice  = Get-IcingaWindowsInformation -ClassName Win32_NetWorkAdapter;

    # Get additional informations using MSFT classes
    $MSFT_Devices      = Get-IcingaWindowsInformation -ClassName MSFT_NetAdapter -NameSpace 'root\StandardCimv2';
    $GetTeamInfo       = Get-IcingaNetworkInterfaceTeamInfo;
    $NetworkDeviceData = @{ };
    $TeamDetails       = @{ };

    foreach ($network in $GetNetworkDevice) {
        $NetworkInfo = @{
            'OperationalStatusDownDefaultPortNotAuthenticated' = $null;
            'PhysicalAdapter'                                  = $network.PhysicalAdapter;
            'OperationalStatusDownMediaDisconnected'           = $null;
            'OperationalStatusDownInterfacePaused'             = $null;
            'OperationalStatusDownLowPowerState'               = $null;
            'SupportedMaximumTransmissionUnit'                 = $network.SupportedMaximumTransmissionUnit;
            'ActiveMaximumTransmissionUnit'                    = $null;
            'AvailableRequestedStates'                         = $null;
            'InterfaceOperationalStatus'                       = $network.InterfaceOperationalStatus;
            'AdditionalAvailability'                           = $null;
            'NetConnectionStatus'                              = $network.NetConnectionStatus;
            'DriverVersion'                                    = $network.DriverVersion;
            'AdminLocked'                                      = $null;
            'AutoSense'                                        = $network.AutoSense;
            'Availability'                                     = $network.Availability;
            'Caption'                                          = $network.Caption;
            'CommunicationStatus'                              = $null;
            'ComponentID'                                      = $null;
            'ConnectorPresent'                                 = $null;
            'CreationClassName'                                = $network.CreationClassName;
            'Description'                                      = $network.Description;
            'DetailedStatus'                                   = $null;
            'DeviceID'                                         = $network.DeviceId;
            'DeviceName'                                       = $null;
            'DeviceWakeUpEnable'                               = $null;
            'DriverDate'                                       = $null;
            'DriverDateData'                                   = $null;
            'DriverDescription'                                = $null;
            'DriverMajorNdisVersion'                           = $null;
            'DriverMinorNdisVersion'                           = $null;
            'DriverName'                                       = $null;
            'DriverProvider'                                   = $null;
            'DriverVersionString'                              = $null;
            'ElementName'                                      = $null;
            'EnabledDefault'                                   = $null;
            'EnabledState'                                     = $null;
            'EndPointInterface'                                = $null;
            'ErrorCleared'                                     = $network.ErrorCleared;
            'ErrorDescription'                                 = $network.ErrorDescription;
            'FullDuplex'                                       = $null;
            'HardwareInterface'                                = $null;
            'HealthState'                                      = $null;
            'Hidden'                                           = $null;
            'HigherLayerInterfaceIndices'                      = @{};
            'IdentifyingDescriptions'                          = $null;
            'IMFilter'                                         = $null;
            'InstallDate'                                      = $network.InstallDate;
            'InstanceID'                                       = $null;
            'InterfaceAdminStatus'                             = $null;
            'InterfaceDescription'                             = $null;
            'InterfaceGuid'                                    = $network.GUID;
            'InterfaceIndex'                                   = $network.InterfaceIndex;
            'Index'                                            = $network.Index;
            'InterfaceName'                                    = $null;
            'InterfaceType'                                    = $null;
            'iSCSIInterface'                                   = $null;
            'LastErrorCode'                                    = $network.LastErrorCode;
            'LinkTechnology'                                   = $null;
            'LowerLayerInterfaceIndices'                       = $null;
            'MajorDriverVersion'                               = $null;
            'MaxQuiesceTime'                                   = $network.MaxSpeed;
            'MaxSpeed'                                         = $null;
            'MediaConnectState'                                = $null;
            'MediaDuplexState'                                 = $null;
            'MinorDriverVersion'                               = $null;
            'MtuSize'                                          = $null;
            'Name'                                             = $network.Name;
            'NdisMedium'                                       = $null;
            'NdisPhysicalMedium'                               = $null;
            'NetLuid'                                          = $network.NetConnectionID;
            'NetLuidIndex'                                     = $null;
            'NetworkAddresses'                                 = $network.NetworkAddresses;
            'NotUserRemovable'                                 = $null;
            'OperatingStatus'                                  = $null;
            'OperationalStatus'                                = $null;
            'OtherEnabledState'                                = $null;
            'OtherIdentifyingInfo'                             = $null;
            'OtherLinkTechnology'                              = $null;
            'OtherNetworkPortType'                             = $network.OtherNetworkPortType;
            'OtherPortType'                                    = $network.OtherPortType;
            'PermanentAddress'                                 = $network.PermanentAddress;
            'PnPDeviceID'                                      = $network.PnPDeviceID;
            'PortNumber'                                       = $network.PortNumber;
            'PortType'                                         = $network.PortType;
            'PowerManagementCapabilities'                      = $network.PowerManagementCapabilities;
            'PowerManagementSupported'                         = $network.PowerManagementSupported;
            'PowerOnHours'                                     = $null;
            'PrimaryStatus'                                    = $null;
            'PromiscuousMode'                                  = $null;
            'PSComputerName'                                   = $network.PSComputerName;
            'ReceiveLinkSpeed'                                 = $null;
            'RequestedSpeed'                                   = $null;
            'RequestedState'                                   = $null;
            'Speed'                                            = $network.Speed;
            'State'                                            = $network.State;
            'StatusDescriptions'                               = $null;
            'StatusInfo'                                       = $network.StatusInfo;
            'SystemCreationClassName'                          = $network.SystemCreationClassName;
            'SystemName'                                       = $network.SystemName;
            'TimeOfLastStateChange'                            = $network.TimeOfLastReset;
            'TotalPowerOnHours'                                = $null;
            'TransitioningToState'                             = $null;
            'TransmitLinkSpeed'                                = $null;
            'UsageRestriction'                                 = $null;
            'Virtual'                                          = $null;
            'VlanID'                                           = $null;
            'WdmInterface'                                     = $networkWdmInterface;
            'AdminStatus'                                      = @{};
            'DriverFileName'                                   = @{};
            'DriverInformation'                                = @{};
            'ifOperStatus'                                     = @{};
            'LinkSpeed'                                        = @{};
            'MACAddress'                                       = $network.MAcAddress;
            'MediaConnectionState'                             = @{};
            'MediaType'                                        = @{};
            'NdisVersion'                                      = @{};
            'PhysicalMediaType'                                = @{};
            'Status'                                           = $network.Status;
            'ConfigManagerUserConfig'                          = $null;
        }

        # Add MSFT Netowrk Device information to which we get from the WMI class
        foreach ($msft_device in $MSFT_Devices) {
            if ((($GetTeamInfo.ContainsKey($msft_device.Name)) -eq $TRUE) -And $msft_device.Name -ne $TeamName) {
                $TeamName = $msft_device.Name;
                $TeamDetails.Add($msft_device.Name, $GetTeamInfo[$msft_device.Name]);
            }

            if ($network.GUID -Contains $msft_device.InstanceID) {
                $NetworkInfo.OperationalStatusDownDefaultPortNotAuthenticated = $msft_device.OperationalStatusDownDefaultPortNotAuthenticated;
                $NetworkInfo.OperationalStatusDownMediaDisconnected           = $msft_device.OperationalStatusDownMediaDisconnected;
                $NetworkInfo.OperationalStatusDownInterfacePaused             = $msft_device.OperationalStatusDownInterfacePaused;
                $NetworkInfo.OperationalStatusDownLowPowerState               = $msft_device.OperationalStatusDownLowPowerState;
                $NetworkInfo.ActiveMaximumTransmissionUnit                    = $msft_device.ActiveMaximumTransmissionUnit;
                $NetworkInfo.HigherLayerInterfaceIndices                      = $msft_device.HigherLayerInterfaceIndices;
                $NetworkInfo.InterfaceOperationalStatus                       = $msft_device.InterfaceOperationalStatus;
                $NetworkInfo.AvailableRequestedStates                         = $msft_device.AvailableRequestedStates;
                $NetworkInfo.ConfigManagerUserConfig                          = $msft_device.ConfigManagerUserConfig;
                $NetworkInfo.AdditionalAvailability                           = $msft_device.AdditionalAvailability;
                $NetworkInfo.DriverMajorNdisVersion                           = $msft_device.DriverMajorNdisVersion;
                $NetworkInfo.DriverMinorNdisVersion                           = $msft_device.DriverMinorNdisVersion;
                $NetworkInfo.TransitioningToState                             = $msft_device.TransitioningToState;
                $NetworkInfo.InterfaceAdminStatus                             = $msft_device.InterfaceAdminStatus;
                $NetworkInfo.InterfaceDescription                             = $msft_device.InterfaceDescription;
                $NetworkInfo.OtherNetworkPortType                             = $msft_device.OtherNetworkPortType;
                $NetworkInfo.CommunicationStatus                              = $msft_device.CommunicationStatus;
                $NetworkInfo.DriverVersionString                              = $msft_device.DriverVersionString;
                $NetworkInfo.DeviceWakeUpEnable                               = $msft_device.DeviceWakeUpEnable;
                $NetworkInfo.MajorDriverVersion                               = $msft_device.MajorDriverVersion;
                $NetworkInfo.MinorDriverVersion                               = $msft_device.MinorDriverVersion;
                $NetworkInfo.NdisPhysicalMedium                               = $msft_device.NdisPhysicalMedium;
                $NetworkInfo.HardwareInterface                                = $msft_device.HardwareInterface;
                $NetworkInfo.EndPointInterface                                = $msft_device.EndPointInterface;
                $NetworkInfo.DriverDescription                                = $msft_device.DriverDescription;
                $NetworkInfo.MediaConnectState                                = $msft_device.MediaConnectState;
                $NetworkInfo.TransmitLinkSpeed                                = $msft_device.TransmitLinkSpeed;
                $NetworkInfo.TransmitLinkSpeedBytes                           = ($msft_device.TransmitLinkSpeed / 8);
                $NetworkInfo.ReceiveLinkSpeed                                 = $msft_device.ReceiveLinkSpeed;
                $NetworkInfo.NotUserRemovable                                 = $msft_device.NotUserRemovable;
                $NetworkInfo.NetworkAddresses                                 = $msft_device.NetworkAddresses;
                $NetworkInfo.ConnectorPresent                                 = $msft_device.ConnectorPresent;
                $NetworkInfo.MediaDuplexState                                 = $msft_device.MediaDuplexState;
                $NetworkInfo.UsageRestriction                                 = $msft_device.UsageRestriction;
                $NetworkInfo.PromiscuousMode                                  = $msft_device.PromiscuousMode;
                $NetworkInfo.iSCSIInterface                                   = $msft_device.iSCSIInterface;
                $NetworkInfo.LinkTechnology                                   = $msft_device.LinkTechnology;
                $NetworkInfo.DetailedStatus                                   = $msft_device.DetailedStatus;
                $NetworkInfo.DriverDateData                                   = $msft_device.DriverDateData;
                $NetworkInfo.DriverProvider                                   = $msft_device.DriverProvider;
                $NetworkInfo.EnabledDefault                                   = $msft_device.EnabledDefault;
                $NetworkInfo.RequestedState                                   = $msft_device.RequestedState;
                $NetworkInfo.RequestedSpeed                                   = $msft_device.RequestedSpeed;
                $NetworkInfo.InterfaceGuid                                    = $msft_device.InterfaceGuid;
                $NetworkInfo.InterfaceName                                    = $msft_device.InterfaceName;
                $NetworkInfo.InterfaceType                                    = $msft_device.InterfaceType;
                $NetworkInfo.PrimaryStatus                                    = $msft_device.PrimaryStatus;
                $NetworkInfo.OtherPortType                                    = $msft_device.OtherPortType;
                $NetworkInfo.EnabledState                                     = $msft_device.EnabledState;
                $NetworkInfo.NetLuidIndex                                     = $msft_device.NetLuidIndex;
                $NetworkInfo.PowerOnHours                                     = $msft_device.PowerOnHours;
                $NetworkInfo.WdmInterface                                     = $msft_device.WdmInterface;
                $NetworkInfo.ComponentID                                      = $msft_device.ComponentID;
                $NetworkInfo.AdminLocked                                      = $msft_device.AdminLocked;
                $NetworkInfo.ElementName                                      = $msft_device.ElementName;
                $NetworkInfo.HealthState                                      = $msft_device.HealthState;
                $NetworkInfo.DeviceName                                       = $msft_device.DeviceName;
                $NetworkInfo.DriverDate                                       = $msft_device.DriverDate;
                $NetworkInfo.DriverName                                       = $msft_device.DriverName;
                $NetworkInfo.FullDuplex                                       = $msft_device.FullDuplex;
                $NetworkInfo.InstanceID                                       = $msft_device.InstanceID;
                $NetworkInfo.NdisMedium                                       = $msft_device.NdisMedium;
                $NetworkInfo.PortNumber                                       = $msft_device.PortNumber;
                $NetworkInfo.MACAddress                                       = $msft_device.MACAddress;
                $NetworkInfo.IMFilter                                         = $msft_device.IMFilter;
                $NetworkInfo.NetLuid                                          = $msft_device.NetLuid;
                $NetworkInfo.Virtual                                          = $msft_device.Virtual;
                $NetworkInfo.MtuSize                                          = $msft_device.MtuSize;
                $NetworkInfo.VlanID                                           = $msft_device.VlanID;
                $NetworkInfo.Hidden                                           = $msft_device.Hidden;
                $NetworkInfo.Status                                           = $msft_device.Status;
                $NetworkInfo.State                                            = $msft_device.State;
                $NetworkInfo.Name                                             = $msft_device.Name;

                break;
            }
        }

        if ([string]::IsNullOrEmpty($NetworkInfo.InterfaceDescription) -eq $FALSE) {
            if (($NetworkDeviceData.ContainsKey($NetworkInfo.InterfaceDescription)) -eq $FALSE) {
                $NetworkDeviceData.Add($NetworkInfo.InterfaceDescription, $NetworkInfo);
            }
        }
    }

    $NetworkDeviceData.Add('Team', $TeamDetails);

    return $NetworkDeviceData;
}
