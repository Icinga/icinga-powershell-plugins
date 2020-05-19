<#
.SYNOPSIS
   Checks via ICMP requests to a target destination for response time and availability
.DESCRIPTION
   Invoke-IcingaCheckICMP returns 'OK', 'WARNING' or 'CRITICAL' depending on response times
   for packet transmition and possible packet loss

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This plugin will check for connections via ICMP requests to check if a target destination is available and the response time.
   Based on thresholds the plugin will return either 'OK', 'WARNING' or 'CRITICAL'
.EXAMPLE
   PS> Invoke-IcingaCheckICMP -Hostname 'example.com';
   [OK] Check package "ICMP Check for example.com"
   | 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113ms;;
.EXAMPLE
   PS> Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv4;
   [OK] Check package "ICMP Check for example.com"
   | 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113ms;;
.EXAMPLE
   PS> Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv6;
   [OK] Check package "ICMP Check for example.com"
   | 'packet_loss'=0%;;;0;100 'packet_count'=4c;; 'response_time'=113.5ms;;
.EXAMPLE
   PS> Invoke-IcingaCheckICMP -Hostname 'example.com' -IPv4 -Warning 80 -Critical 100 -WarningPl 50 -CriticalPl 75;
   [CRITICAL] Check package "ICMP Check for example.com" - [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes
   \_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "114ms" is greater than threshold "100ms"
   \_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
   \_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
   \_ [CRITICAL] ICMP request to 93.184.216.34 with 1024 bytes: Value "113ms" is greater than threshold "100ms"
   | 'packet_loss'=0%;50;75;0;100 'packet_count'=4c;; 'response_time'=113.25ms;80;100
.PARAMETER Warning
   Treshold on which the plugin will return 'WARNING' for the response time in ms
.PARAMETER Critical
   Treshold on which the plugin will return 'CRITICAL' for the response time in ms
.PARAMETER WarningPl
   Treshold on which the plugin will return 'WARNING' for possible packet loss in %
.PARAMETER CriticalPl
   Treshold on which the plugin will return 'CRITICAL' for possible packet loss in %
.PARAMETER Hostname
   The target hosts IP or FQDN to send ICMP requests too
.PARAMETER PacketCount
   The amount of packets send to the target host
.PARAMETER PacketSize
   The size of each packet send to the target host
.PARAMETER IPv4
   Force the usage of IPv4 addresses for ICMP calls by using a hostname
.PARAMETER IPv6
   Force the usage of IPv6 addresses for ICMP calls by using a hostname
.PARAMETER NoPerfData
   Set this argument to not write any performance data
.PARAMETER Verbosity
   Increase the printed output message by adding additional details or print all data regardless of their status
.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckICMP()
{
    param (
        $Warning            = 100,
        $Critical           = 200,
        $WarningPl          = 20,
        $CriticalPl         = 50,
        [string]$Hostname,
        [int]$PacketCount   = 5,
        [int]$PacketSize    = 64,
        [switch]$IPv4       = $FALSE,
        [switch]$IPv6       = $FALSE,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity     = 0
    );

    $Result      = Test-IcingaICMPConnection -Hostname $Hostname -PacketCount $PacketCount -PacketSize $PacketSize -IPv4 $IPv4 -IPv6 $IPv6;
    $ICMPPackage = New-IcingaCheckPackage -Name ([string]::Format('ICMP Check for {0}', $Hostname)) -OperatorAnd -Verbose $Verbosity;

    foreach ($entry in $Result.Results.Values) {
        $ICMPError = $entry.Error;
        $ICMPValue = $entry.Value;
        $ICMPCheck = $null;

        if (-Not $ICMPError) {
            $ICMPCheck = New-IcingaCheck -Name ([string]::Format('ICMP request to {0} with {1} bytes', $Result.Summary.IPAddress, $PacketSize)) -Value $ICMPValue.ResponseTime -Unit 'ms' -NoPerfData;
            $ICMPCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        } else {
            $ICMPCheck = New-IcingaCheck -Name ([string]::Format('Error during request: {0}', $ICMPValue)) -NoPerfData;
            $ICMPCheck.SetCritical();
        }
        $ICMPPackage.AddCheck($ICMPCheck);
    }

    $PacketLoss = New-IcingaCheck -Name 'Packet Loss' -Value $Result.Summary.PacketLoss -Unit '%';
    $PacketLoss.WarnOutOfRange($WarningPl).CritOutOfRange($CriticalPl) | Out-Null;

    $ICMPPackage.AddCheck($PacketLoss);

    $ResponseTime = New-IcingaCheck -Name 'Response Time' -Value $Result.Summary.ResponseTime -Unit 'ms';
    $ResponseTime.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    $PerfDataPackage = New-IcingaCheckPackage -Name 'PerfData' -OperatorAnd -Verbose $Verbosity -Hidden -Checks @(
        $ResponseTime,
        (New-IcingaCheck -Name 'Packet Count' -Value $Result.Summary.PacketsSend -Unit 'c')
    );
    $ICMPPackage.AddCheck($PerfDataPackage);

    return (New-IcingaCheckResult -Check $ICMPPackage -NoPerfData $NoPerfData -Compile);
}
