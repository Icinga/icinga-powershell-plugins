<#
.SYNOPSIS
    Checks availability, state and Usage of Network interfaces and Interface Teams
.DESCRIPTION
    This plugin checks availability, status and load of a network adapter. It is also
    equipped with various parameters, so you have the possibility to decide almost
    everything by yourself, when the single checks have to be Warning or Critical. For the
    Team-Members Physical adapters no Performance Counter are displayed.
.ROLE
    ### WMI Permissions

    * root\Cimv2
    * root\StandardCimv2
.PARAMETER IncludeNetworkDevice
    Specify the index of network adapters you want to include for checks. Example 4, 3
.PARAMETER ExcludeNetworkDevice
    Specify the index of network adapters you want to exclude for checks. Example 4, 3
.PARAMETER IncludeInterfaceTeam
    Specify the name of network interface teams you want to include for checks. Example OutboundGroup, ClusterInterface
.PARAMETER ExcludeInterfaceTeam
    Specify the name of network interface teams you want to exclude for checks. Example OutboundGroup, ClusterInterface
.PARAMETER IncludeHiddenNetworkDevice
    Set this argument if you want to include hidden network Adapter for checks. It is a network which is available but is not
    broadcasting its ID.
.PARAMETER PacketReceivedSecWarning
    Warning threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface.
.PARAMETER PacketReceivedSecCritical
    Critical threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface.
.PARAMETER PacketSentSecWarning
    Warning threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface.
.PARAMETER PacketSentSecCritical
    Critical threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface.
.PARAMETER PackteReceivedErrorWarning
    Warning threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing
    them from being deliverable to a higher-layer protocol.
.PARAMETER PackteReceivedErrorCritical
    Critical threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing
    them from being deliverable to a higher-layer protocol.
.PARAMETER PackteOutboundErrorWarning
    Warning threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted
    because of errors.
.PARAMETER PackteOutboundErrorCritical
    Critical threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted
    because of errors.
.PARAMETER PacketReceivedDiscardedWarning
    Warning threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded
    even though no errors had been detected to prevent their delivery to a higher-layer protocol.
.PARAMETER PacketReceivedDiscardedCritical
    Critical threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded
    even though no errors had been detected to prevent their delivery to a higher-layer protocol.
.PARAMETER PacketOutboundDiscardedWarning
    Warning threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded
    even though no errors had been detected to prevent transmission.
.PARAMETER PacketOutboundDiscardedCritical
    Critical threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded
    even though no errors had been detected to prevent transmission.
.PARAMETER IncomingAvgBandUsageWarning
    Warning threshold for network Interface avg. Bytes Received/sec is the average of incoming Bytes.
.PARAMETER IncomingAvgBandUsageCritical
    Critical threshold for network Interface avg. Bytes Received/sec is the average of incoming Bytes.
.PARAMETER OutboundAvgBandUsageWarning
    Warning threshold for network Interface avg. Bytes Sent/sec is the average of outbound Bytes.
.PARAMETER OutboundAvgBandUsageCritical
    Critical threshold for network Interface avg. Bytes Sent/sec is the average of outbound Bytes.
.PARAMETER DeviceTotalBytesSecWarning
    Warning threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter,
    including framing characters.
.PARAMETER DeviceTotalBytesSecCritical
    Critical threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter,
    including framing characters.
.PARAMETER DeviceSentBytesSecWarning
    Warning threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing
    characters.
.PARAMETER DeviceSentBytesSecCritical
    Critical threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing
    characters.
.PARAMETER DeviceReceivedBytesSecWarning
    Warning threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including
    framing characters.
.PARAMETER DeviceReceivedBytesSecCritical
    Critical threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including
    framing characters.
.PARAMETER LinkSpeedWarning
    Warning threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface.
.PARAMETER LinkSpeedCritical
    Critical threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface.
.PARAMETER InterfaceTeamStatusWarning
    Warning threshold for the Status of a network Interface Teams.
.PARAMETER InterfaceTeamStatusCritical
    Critical threshold for the Status of a network Interface Teams.
.PARAMETER InterfaceSlaveEnabledStateWarning
    Warning threshold for the State of a network Interface Team-Members/Slaves.
.PARAMETER InterfaceSlaveEnabledStateCritical
    Critical threshold for the State of a network Interface Team-Members/Slaves.
.PARAMETER InterfaceAdminStatusWarning
    Warning threshold for the network Interface administrative status.
