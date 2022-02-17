function Measure-IcingaTCPConnection()
{
    param (
        [string]$Address = '',
        [array]$Ports    = @()
    );

    if ([string]::IsNullOrEmpty($Address) -Or $Ports.Count -eq 0) {
        Exit-IcingaThrowException -ExceptionType 'Configuration' `
            -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing `
            -CustomMessage 'Plugin argument "-Address" and/or "-Ports" is empty' `
            -Force;
    }

    [hashtable]$Result = @{ };

    foreach ($port in $Ports) {
        Start-IcingaTimer -Name ([string]::Format('TCPConnection:{0}', $port));
        [bool]$Success = $FALSE;

        try {
            $TcpConnection = New-Object System.Net.Sockets.TcpClient($Address, $port);
            $TcpConnection.Close();
            $TcpConnection.Dispose();
            $Success = $TRUE;
        } catch {
            # Do nothing
        }

        Stop-IcingaTimer -Name ([string]::Format('TCPConnection:{0}', $port));

        $ConnectionTime = Get-IcingaTimer -Name ([string]::Format('TCPConnection:{0}', $port));

        if ($Result.ContainsKey([string]$port) -eq $FALSE) {
            $Result.Add(
                [string]$port,
                @{
                    'Success' = $Success;
                    'Time'    = $ConnectionTime.Elapsed.TotalSeconds;
                }
            );
        }
    }

    return $Result;
}
