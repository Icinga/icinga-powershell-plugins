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
.PARAMETER IncludeHidden
    Set this argument if you want to include hidden network Adapter for checks. It is a network which is available but is not
    broadcasting its ID.
.PARAMETER PacketReceivedSecWarn
    Warning threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface.
.PARAMETER PacketReceivedSecCrit
    Critical threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface.
.PARAMETER PacketSentSecWarn
    Warning threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface.
.PARAMETER PacketSentSecCrit
    Critical threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface.
.PARAMETER PackteReceivedErrorWarn
    Warning threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing
    them from being deliverable to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want
    a percentage comparison. Default (c)
.PARAMETER PackteReceivedErrorCrit
    Critical threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing
    them from being deliverable to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c)
.PARAMETER PackteOutboundErrorWarn
    Warning threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted
    because of errors. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c)
.PARAMETER PackteOutboundErrorCrit
    Critical threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted
    because of errors. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c)
.PARAMETER PacketReceivedDiscardedWarn
    Warning threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded
    even though no errors had been detected to prevent their delivery to a higher-layer protocol. It is possible to enter e.g. 10% as
    threshold value if you want a percentage comparison. Default (c)
.PARAMETER PacketReceivedDiscardedCrit
    Critical threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded
    even though no errors had been detected to prevent their delivery to a higher-layer protocol. It is possible to enter e.g. 10% as
    threshold value if you want a percentage comparison. Default (c)
.PARAMETER PacketOutboundDiscardedWarn
    Warning threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded
    even though no errors had been detected to prevent transmission. It is possible to enter e.g. 10% as threshold value if you want
    a percentage comparison. Default (c)
.PARAMETER PacketOutboundDiscardedCrit
    Critical threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded
    even though no errors had been detected to prevent transmission. It is possible to enter e.g. 10% as threshold value if you want
    a percentage comparison. Default (c)
.PARAMETER DeviceTotalBytesSecWarn
    Warning threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter,
    including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER DeviceTotalBytesSecCrit
    Critical threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter,
    including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER DeviceSentBytesSecWarn
    Warning threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing
    characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER DeviceSentBytesSecCrit
    Critical threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing
    characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER DeviceReceivedBytesSecWarn
    Warning threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including
    framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER DeviceReceivedBytesSecCrit
    Critical threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including
    framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER LinkSpeedWarn
    Warning threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface.
.PARAMETER LinkSpeedCrit
    Critical threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface.
.PARAMETER IfTeamStatusWarn
    Warning threshold for the Status of a network Interface Teams.
.PARAMETER IfTeamStatusCrit
    Critical threshold for the Status of a network Interface Teams.
.PARAMETER IfSlaveEnabledStateWarn
    Warning threshold for the State of a network Interface Team-Members/Slaves.
.PARAMETER IfSlaveEnabledStateCrit
    Critical threshold for the State of a network Interface Team-Members/Slaves.
.PARAMETER IfAdminStatusWarn
    Warning threshold for the network Interface administrative status.
.PARAMETER IfOperationalStatusWarn
    Warning threshold for the current network interface operational status.
.Parameter IfOperationalStatusCrit
    Critical threshold for the current network interface operational status.
.PARAMETER IfConnectionStatusWarn
    Warning threshold for the state of the network adapter connection to the network.
.PARAMETER IfConnectionStatusCrit
    Critical threshold for the state of the network adapter connection to the network.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
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
        \_ [OK] #1 packets outbound discarded: 0
        \_ [OK] #1 packets outbound errors: 0
        \_ [OK] #1 packets received discarded: 0
        \_ [OK] #1 packets received errors: 0
        \_ [OK] #1 packets received/sec: 6.467305
        \_ [OK] #1 packets sent/sec: 1.659066
        \_ [OK] #1 VlanID:
    | '1_packets_outbound_discarded'=0;; '1_packets_receivedsec'=6.467305;; '1_bytes_receivedsec'=3691.900146B;; '1_packets_received_errors'=0;; '1_packets_sentsec'=1.659066;; '1_bytes_sentsec'=324.831177B;; '1_packets_received_discarded'=0;; '1_packets_outbound_errors'=0;; '1_bytes_totalsec'=3994.609619B;;
    0
