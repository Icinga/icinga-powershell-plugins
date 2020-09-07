function Invoke-IcingaCheckClusterNode()
{
    param(
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity          = 0
    );

    $CheckPackage    = New-IcingaCheckPackage -Name 'Cluster Nodes Package' -OperatorAnd -Verbose $Verbosity;
    $GetClusterNodes = Get-IcingaClusterNodeInfo;

    foreach ($node in $GetClusterNodes.Keys) {
        $ClusterNode      = $GetClusterNodes[$node];
        $NodeCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('Node {0}', $ClusterNode.Name)) -OperatorAnd -Verbose $Verbosity;
        $NodeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('#{0} StatusInformation', $node)) `
                    -Value $ClusterNode.StatusInformation `
                    -Translation $ProviderEnums.ClusterNodeStatusInfo
            )
        );

        [array]$ClusterNodeDedicated = $ClusterNode.Dedicated.Values;
        $NodeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('#{0} Dedicated', $node)) `
                    -Value ([string]::Join(',', $ClusterNodeDedicated))
            ).WarnIfMatch(
                $ProviderEnums.ClusterNodeDedicatedName.Unknown
            ).CritIfMatch(
                $ProviderEnums.ClusterNodeDedicatedName.'Not Dedicated'
            )
        );

        $NodeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('#{0} NodeDrainStatus', $node)) `
                    -Value $ClusterNode.NodeDrainStatus `
                    -Translation $ProviderEnums.NodeDrainStatus
            ).CritIfMatch(
                $ProviderEnums.NodeDrainStatusName.Failed
            )
        );

        $NodeCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('#{0} State', $node)) `
                    -Value $ClusterNode.State `
                    -Translation $ProviderEnums.ClusterNodeState `
                    -NoPerfData
            ).WarnIfMatch(
                $ProviderEnums.ClusterNodeStateName.Unknown
            ).CritIfMatch(
                $ProviderEnums.ClusterNodeStateName.Down
            ).CritIfMatch(
                $ProviderEnums.ClusterNodeStateName.Paused
            )
        );

        $CheckPackage.AddCheck($NodeCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