.PARAMETER InterfaceOperationalStatusWarning
    Warning threshold for the current network interface operational status.
.Parameter InterfaceOperationalStatusCritical
    Critical threshold for the current network interface operational status.
.PARAMETER InterfaceConnectionStatusWarning
    Warning threshold for the state of the network adapter connection to the network.
.PARAMETER InterfaceConnectionStatusCritical
    Critical threshold for the state of the network adapter connection to the network.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
.EXAMPLE
    PS> icinga { Invoke-IcingaCheckNetworkInterface  -Verbosity 2  }
    [OK] Check package "Network Device Package" (Match All)
        \_ [OK] Check package "Interface Ethernet" (Match All)
        \_ [OK] #1 AdminLocked: False
        \_ [OK] #1 bytes received/sec: 3691.900146B
        \_ [OK] #1 bytes sent/sec: 324.831177B
        \_ [OK] #1 bytes total/sec: 3994.609619B
        \_ [OK] #1 Interface AdminStatus: Up
        \_ [OK] #1 Interface OperationalStatus: Up
        \_ [OK] #1 LinkSpeed: 1 GBit
        \_ [OK] #1 NetConnectionStatus: Connected
        \_ [OK] #1 packets avg. incoming traffic load: 0%
        \_ [OK] #1 packets avg. outbound traffic load: 0%
        \_ [OK] #1 packets outbound discarded: 0
        \_ [OK] #1 packets outbound errors: 0
        \_ [OK] #1 packets received discarded: 0
        \_ [OK] #1 packets received errors: 0
        \_ [OK] #1 packets received/sec: 6.467305
        \_ [OK] #1 packets sent/sec: 1.659066
        \_ [OK] #1 VlanID:
    | '1_packets_outbound_discarded'=0;; '1_packets_receivedsec'=6.467305;; '1_bytes_receivedsec'=3691.900146B;; '1_packets_received_errors'=0;; '1_packets_sentsec'=1.659066;; '1_bytes_sentsec'=324.831177B;; '1_packets_avg_incomming_traffic_load'=0%;;;0;100 '1_packets_received_discarded'=0;; '1_packets_avg_outbound_traffic_load'=0%;;;0;100 '1_packets_outbound_errors'=0;; '1_bytes_totalsec'=3994.609619B;;
    0
.LINK
    https://github.com/Icinga/icinga-powershell-framework
    https://github.com/Icinga/icinga-powershell-plugins
    https://icinga.com/docs/windows/latest/doc/01-Introduction/
#>