.LINK
    https://github.com/Icinga/icinga-powershell-framework
    https://github.com/Icinga/icinga-powershell-plugins
    https://icinga.com/docs/windows/latest/doc/01-Introduction/
#>

function Invoke-IcingaCheckNetworkInterface()
{
    param (
        [array]$IncludeNetworkDevice  = @(),
        [array]$ExcludeNetworkDevice  = @(),
        [array]$ExcludeInterfaceTeam  = @(),
        [array]$IncludeInterfaceTeam  = @(),
        $PacketReceivedSecWarn        = $null,
        $PacketReceivedSecCrit        = $null,
        $PacketSentSecWarn            = $null,
        $PacketSentSecCrit            = $null,
        $PackteReceivedErrorWarn      = $null,
        $PackteReceivedErrorCrit      = $null,
        $PackteOutboundErrorWarn      = $null,
        $PackteOutboundErrorCrit      = $null,
        $PacketReceivedDiscardedWarn  = $null,
        $PacketReceivedDiscardedCrit  = $null,
        $PacketOutboundDiscardedWarn  = $null,
        $PacketOutboundDiscardedCrit  = $null,
        $DeviceTotalBytesSecWarn      = $null,
        $DeviceTotalBytesSecCrit      = $null,
        $DeviceSentBytesSecWarn       = $null,
        $DeviceSentBytesSecCrit       = $null,
        $DeviceReceivedBytesSecWarn   = $null,
        $DeviceReceivedBytesSecCrit   = $null,
        $LinkSpeedWarn,
        $LinkSpeedCrit,
        [ValidateSet('Up', 'Down', 'Degraded')]
        $IfTeamStatusWarn,
        [ValidateSet('Up', 'Down', 'Degraded')]
        $IfTeamStatusCrit,
        [ValidateSet('Unknown', 'Other', 'Enabled', 'Disabled', 'ShuttingDown', 'NotApplicable', 'EnabledButOffline', 'InTest', 'Deferred', 'Quiesce', 'Starting')]
        $IfSlaveEnabledStateWarn,
        [ValidateSet('Unknown', 'Other', 'Enabled', 'Disabled', 'ShuttingDown', 'NotApplicable', 'EnabledButOffline', 'InTest', 'Deferred', 'Quiesce', 'Starting')]
        $IfSlaveEnabledStateCrit,
        [ValidateSet('Up', 'Down', 'Testing')]
        $IfAdminStatusWarn,
        [ValidateSet('Up', 'Down', 'Testing', 'Unknown', 'Dormant', 'NotPresent', 'LowerLayerDown')]
        $IfOperationalStatusWarn,
        [ValidateSet('Up', 'Down', 'Testing', 'Unknown', 'Dormant', 'NotPresent', 'LowerLayerDown')]
        $IfOperationalStatusCrit,
        [ValidateSet('Disconnected', 'Connecting', 'Connected', 'Disconnecting', 'HardwareNotPresent', 'HardwareDisabled', 'HardwareMalfunction', 'MediaDisconnected', 'Authenticating', 'AuthenticationSucceeded', 'AuthenticationFailed', 'InvalidAddress', 'CredentialsRequired', 'Other')]
        $IfConnectionStatusWarn,
        [ValidateSet('Disconnected', 'Connecting', 'Connected', 'Disconnecting', 'HardwareNotPresent', 'HardwareDisabled', 'HardwareMalfunction', 'MediaDisconnected', 'Authenticating', 'AuthenticationSucceeded', 'AuthenticationFailed', 'InvalidAddress', 'CredentialsRequired', 'Other')]
        $IfConnectionStatusCrit,
        [switch]$IncludeHidden        = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                    = 0
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
        -IncludeHiddenNetworkDevice:$IncludeHidden;

    $CheckPackage          = New-IcingaCheckPackage -Name 'Network Device Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
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
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetsreceivedsec'
            ).WarnOutOfRange(
                $PacketReceivedSecWarn
            ).CritOutOfRange(
                $PacketReceivedSecCrit
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets sent/sec', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets sent/sec'].value `
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetssentsec'
            ).WarnOutOfRange(
                $PacketSentSecWarn
            ).CritOutOfRange(
                $PacketSentSecCrit
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets received errors', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets received errors'].value `
                    -BaseValue $NetworkDeviceObject.PerfCounter['packets received/sec'].value `
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetsreceivederrors'
            ).WarnOutOfRange(
                $PackteReceivedErrorWarn
            ).CritOutOfRange(
                $PackteReceivedErrorCrit
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets outbound errors', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets outbound errors'].value `
                    -BaseValue $NetworkDeviceObject.PerfCounter['packets sent/sec'].value `
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetsoutbounderrors'
            ).WarnOutOfRange(
                $PackteOutboundErrorWarn
            ).CritOutOfRange(
                $PackteOutboundErrorCrit
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets received discarded', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets received discarded'].value `
                    -BaseValue $NetworkDeviceObject.PerfCounter['packets received/sec'].value `
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetsreceiveddiscarded'
            ).WarnOutOfRange(
                $PacketReceivedDiscardedWarn
            ).CritOutOfRange(
                $PacketReceivedDiscardedCrit
            )
        );

        $NetworkEntryCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: packets outbound discarded', $InterfaceName)) `
                    -Value $NetworkDeviceObject.PerfCounter['packets outbound discarded'].value `
                    -BaseValue $NetworkDeviceObject.PerfCounter['packets sent/sec'].value `
                    -Unit 'c' `
                    -MetricIndex $InterfaceName `
                    -MetricName 'packetsoutbounddiscarded'
            ).WarnOutOfRange(
                $PacketOutboundDiscardedWarn
            ).CritOutOfRange(
                $PacketOutboundDiscardedCrit
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
        $LinkChecks = Get-IcingaNetworkSpeedChecks -Name $InterfaceName -LinkSpeed $NetworkDeviceObject.Data.TransmitLinkSpeed -LinkSpeedWarning $LinkSpeedWarn -LinkSpeedCritical $LinkSpeedCrit;
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
                    $ProviderEnums.InterfaceTeamStatusName[[string]$IfTeamStatusWarn]
                ).CritIfMatch(
                    $ProviderEnums.InterfaceTeamStatusName[[string]$IfTeamStatusCrit]
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
                        $ProviderEnums.SlaveEnabledStateName[[string]$IfSlaveEnabledStateWarn]
                    ).CritIfMatch(
                        $ProviderEnums.SlaveEnabledStateName[[string]$IfSlaveEnabledStateCrit]
                    )
                );

                # Add the checks for our interface link speed and performance metrics
                $LinkChecks = Get-IcingaNetworkSpeedChecks -Name $TeamMember.Name -LinkSpeed $TeamMember.TransmitLinkSpeed -LinkSpeedWarning $LinkSpeedWarn -LinkSpeedCritical $LinkSpeedCrit;
                $TeamMemberPackage.AddCheck($LinkChecks.CheckLinkSpeed);
                $HiddenCheckPackage.AddCheck($LinkChecks.PerfDataLinkSpeed);

                $CheckPackage.AddCheck($TeamMemberPackage);

                $NetworkEntryCheckPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0}: bytes total/sec', $InterfaceName)) `
                            -Value $NetworkDeviceObject.PerfCounter['bytes total/sec'].value `
                            -BaseValue $TeamMember.TransmitLinkSpeedBytes `
                            -Unit 'B' `
                            -MetricIndex $InterfaceName `
                            -MetricName 'bytestotalsec'
                    ).WarnOutOfRange(
                        $DeviceTotalBytesSecWarn
                    ).CritOutOfRange(
                        $DeviceTotalBytesSecCrit
                    )
                );

                $NetworkEntryCheckPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0}: bytes sent/sec', $InterfaceName)) `
                            -Value $NetworkDeviceObject.PerfCounter['bytes sent/sec'].value `
                            -BaseValue $TeamMember.TransmitLinkSpeedBytes `
                            -Unit 'B' `
                            -MetricIndex $InterfaceName `
                            -MetricName 'bytessentsec'
                    ).WarnOutOfRange(
                        $DeviceSentBytesSecWarn
                    ).CritOutOfRange(
                        $DeviceSentBytesSecCrit
                    )
                );

                $NetworkEntryCheckPackage.AddCheck(
                    (
                        New-IcingaCheck `
                            -Name ([string]::Format('{0}: bytes received/sec', $InterfaceName)) `
                            -Value $NetworkDeviceObject.PerfCounter['bytes received/sec'].value `
                            -BaseValue $TeamMember.TransmitLinkSpeedBytes `
                            -Unit 'B' `
                            -MetricIndex $InterfaceName `
                            -MetricName 'bytesreceivedsec'
                    ).WarnOutOfRange(
                        $DeviceReceivedBytesSecWarn
                    ).CritOutOfRange(
                        $DeviceReceivedBytesSecCrit
                    )
                );
            }

            $InterfaceTeamsPackage.AddCheck($NetworkEntryCheckPackage);
        } else {
            # All remaining data for regular interfaces not part of a team

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: bytes total/sec', $InterfaceName)) `
                        -Value $NetworkDeviceObject.PerfCounter['bytes total/sec'].value `
                        -BaseValue $NetworkDeviceObject.Data.TransmitLinkSpeedBytes `
                        -Unit 'B' `
                        -MetricIndex $InterfaceName `
                        -MetricName 'bytestotalsec'
                ).WarnOutOfRange(
                    $DeviceTotalBytesSecWarn
                ).CritOutOfRange(
                    $DeviceTotalBytesSecCrit
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: bytes sent/sec', $InterfaceName)) `
                        -Value $NetworkDeviceObject.PerfCounter['bytes sent/sec'].value `
                        -BaseValue $NetworkDeviceObject.Data.TransmitLinkSpeedBytes `
                        -Unit 'B' `
                        -MetricIndex $InterfaceName `
                        -MetricName 'bytessentsec'
                ).WarnOutOfRange(
                    $DeviceSentBytesSecWarn
                ).CritOutOfRange(
                    $DeviceSentBytesSecCrit
                )
            );

            $NetworkEntryCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0}: bytes received/sec', $InterfaceName)) `
                        -Value $NetworkDeviceObject.PerfCounter['bytes received/sec'].value `
                        -BaseValue $NetworkDeviceObject.Data.TransmitLinkSpeedBytes `
                        -Unit 'B' `
                        -MetricIndex $InterfaceName `
                        -MetricName 'bytesreceivedsec'
                ).WarnOutOfRange(
                    $DeviceReceivedBytesSecWarn
                ).CritOutOfRange(
                    $DeviceReceivedBytesSecCrit
                )
            );

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
                    $ProviderEnums.InterfaceAdminStatusName[[string]$IfAdminStatusWarn]
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
                    $ProviderEnums.InterfaceOperationalStatusName[[string]$IfOperationalStatusWarn]
                ).CritIfMatch(
                    $ProviderEnums.InterfaceOperationalStatusName[[string]$IfOperationalStatusCrit]
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
                    $ProviderEnums.NetConnectionStatusName[[string]$IfConnectionStatusWarn]
                ).CritIfMatch(
                    $ProviderEnums.NetConnectionStatusName[[string]$IfConnectionStatusCrit]
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
