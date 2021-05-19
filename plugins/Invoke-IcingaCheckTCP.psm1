<#
.SYNOPSIS
    Checks the connection for an address and a range of ports and fetches the connection status
    including the time require to connect.
.DESCRIPTION
    Invoke-IcingaCheckTCP connects to a provided address and a single or a range of ports and determines if the
    connection was successful or not. In addition the time for a successful connection is measured.

    By default the plugin will return [CRITICAL] if the connection is not possible, can how ever be changed by the
    `-Negate` argument which will return [CRITICAL] if the connection is possible.

    In addition you can measure the connection time and alert by using `-Warning` or `-Critical`.
.PARAMETER Address
    The IP address or FQDN of the target host
.PARAMETER Ports
    A single or a list of ports to check on the target address
.PARAMETER Negate
    By default the plugin will return [CRITICAL] in case connections to a port are not possible. By setting this argument,
    the plugin will return [CRITICAL] for successful connections instead
.PARAMETER Warning
    A warning threshold for the connection time in seconds. Allows the usage of unit additions, like 100ms.

    Allowed units: ms, s, m, h, d, w, M, y
.PARAMETER Critical
    A critical threshold for the connection time in seconds. Allows the usage of unit additions, like 100ms.

    Allowed units: ms, s, m, h, d, w, M, y
.PARAMETER NoPerfData
    Disables the performance data output of this plugin. Default to FALSE.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
   Invoke-IcingaCheckTCP -Address 'example.com' -Ports 443, 80, 5665, 3001;

    [CRITICAL] Check package "TCP Connections" - [CRITICAL] example.com:3001 Status
    \_ [CRITICAL] Check package "example.com:3001"
        \_ [CRITICAL] example.com:3001 Status: Value "Not Connected" is not matching threshold "Connected"
    | 'port_80_time'=0.029526s;; 'port_80_status'=1;;1 'port_5665_status'=1;;1 'port_5665_time'=0.012666s;; 'port_3001_status'=0;;1 'port_3001_time'=21.041116s;; 'port_443_time'=0.353218s;; 'port_443_status'=1;;1
.EXAMPLE
    Invoke-IcingaCheckTCP -Address 'example.com' -Ports 443, 80, 5665, 3001 -Negate;

    [CRITICAL] Check package "TCP Connections" - [CRITICAL] example.com:443 Status, example.com:5665 Status, example.com:80 Status
    \_ [CRITICAL] Check package "example.com:443"
        \_ [CRITICAL] example.com:443 Status: Value "Connected" is not matching threshold "Not Connected"
    \_ [CRITICAL] Check package "example.com:5665"
        \_ [CRITICAL] example.com:5665 Status: Value "Connected" is not matching threshold "Not Connected"
    \_ [CRITICAL] Check package "example.com:80"
        \_ [CRITICAL] example.com:80 Status: Value "Connected" is not matching threshold "Not Connected"
    | 'port_80_time'=0.017343s;; 'port_80_status'=1;;0 'port_5665_status'=1;;0 'port_5665_time'=0.013514s;; 'port_3001_status'=0;;0 'port_3001_time'=21.039489s;; 'port_443_time'=0.332817s;; 'port_443_status'=1;;0
.EXAMPLE
    Invoke-IcingaCheckTCP -Address 'example.com' -Ports 443, 80, 5665, 3001 -Warning 100ms -Critical 200ms;

    [CRITICAL] Check package "TCP Connections" - [CRITICAL] example.com:3001 Status, example.com:3001 Time, example.com:443 Time
    \_ [CRITICAL] Check package "example.com:3001"
        \_ [CRITICAL] example.com:3001 Status: Value "Not Connected" is not matching threshold "Connected"
        \_ [CRITICAL] example.com:3001 Time: Value "21.038106s" is greater than threshold "0.2s"
    \_ [CRITICAL] Check package "example.com:443"
        \_ [CRITICAL] example.com:443 Time: Value "0.249976s" is greater than threshold "0.2s"
    | 'port_80_time'=0.017512s;0.1;0.2 'port_80_status'=1;;1 'port_5665_status'=1;;1 'port_5665_time'=0.013497s;0.1;0.2 'port_3001_status'=0;;1 'port_3001_time'=21.038106s;0.1;0.2 'port_443_time'=0.249976s;0.1;0.2 'port_443_status'=1;;1
.LINK
    https://github.com/Icinga/icinga-powershell-framework
    https://github.com/Icinga/icinga-powershell-plugins
#>

function Invoke-IcingaCheckTCP()
{
    param (
        [string]$Address       = '',
        [array]$Ports          = @(),
        [switch]$Negate        = $FALSE,
        $Warning               = $null,
        $Critical              = $null,
        [switch]$NoPerfData    = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity             = 0
    );

    $ConnectionData = Measure-IcingaTCPConnection -Address $Address -Ports $Ports;
    $CheckPackage   = New-IcingaCheckPackage -Name 'TCP Connections' -OperatorAnd -Verbose $Verbosity;

    foreach ($port in $ConnectionData.Keys) {

        $ConnectionValue   = $ConnectionData[$port];
        $ConnectionPackage = New-IcingaCheckPackage -Name ([string]::Format('{0}:{1}', $Address, $port)) -OperatorAnd -Verbose $Verbosity;

        $ConnectionCheck = New-IcingaCheck `
            -Name ([string]::Format('{0}:{1} Status', $Address, $port)) `
            -Value $ConnectionValue.Success `
            -Translation @{ 'False' = 'Not Connected'; 'True' = 'Connected' } `
            -LabelName ([string]::Format('port_{0}_status', $port));

        if ($Negate -eq $FALSE) {
            $ConnectionCheck.CritIfNotMatch($TRUE) | Out-Null;
        } else {
            $ConnectionCheck.CritIfNotMatch($FALSE) | Out-Null;
        }

        $ConnectionTimeCheck = New-IcingaCheck `
            -Name ([string]::Format('{0}:{1} Time', $Address, $port)) `
            -Value $ConnectionValue.Time `
            -Unit 's' `
            -LabelName ([string]::Format('port_{0}_time', $port));

        $ConnectionTimeCheck.WarnOutOfRange($Warning.Value).CritOutOfRange($Critical.Value) | Out-Null;

        $ConnectionPackage.AddCheck($ConnectionCheck);
        $ConnectionPackage.AddCheck($ConnectionTimeCheck);

        $CheckPackage.AddCheck($ConnectionPackage);
    }

    return (New-IcingaCheckResult -Name 'TCP Connection' -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
