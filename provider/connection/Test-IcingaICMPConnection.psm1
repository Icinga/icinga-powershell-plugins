<#
.SYNOPSIS
   Tests the availability and response times for a given hostname or IP address
.DESCRIPTION
   Returns a hashtable with connection availability and response times including
   pre-calculated averages for packet loss and response times

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This function will connect to a target destination and send ICMP requests to it.
   It will measure the response times and possible packet loss and calucate the average
   to return all summaries as hashtable afterwards
.EXAMPLE
   PS> Test-IcingaICMPConnection -Hostname 'example.com';
.EXAMPLE
   PS> Test-IcingaICMPConnection -Hostname 'example.com' -PacketCount 10 -PacketSize 512;
.EXAMPLE
   PS> Test-IcingaICMPConnection -Hostname 'example.com' -IPv4 -PacketCount 10 -PacketSize 512;
.EXAMPLE
   PS> Test-IcingaICMPConnection -Hostname 'example.com' -IPv6 -PacketCount 10 -PacketSize 512;
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
.OUTPUTS
   System.Hashtable

.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Test-IcingaICMPConnection()
{
    param (
        [string]$Hostname,
        [int]$PacketCount = 5,
        [int]$PacketSize  = 64,
        [bool]$IPv4       = $FALSE,
        [bool]$IPv6       = $FALSE
    );

    # Always test 1 packet alteast
    if ($PacketCount -le 0) {
        $PacketCount = 1;
    }

    # Handle invalid plugin configuration
    if ($IPv4 -And $IPv6) {
        Exit-IcingaThrowException -ExceptionType 'Configuration' -CustomMessage $Counter -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentConflict -Force;
    }

    $CheckAddress = $null;

    # Force IPv4 if nothing is specified
    if (-Not $IPv4 -And -Not $IPv6) {
        $IPv4 = $TRUE;
    }

    try {
        # Throw error if no hostname is specified
        if ([string]::IsNullOrEmpty($Hostname)) {
            throw 'Please enter a valid hostname or IP address';
        }
        # Lookup the possible IP addresses for a certain host
        $IPAddresses = [System.Net.Dns]::GetHostAddresses($Hostname);
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'DNSResolveError' -InputString ([string]::Format('The specified hostname or IP address "{0}" could not be resolved.', $Hostname)) -Force;
    }

    # Loop all returned addresses and pick the first IPv4/IPv6 address depending on our configuration
    foreach ($address in $IPAddresses) {
        if ($address.AddressFamily -eq 'InterNetwork' -And $IPv4) {
            $CheckAddress = $address.IPAddressToString;
            break;
        } elseif ($address.AddressFamily -eq 'InterNetworkV6' -And $IPv6) {
            $CheckAddress = $address.IPAddressToString;
            break;
        }
    }

    # Check if we have a IP address picked, if non was avaialble for our configuration throw an error
    if ($null -eq $CheckAddress) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'ICMPConfigurationError' -InputString (
            [string]::Format('Your specified ICMP configuration (IPv4/IPv6) could not be applied for "{0}", as no IP for the specified protocol was found.', $Hostname)
        ) -Force;
    }

    [int]$PacketsLost      = 0;
    [int]$PacketsSend      = 0;
    [int]$ResponseTime     = 0;
    [single]$PacketLoss    = 0;
    [hashtable]$ICMPResult = @{};
    [hashtable]$ICMPResult = @{};

    # To catch possible errors properly, only do one attempt each and loop for the amount of requests we wish to send
    while ($PacketCount -gt 0) {
        $PacketsSend++;
        try {
            $ICMP          = (Test-Connection -ComputerName $CheckAddress -BufferSize $PacketSize -Count 1 -ErrorAction Stop);
            $ResponseTime += $ICMP.ResponseTime;
            Add-IcingaHashtableItem -Hashtable $ICMPResult -Key $PacketCount -Value @{
                'Value' = $ICMP;
                'Error' = $FALSE;
            } | Out-Null;
        } catch {
            Add-IcingaHashtableItem -Hashtable $ICMPResult -Key $PacketCount -Value @{
                'Value' = $_.CategoryInfo.Category;
                'Error' = $TRUE;
            } | Out-Null;
            $PacketsLost++;
        }
        $PacketCount--;
    }

    $PacketLoss = $PacketsLost / $PacketsSend * 100;

    return @{
        'Results' = $ICMPResult;
        'Summary' = @{
            'PacketsSend'  = $PacketsSend;
            'PacketLoss'   = $PacketLoss;
            'ResponseTime' = ($ResponseTime / $PacketsSend);
            'IPAddress'    = $CheckAddress;
        };
    };
}
