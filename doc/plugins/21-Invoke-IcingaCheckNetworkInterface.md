
# Invoke-IcingaCheckNetworkInterface

## Description

Checks availability, state and Usage of Network interfaces and Interface Teams

This plugin checks availability, status and load of a network adapter. It is also
equipped with various parameters, so you have the possibility to decide almost
everything by yourself, when the single checks have to be Warning or Critical. For the
Team-Members Physical adapters no Performance Counter are displayed.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* root\Cimv2
* root\StandardCimv2

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeNetworkDevice | Array | false | @() | Specify the index id, interface name or connection name of network adapters you want to include for checks. Example 4, 3, *LAN*, *Ethernet* |
| ExcludeNetworkDevice | Array | false | @() | Specify the index id, interface name or connection name of network adapters you want to exclude for checks. Example 4, 3, *LAN*, *Ethernet* |
| ExcludeInterfaceTeam | Array | false | @() | Specify the name of network interface teams you want to exclude for checks. Example OutboundGroup, ClusterInterface |
| IncludeInterfaceTeam | Array | false | @() | Specify the name of network interface teams you want to include for checks. Example OutboundGroup, ClusterInterface |
| PacketReceivedSecWarn | Object | false |  | Warning threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface. |
| PacketReceivedSecCrit | Object | false |  | Critical threshold for network Interface Packets Received/sec is the rate at which packets are received on the network interface. |
| PacketSentSecWarn | Object | false |  | Warning threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface. |
| PacketSentSecCrit | Object | false |  | Critical threshold for network Interface Packets Sent/sec is the rate at which packets are sent on the network interface. |
| PackteReceivedErrorWarn | Object | false |  | Warning threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing them from being deliverable to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PackteReceivedErrorCrit | Object | false |  | Critical threshold for network Interface Packets Received Errors is the number of inbound packets that contained errors preventing them from being deliverable to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PackteOutboundErrorWarn | Object | false |  | Warning threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted because of errors. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PackteOutboundErrorCrit | Object | false |  | Critical threshold for network Interface Packets Outbound Errors is the number of outbound packets that could not be transmitted because of errors. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PacketReceivedDiscardedWarn | Object | false |  | Warning threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded even though no errors had been detected to prevent their delivery to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PacketReceivedDiscardedCrit | Object | false |  | Critical threshold for network Interface Packets Received Discarded is the number of inbound packets that were chosen to be discarded even though no errors had been detected to prevent their delivery to a higher-layer protocol. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PacketOutboundDiscardedWarn | Object | false |  | Warning threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded even though no errors had been detected to prevent transmission. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| PacketOutboundDiscardedCrit | Object | false |  | Critical threshold for network Interface Packets Outbound Discarded is the number of outbound packets that were chosen to be discarded even though no errors had been detected to prevent transmission. It is possible to enter e.g. 10% as threshold value if you want a percentage comparison. Default (c) |
| DeviceTotalBytesSecWarn | Object | false |  | Warning threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| DeviceTotalBytesSecCrit | Object | false |  | Critical threshold for network Interface Bytes Total/sec is the rate at which bytes are sent and received over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| DeviceSentBytesSecWarn | Object | false |  | Warning threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| DeviceSentBytesSecCrit | Object | false |  | Critical threshold for network Interface Bytes Sent/sec is the rate at which bytes are sent over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| DeviceReceivedBytesSecWarn | Object | false |  | Warning threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| DeviceReceivedBytesSecCrit | Object | false |  | Critical threshold for network Interface Bytes Received/sec is the rate at which bytes are received over each network adapter, including framing characters. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| LinkSpeedWarn | Object | false |  | Warning threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface. |
| LinkSpeedCrit | Object | false |  | Critical threshold for the transmit link speed in (10 MBit, 100 MBit, 1 GBit, 10 GBit, 100 GBit, ...) of the network Interface. |
| IfTeamStatusWarn | Object | false |  | Warning threshold for the Status of a network Interface Teams. |
| IfTeamStatusCrit | Object | false |  | Critical threshold for the Status of a network Interface Teams. |
| IfSlaveEnabledStateWarn | Object | false |  | Warning threshold for the State of a network Interface Team-Members/Slaves. |
| IfSlaveEnabledStateCrit | Object | false |  | Critical threshold for the State of a network Interface Team-Members/Slaves. |
| IfAdminStatusWarn | Object | false |  | Warning threshold for the network Interface administrative status. |
| IfOperationalStatusWarn | Object | false |  | Warning threshold for the current network interface operational status. |
| IfOperationalStatusCrit | Object | false |  | Critical threshold for the current network interface operational status. |
| IfConnectionStatusWarn | Object | false |  | Warning threshold for the state of the network adapter connection to the network. |
| IfConnectionStatusCrit | Object | false |  | Critical threshold for the state of the network adapter connection to the network. |
| IncludeHidden | SwitchParameter | false | False | Set this argument if you want to include hidden network Adapter for checks. It is a network which is available but is not broadcasting its ID. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckNetworkInterface  -Verbosity 2  }
```

### Example Output 1

```powershell
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
```
