function Get-IcingaNetworkInterfaceTeamInfo ()
{
    $GetTeamMembers = Get-IcingaWindowsInformation -ClassName MSFT_NetLbfoTeamMember -NameSpace 'root\StandardCimv2';
    $GetDeviceTeams = Get-IcingaWindowsInformation -ClassName MSFT_NetImPlatAdapter -NameSpace 'root\StandardCimv2';
    $NetLbfoTeam    = Get-IcingaWindowsInformation -ClassName MSFT_NetLbfoTeam -NameSpace 'root\StandardCimv2';
    $DeviceTeamData = @{ };

    foreach ($item in $NetLbfoTeam) {
        $Team_details = @{
            'Slave'                  = @{};
            'Members'                = @();
            'LacpTimer'              = $item.LacpTimer;
            'LoadBalancingAlgorithm' = $item.LoadBalancingAlgorithm;
            'TeamingMode'            = $item.TeamingMode;
            'Status'                 = $item.Status;
            'Name'                   = $item.Name;
        };

        foreach ($team in $GetDeviceTeams) {
            if ($team.Name -eq $item.Name) {
                $Team_details.Add('Caption', $team.Caption);
                $Team_details.Add('Description', $team.Description);
                $Team_details.Add('ElementName', $team.ElementName);
                $Team_details.Add('InstanceID', $team.InstanceID);
                $Team_details.Add('CommunicationStatus', $team.CommunicationStatus);
                $Team_details.Add('DetailedStatus', $team.DetailedStatus);
                $Team_details.Add('HealthStatus', $team.HealthStatus);
                $Team_details.Add('InstallDate', $team.InstallDate);
                $Team_details.Add('OperatingStatus', $team.OperatingStatus);
                $Team_details.Add('PrimaryStatus', $team.PrimaryStatus);
                $Team_details.Add('OperationalStatus', $team.OperationalStatus);
                $Team_details.Add('AvailableRequestedStates', $team.AvailableRequestedStates);
                $Team_details.Add('EnabledDefault', $team.EnabledDefault);
                $Team_details.Add('EnabledState', $team.EnabledState);
                $Team_details.Add('OtherEnabledState', $team.OtherEnabledState);
                $Team_details.Add('RequestedState', $team.RequestedState);
                $Team_details.Add('TimeOfLastStateChange', $team.TimeOfLastStateChange);
                $Team_details.Add('TransitioningToState', $team.TransitioningToState);
                $Team_details.Add('FailureReason', $team.FailureReason);
                $Team_details.Add('InterfaceDescription', $team.InterfaceDescription);
                $Team_details.Add('NumberOfFailures', $team.NumberOfFailures);
                $Team_details.Add('ReceiveLinkSpeed', $team.ReceiveLinkSpeed);
                $Team_details.Add('Team', $team.Team);
                $Team_details.Add('TransmitLinkSpeed', $team.TransmitLinkSpeed);
                $Team_details.Add('TransmitLinkSpeedBytes', ($team.TransmitLinkSpeed / 8));
                $Team_details.Add('Default', $team.Default);
                $Team_details.Add('Primary', $team.Primary);
                $Team_details.Add('VlanID', $team.VlanID);
                $Team_details.Add('PSComputerName', $team.PSComputerName);

                break;
            }
        }

        foreach ($team_member in $GetTeamMembers) {
            if (($item.Name -eq $team_member.Team) -And $item.Name -ne $team_member.Name) {
                $Team_details.Members += $team_member.Name;
                $Team_details.Slave.Add(
                    $team_member.Name, @{
                        'Caption'                  = $team_member.Caption;
                        'Description'              = $team_member.Description;
                        'ElementName'              = $team_member.ElementName
                        'InstanceID'               = $team_member.InstanceID;
                        'CommunicationStatus'      = $team_member.CommunicationStatus;
                        'DetailedStatus'           = $team_member.DetailedStatus;
                        'HealthStatus'             = $team_member.HealthStatus;
                        'InstallDate'              = $team_member.InstallDate;
                        'Name'                     = $team_member.Name;
                        'OperatingStatus'          = $team_member.OperatingStatus;
                        'PrimaryStatus'            = $team_member.PrimaryStatus;
                        'OperationalStatus'        = $team_member.OperationalStatus;
                        'Status'                   = $team_member.Status;
                        'StatusDescriptions'       = $team_member.StatusDescriptions;
                        'AvailableRequestedStates' = $team_member.AvailableRequestedStates;
                        'EnabledDefault'           = $team_member.EnabledDefault;
                        'EnabledState'             = $team_member.EnabledState;
                        'OtherEnabledState'        = $team_member.OtherEnabledState;
                        'RequestedState'           = $team_member.RequestedState;
                        'TimeOfLastStateChange'    = $team_member.TimeOfLastStateChange;
                        'TransitioningToState'     = $team_member.TransitioningToState;
                        'FailureReason'            = $team_member.FailureReason;
                        'InterfaceDescription'     = $team_member.InterfaceDescription;
                        'NumberOfFailures'         = $team_member.NumberOfFailures;
                        'ReceiveLinkSpeed'         = $team_member.ReceiveLinkSpeed;
                        'Team'                     = $team_member.Team;
                        'TransmitLinkSpeed'        = $team_member.TransmitLinkSpeed;
                        'TransmitLinkSpeedBytes'   = ($team_member.TransmitLinkSpeed / 8);
                        'Default'                  = $team_member.Default;
                        'Primary'                  = $team_member.Primary;
                        'VlanID'                   = $team_member.VlanID;
                        'AdministrativeMode'       = $team_member.AdministrativeMode;
                        'OperationalMode'          = $team_member.OperationalMode;
                        'PSComputerName'           = $team_member.PSComputerName;
                    }
                );
            }
        }

        $DeviceTeamData.Add($item.Name, $Team_details);
    }

    return $DeviceTeamData;
}
