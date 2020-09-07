function Get-IcingaClusterInfo()
{
    $ClusterServices = Get-IcingaWindowsInformation -ClassName CIM_ClusteringService -Namespace 'Root\MSCluster';
    $ClusterData     = @{ };

    foreach ($service in $ClusterServices) {
        $details = @{
            'Caption'                 = $service.Caption;
            'Description'             = $service.Description;
            'InstallDate'             = $service.InstallDate;
            'Status'                  = $service.Status;
            'CreationClassName'       = $service.CreationClassName;
            'Name'                    = $service.Name;
            'StartMode'               = $service.StartMode;
            'Started'                 = $service.Started;
            'State'                   = $service.State;
            'SystemCreationClassName' = $service.SystemCreationClassName;
            'SystemName'              = $service.SystemName;
            'NodeHighestVersion'      = $service.NodeHighestVersion;
            'NodeLowestVersion'       = $service.NodeLowestVersion;
            'CimClass'                = $service.CimClass;
        };

        $ClusterData.Add($service.SystemName, $details);
    }

    return $ClusterData;
}
