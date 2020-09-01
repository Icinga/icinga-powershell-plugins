function Get-IcingaClusterNodeInfo()
{
    param(

    );

    $ClusterNodes    = Get-IcingaWindowsInformation -ClassName MSCluster_Node -NameSpace 'Root\MSCluster';
    $ClusterNodeData = @{ };

    foreach ($node in $ClusterNodes) {
        $NodeDetails = @{
            'Caption'                     = $node.Caption;
            'CreationClassName'           = $node.CreationClassName;
            'InitialLoadInfo'             = $null;
            'InstallDate'                 = $node.InstallDate;
            'LastLoadInfo'                = $node.LastLoadInfo;
            'Name'                        = $node.Name;
            'NameFormat'                  = $node.NameFormat;
            'OtherIdentifyingInfo'        = $null;
            'IdentifyingDescriptions'     = $null;
            'Dedicated'                   = $null;
            'PowerManagementCapabilities' = $null;
            'PowerState'                  = $node.PowerState;
            'PrimaryOwnerContact'         = $node.PrimaryOwnerContact;
            'PrimaryOwnerName'            = $node.PrimaryOwnerName;
            'ResetCapability'             = $node.ResetCapability;
            'Roles'                       = $null;
            'Status'                      = $node.Status;
            'Description'                 = $node.Description;
            'NodeWeight'                  = $node.NodeWeight;
            'DynamicWeight'               = $node.DynamicWeight;
            'NodeHighestVersion'          = $node.NodeHighestVersion;
            'NodeLowestVersion'           = $node.NodeLowestVersion;
            'MajorVersion'                = $node.MajorVersion;
            'MinorVersion'                = $node.MinorVersion;
            'BuildNumber'                 = $node.BuildNumber;
            'CSDVersion'                  = $node.CSDVersion;
            'Id'                          = $node.Id;
            'NodeInstanceID'              = $node.NodeInstanceID;
            'NodeDrainStatus'             = $node.NodeDrainStatus;
            'NodeDrainTarget'             = $node.NodeDrainTarget;
            'State'                       = $node.State;
            'Flags'                       = $node.Flags;
            'Characteristics'             = $node.Characteristics;
            'NeedsPreventQuorum'          = $node.NeedsPreventQuorum;
            'FaultDomainId'               = $node.FaultDomainId;
            'StatusInformation'           = $node.StatusInformation;
            'FaultDomain'                 = $null;
            'PrivateProperties'           = $node.PrivateProperties;
        };

        if ($null -ne $node.OtherIdentifyingInfo) {
            $OtherIdentifyingInfo = @{ };
            foreach ($item in $node.OtherIdentifyingInfo) {
                Add-IcingaHashtableItem -Hashtable $OtherIdentifyingInfo -Key ([string]$item) -Value ([string]$item) | Out-Null;
            }

            $NodeDetails.OtherIdentifyingInfo = $OtherIdentifyingInfo;
        } else {
            $NodeDetails.OtherIdentifyingInfo = @{ 'Unknown' = 'Unknown'; }
        }

        if ($null -ne $node.IdentifyingDescriptions) {
            $IdentifyingDescriptions = @{ };
            foreach ($desc in $node.IdentifyingDescriptions) {
                Add-IcingaHashtableItem -Hashtable $IdentifyingDescriptions -Key ([string]$desc) -Value ([string]$desc) | Out-Null;
            }

            $NodeDetails.IdentifyingDescriptions = $IdentifyingDescriptions;
        } else {
            $NodeDetails.IdentifyingDescriptions = @{ 'Unknown' = 'Unknown'; }
        }

        if ($null -ne $node.Dedicated) {
            $Dedicated = @{ };
            foreach ($key in $node.Dedicated) {
                Add-IcingaHashtableItem -Hashtable $Dedicated -Key ([int]$key) -Value ($ProviderEnums.ClusterNodeDedicated[[int]$key]) | Out-Null;
            }

            $NodeDetails.Dedicated = $Dedicated;
        } else {
            $NodeDetails.Dedicated = @{ 1 = 'Unknown'; }
        }

        if ($null -ne $node.PowerManagementCapabilities) {
            $PowerManagementCapabilities = @{ };
            foreach ($capability in $node.PowerManagementCapabilities) {
                Add-IcingaHashtableItem -Hashtable $PowerManagementCapabilities -Key ([int]$capability) -Value ($ProviderEnums.ClusterPowerManagementCapabilities[[int]$capability]) | Out-Null;
            }

            $NodeDetails.PowerManagementCapabilities = $PowerManagementCapabilities;
        } else {
            $NodeDetails.PowerManagementCapabilities = @{ 0 = 'Unknown'; }
        }

        if ($null -ne $node.Roles) {
            $Roles = @{ };
            foreach ($role in $node.Roles) {
                Add-IcingaHashtableItem -Hashtable $Roles -Key ([string]$role) -Value ([string]$role) | Out-Null;
            }

            $NodeDetails.Roles = $Roles;
        } else {
            $NodeDetails.Roles = @{ 'Unknown' = 'Unknown'; }
        }

        if ($null -ne $node.FaultDomain) {
            $FaultDomain = @{ };
            foreach ($domain in $node.FaultDomain) {
                Add-IcingaHashtableItem -Hashtable $FaultDomain -Key ([string]$domain) -Value ([string]$domain) | Out-Null;
            }

            $NodeDetails.FaultDomain = $FaultDomain;
        } else {
            $NodeDetails.FaultDomain = @{ 'Unknown' = 'Unknown'; }
        }

        if ($null -ne $node.InitialLoadInfo) {
            $InitialLoadInfo = @{ };
            foreach ($info in $node.InitialLoadInfo) {
                Add-IcingaHashtableItem -Hashtable $InitialLoadInfo -Key ([string]$info) -Value ([string]$info) | Out-Null;
            }

            $NodeDetails.InitialLoadInfo = $InitialLoadInfo;
        } else {
            $NodeDetails.InitialLoadInfo = @{ 'Unknown' = 'Unknown'; }
        }

        $ClusterNodeData.Add($node.Id, $NodeDetails);
    }

    return $ClusterNodeData;
}