function Invoke-IcingaCheckNetworkInterface()
{
    param (
        [array]$IncludeNetworkDevice        = @(),
        [array]$ExcludeNetworkDevice        = @(),
        [array]$ExcludeInterfaceTeam        = @(),
        [array]$IncludeInterfaceTeam        = @(),
        $PacketReceivedSecWarning           = $null,
        $PacketReceivedSecCritical          = $null,
        $PacketSentSecWarning               = $null,
        $PacketSentSecCritical              = $null,
        $PackteReceivedErrorWarning         = $null,
        $PackteReceivedErrorCritical        = $null,
        $PackteOutboundErrorWarning         = $null,
        $PackteOutboundErrorCritical        = $null,
        $PacketReceivedDiscardedWarning     = $null,
        $PacketReceivedDiscardedCritical    = $null,
        $PacketOutboundDiscardedWarning     = $null,
        $PacketOutboundDiscardedCritical    = $null,
        $IncomingAvgBandUsageWarning        = $null,
        $IncomingAvgBandUsageCritical       = $null,
        $OutboundAvgBandUsageWarning        = $null,
        $OutboundAvgBandUsageCritical       = $null,
        $DeviceTotalBytesSecWarning         = $null,
        $DeviceTotalBytesSecCritical        = $null,
        $DeviceSentBytesSecWarning          = $null,
        $DeviceSentBytesSecCritical         = $null,
        $DeviceReceivedBytesSecWarning      = $null,
        $DeviceReceivedBytesSecCritical     = $null,
        $LinkSpeedWarning,
        $LinkSpeedCritical,
        [ValidateSet('Up', 'Down', 'Degraded')]
        $InterfaceTeamStatusWarning,
        [ValidateSet('Up', 'Down', 'Degraded')]
        $InterfaceTeamStatusCritical,
        [ValidateSet('Unknown', 'Other', 'Enabled', 'Disabled', 'ShuttingDown', 'NotApplicable', 'EnabledButOffline', 'InTest', 'Deferred', 'Quiesce', 'Starting')]
        $InterfaceSlaveEnabledStateWarning,
        [ValidateSet('Unknown', 'Other', 'Enabled', 'Disabled', 'ShuttingDown', 'NotApplicable', 'EnabledButOffline', 'InTest', 'Deferred', 'Quiesce', 'Starting')]
        $InterfaceSlaveEnabledStateCritical,
        [ValidateSet('Up', 'Down', 'Testing')]
        $InterfaceAdminStatusWarning,
        [ValidateSet('Up', 'Down', 'Testing', 'Unknown', 'Dormant', 'NotPresent', 'LowerLayerDown')]
        $InterfaceOperationalStatusWarning,
        [ValidateSet('Up', 'Down', 'Testing', 'Unknown', 'Dormant', 'NotPresent', 'LowerLayerDown')]
        $InterfaceOperationalStatusCritical,
        [ValidateSet('Disconnected', 'Connecting', 'Connected', 'Disconnecting', 'HardwareNotPresent', 'HardwareDisabled', 'HardwareMalfunction', 'MediaDisconnected', 'Authenticating', 'AuthenticationSucceeded', 'AuthenticationFailed', 'InvalidAddress', 'CredentialsRequired', 'Other')]
        $InterfaceConnectionStatusWarning,
        [ValidateSet('Disconnected', 'Connecting', 'Connected', 'Disconnecting', 'HardwareNotPresent', 'HardwareDisabled', 'HardwareMalfunction', 'MediaDisconnected', 'Authenticating', 'AuthenticationSucceeded', 'AuthenticationFailed', 'InvalidAddress', 'CredentialsRequired', 'Other')]
        $InterfaceConnectionStatusCritical,
        [switch]$IncludeHiddenNetworkDevice = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        $Verbosity                          = 0
    );

    $NetworkDevices = Join-IcingaNetworkDeviceDataPerfCounter -NetworkDeviceCounter @(
        '\Network Interface(*)\packets received/sec',
        '\Network Interface(*)\packets sent/sec',
        '\Network Interface(*)\packets received errors',
        '\Network Interface(*)\packets outbound errors',
        '\Network Interface(*)\packets received discarded',
        '\Network Interface(*)\packets outbound discarded',
        '\Network Interface(*)\bytes total/sec',
        '\Network Interface(*)\bytes received/sec',
        '\Network Interface(*)\bytes sent/sec'
    ) `
        -IncludeNetworkDevice $IncludeNetworkDevice `
        -ExcludeNetworkDevice $ExcludeNetworkDevice `
        -ExcludeInterfaceTeam $ExcludeInterfaceTeam `
        -IncludeInterfaceTeam $IncludeInterfaceTeam `
        -IncludeHiddenNetworkDevice:$IncludeHiddenNetworkDevice;

    $CheckPackage          = New-IcingaCheckPackage -Name 'Network Device Package' -OperatorAnd -Verbose $Verbosity;
    $InterfaceTeamsPackage = New-IcingaCheckPackage -Name 'Interface Teams' -OperatorAnd -Verbose $Verbosity;
    $HiddenCheckPackage    = New-IcingaCheckPackage -Name 'Hidden PerfData Package' -Hidden;

    foreach ($NetworkDevice in $NetworkDevices.Keys) {
        $NetworkDeviceObject = $NetworkDevices[$NetworkDevice];

        # If we have no data, skip this object
        if ($null -eq $NetworkDeviceObject.Data) {
            continue;
        }

        # Define a basic set of variables to use for naming and easier handling
        $CheckPackageName    = '';
        $InterfaceTeamName   = '';
        $InterfaceName       = '';
        [bool]$IsNetworkTeam = $FALSE;

        # If we are a team object, setup our variables differently with other naming tags
        if ((($NetworkDeviceObject.Data.ContainsKey('TeamingMode')) -eq $TRUE) -And ($NetworkDeviceObject.Data.ContainsKey('Team'))) {
            $CheckPackageName  = ([string]::Format('Team {0}', $NetworkDeviceObject.Data.Name));
            $InterfaceTeamName = $NetworkDeviceObject.Data.Name;
            $InterfaceName     = $InterfaceTeamName;
            $IsNetworkTeam     = $TRUE;
        } else {
            # In case are simple interfaces, initialise them with other names
            $CheckPackageName = ([string]::Format('Interface {0}', $NetworkDeviceObject.Data.Name));
            $InterfaceName    = ([string]::Format('eth {0}', $NetworkDeviceObject.Data.Index));
        }

        # Create a new package we add all our performance metrics and interface data into
        $NetworkEntryCheckPackage = New-IcingaCheckPackage -Name $CheckPackageName -OperatorAnd -Verbose $Verbosity;

        # At first add all performance counters
        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets received/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets received/sec'].value `
            ).WarnOutOfRange(
                $PacketReceivedSecWarning
            ).CritOutOfRange(
                $PacketReceivedSecCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets sent/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets sent/sec'].value `
            ).WarnOutOfRange(
                $PacketSentSecWarning
            ).CritOutOfRange(
                $PacketSentSecCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets received errors', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets received errors'].value
            ).WarnOutOfRange(
                $PackteReceivedErrorWarning
            ).CritOutOfRange(
                $PackteReceivedErrorCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets outbound errors', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets outbound errors'].value
            ).WarnOutOfRange(
                $PackteOutboundErrorWarning
            ).CritOutOfRange(
                $PackteOutboundErrorCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets received discarded', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets received discarded'].value
            ).WarnOutOfRange(
                $PacketReceivedDiscardedWarning
            ).CritOutOfRange(
                $PacketReceivedDiscardedCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets outbound discarded', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets outbound discarded'].value
            ).WarnOutOfRange(
                $PacketOutboundDiscardedWarning
            ).CritOutOfRange(
                $PacketOutboundDiscardedCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets avg. outbound traffic load', $InterfaceName)) `
                    -Value (
                    Get-IcingaInterfaceAverageBandWidthUsage `
                        -AverageTrafficBytes ($NetworkDeviceObject.PerfCounter['bytes sent/sec'].value) `
                        -TotalBandwidth $NetworkDeviceObject.Data.TransmitLinkSpeed
                ) `
                    -Unit '%'
            ).WarnOutOfRange(
                $OutboundAvgBandUsageWarning
            ).CritOutOfRange(
                $OutboundAvgBandUsageCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets avg. incoming traffic load', $InterfaceName)) `
                    -Value (
                    Get-IcingaInterfaceAverageBandWidthUsage `
                        -AverageTrafficBytes ($NetworkDeviceObject.PerfCounter['bytes received/sec'].value) `
                        -TotalBandwidth $NetworkDeviceObject.Data.TransmitLinkSpeed
                ) `
                    -Unit '%'
            ).WarnOutOfRange(
                $IncomingAvgBandUsageWarning
            ).CritOutOfRange(
                $IncomingAvgBandUsageCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: bytes total/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['bytes total/sec'].value `
                    -Unit 'B'
            ).WarnOutOfRange(
                $DeviceTotalBytesSecWarning
            ).CritOutOfRange(
                $DeviceTotalBytesSecCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: bytes sent/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['bytes sent/sec'].value `
                    -Unit 'B'
            ).WarnOutOfRange(
                $DeviceSentBytesSecWarning
            ).CritOutOfRange(
                $DeviceSentBytesSecCritical
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: bytes received/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['bytes received/sec'].value `
                    -Unit 'B'
            ).WarnOutOfRange(
                $DeviceReceivedBytesSecWarning
            ).CritOutOfRange(
                $DeviceReceivedBytesSecCritical
            )
        );

        # Add VLAN Id to system if present
        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: VlanID', $InterfaceName)) `
                    -Value $NetworkDeviceObject.Data.VlanID `
                    -NoPerfData
            )
        );

        # Add the checks for our interface link speed and performance metrics
        $LinkChecks = Get-IcingaNetworkSpeedChecks -Name $InterfaceName -LinkSpeed $NetworkDeviceObject.Data.TransmitLinkSpeed -LinkSpeedWarning $LinkSpeedWarning -LinkSpeedCritical $LinkSpeedCritical;
        $NetworkEntryCheckPackage.AddCheck($LinkChecks.CheckLinkSpeed);
        $HiddenCheckPackage.AddCheck($LinkChecks.PerfDataLinkSpeed);

        # Add specific check content which only applies to network teams
        if ($IsNetworkTeam) {
            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Teaming Mode', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.TeamingMode `
                        -Translation $ProviderEnums.TeamingMode `
                        -NoPerfData
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Status', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.Status `
                        -Translation $ProviderEnums.InterfaceTeamStatus `
                        -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.InterfaceTeamStatusName[[string]$InterfaceTeamStatusWarning]
                ).CritIfMatch(
                    $ProviderEnums.InterfaceTeamStatusName[[string]$InterfaceTeamStatusCritical]
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Members', $InterfaceName)) `
                        -Value ($NetworkDeviceObject.Data.Members.Count) `
                        -NoPerfData
                )
            );

            # We need to take care about the members of our team
            foreach ($InterfaceMember in $NetworkDeviceObject.Data.Slave.Keys) {
                $TeamMember        = $NetworkDeviceObject.Data.Slave[$InterfaceMember];
                $TeamMemberPackage = New-IcingaCheckPackage -Name ([string]::Format('Interface {0} (Team: {1})', $TeamMember.Name, $TeamMember.Team)) -OperatorAnd -Verbose $Verbosity;

                $TeamMemberPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0}: Administrative Mode', $TeamMember.Name)) `
                            -Value $TeamMember.AdministrativeMode `
                            -Translation $ProviderEnums.AdministrativeMode `
                            -NoPerfData
                    ).WarnIfMatch(
                        $ProviderEnums.AdministrativeModeName.Standby
                    )
                );

                $OperationalModeCheck = New-IcingaCheck `
                    -Name ([string]::Format('{0}: Operational Mode', $TeamMember.Name)) `
                    -Value $TeamMember.OperationalMode `
                    -Translation $ProviderEnums.OperationalMode `
                    -NoPerfData;

                if ($TeamMember.OperationalMode -eq $ProviderEnums.OperationalModeName.Active -or $ProviderEnums.OperationalModeName.Standby) {
                    $TeamMemberPackage.AddCheck($OperationalModeCheck);
                } else {
                    $OperationalModeCheck.SetCritical() | Out-Null;
                    $TeamMemberPackage.AddCheck($OperationalModeCheck);
                }

                $TeamMemberPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0}: Enabled State', $TeamMember.Name)) `
                            -Value $TeamMember.EnabledState `
                            -Translation $ProviderEnums.SlaveEnabledState `
                            -NoPerfData
                    ).WarnIfMatch(
                        $ProviderEnums.SlaveEnabledStateName[[string]$InterfaceSlaveEnabledStateWarning]
                    ).CritIfMatch(
                        $ProviderEnums.SlaveEnabledStateName[[string]$InterfaceSlaveEnabledStateCritical]
                    )
                );

                # Add the checks for our interface link speed and performance metrics
                $LinkChecks = Get-IcingaNetworkSpeedChecks -Name $TeamMember.Name -LinkSpeed $TeamMember.TransmitLinkSpeed -LinkSpeedWarning $LinkSpeedWarning -LinkSpeedCritical $LinkSpeedCritical;
                $TeamMemberPackage.AddCheck($LinkChecks.CheckLinkSpeed);
                $HiddenCheckPackage.AddCheck($LinkChecks.PerfDataLinkSpeed);

                $CheckPackage.AddCheck($TeamMemberPackage);
            }

            $InterfaceTeamsPackage.AddCheck($NetworkEntryCheckPackage);
        } else {
            # All remaining data for regular interfaces not part of a team
            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: AdminLocked', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.AdminLocked `
                        -NoPerfData
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Interface AdminStatus', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.InterfaceAdminStatus `
                        -Translation $ProviderEnums.InterfaceAdminStatus `
                        -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.InterfaceAdminStatusName[[string]$InterfaceAdminStatusWarning]
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: Interface OperationalStatus', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.InterfaceOperationalStatus `
                        -Translation $ProviderEnums.InterfaceOperationalStatus `
                        -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.InterfaceOperationalStatusName[[string]$InterfaceOperationalStatusWarning]
                ).CritIfMatch(
                    $ProviderEnums.InterfaceOperationalStatusName[[string]$InterfaceOperationalStatusCritical]
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: NetConnectionStatus', $InterfaceName)) `
                        -Value $NetworkDeviceObject.Data.NetConnectionStatus `
                        -Translation $ProviderEnums.NetConnectionStatus `
                        -NoPerfData
                ).WarnIfMatch(
                    $ProviderEnums.NetConnectionStatusName[[string]$InterfaceConnectionStatusWarning]
                ).CritIfMatch(
                    $ProviderEnums.NetConnectionStatusName[[string]$InterfaceConnectionStatusCritical]
                )
            );

            $CheckPackage.AddCheck($NetworkEntryCheckPackage);
        }
    }

    if ($InterfaceTeamsPackage.HasChecks()) {
        $CheckPackage.AddCheck($InterfaceTeamsPackage);
    }

    if ($HiddenCheckPackage.HasChecks()) {
        $CheckPackage.AddCheck($HiddenCheckPackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
