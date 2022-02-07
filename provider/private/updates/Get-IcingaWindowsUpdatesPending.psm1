function Global:Get-IcingaWindowsUpdatesPending()
{
    param (
        [array]$UpdateFilter = @()
    );

    [hashtable]$PendingUpdates         = @{ };
    [hashtable]$PendingUpdateNameCache = @{ };

    # Fetch all informations about installed updates and add them
    try {
        $WindowsUpdates = New-Object -ComObject "Microsoft.Update.Session" -ErrorAction Stop;
        $SearchIndex    = $WindowsUpdates.CreateUpdateSearcher();
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.WindowsUpdate -Force;
    }

    try {
        # Get a list of current pending updates which are not yet installed on the system
        $Pending = $SearchIndex.Search("IsInstalled=0");
        $PendingUpdates.Add('count', 0);
        $PendingUpdates.Add(
            'RebootPending',
            (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
        );
        $PendingUpdates.Add(
            'updates',
            @{
                'security' = @{ };
                'defender' = @{ };
                'rollups'  = @{ };
                'other'    = @{ };
            }
        );

        foreach ($update in $Pending.Updates) {
            [hashtable]$PendingUpdateDetails = @{ };
            $PendingUpdateDetails.Add('Title', $update.Title);
            $PendingUpdateDetails.Add('Category', $null);
            $PendingUpdateDetails.Add('Deadline', $update.Deadline);
            $PendingUpdateDetails.Add('Description', $update.Description);
            $PendingUpdateDetails.Add('IsBeta', $update.IsBeta);
            $PendingUpdateDetails.Add('IsDownloaded', $update.IsDownloaded);
            $PendingUpdateDetails.Add('IsHidden', $update.IsHidden);
            $PendingUpdateDetails.Add('IsInstalled', $update.IsInstalled);
            $PendingUpdateDetails.Add('IsMandatory', $update.IsMandatory);
            $PendingUpdateDetails.Add('IsUninstallable', $update.IsUninstallable);
            $PendingUpdateDetails.Add('Languages', $update.Languages);
            $PendingUpdateDetails.Add('LastDeploymentChangeTime', $update.LastDeploymentChangeTime);
            $PendingUpdateDetails.Add('MaxDownloadSize', $update.MaxDownloadSize);
            $PendingUpdateDetails.Add('MinDownloadSize', $update.MinDownloadSize);
            $PendingUpdateDetails.Add('MoreInfoUrls', $update.MoreInfoUrls);
            $PendingUpdateDetails.Add('MsrcSeverity', $update.MsrcSeverity);
            $PendingUpdateDetails.Add('RecommendedCpuSpeed', $update.RecommendedCpuSpeed);
            $PendingUpdateDetails.Add('RecommendedHardDiskSpace', $update.RecommendedHardDiskSpace);
            $PendingUpdateDetails.Add('RecommendedMemory', $update.RecommendedMemory);
            $PendingUpdateDetails.Add('ReleaseNotes', $update.ReleaseNotes);
            $PendingUpdateDetails.Add('SecurityBulletinIDs', $update.SecurityBulletinIDs);
            $PendingUpdateDetails.Add('SupersededUpdateIDs', $update.SupersededUpdateIDs);
            $PendingUpdateDetails.Add('SupportUrl', $update.SupportUrl);
            $PendingUpdateDetails.Add('Type', $update.Type);
            $PendingUpdateDetails.Add('UninstallationNotes', $update.UninstallationNotes);
            $PendingUpdateDetails.Add('UninstallationBehavior', $update.UninstallationBehavior);
            $PendingUpdateDetails.Add('UninstallationSteps', $update.UninstallationSteps);
            $PendingUpdateDetails.Add('KBArticleIDs', $update.KBArticleIDs);
            $PendingUpdateDetails.Add('DeploymentAction', $update.DeploymentAction);
            $PendingUpdateDetails.Add('DownloadPriority', $update.DownloadPriority);
            $PendingUpdateDetails.Add('RebootRequired', $update.RebootRequired);
            $PendingUpdateDetails.Add('IsPresent', $update.IsPresent);
            $PendingUpdateDetails.Add('CveIDs', $update.CveIDs);
            $PendingUpdateDetails.Add('BrowseOnly', $update.BrowseOnly);
            $PendingUpdateDetails.Add('PerUser', $update.PerUser);
            $PendingUpdateDetails.Add('AutoSelection', $update.AutoSelection);
            $PendingUpdateDetails.Add('AutoDownload', $update.AutoDownload);

            if ($UpdateFilter.Count -ne 0) {
                foreach ($filter in $UpdateFilter) {
                    if ($update.Title -Like $filter) {
                        $PendingUpdates.count += 1;
                        break;
                    }
                }
            } else {
                $PendingUpdates.count += 1;
            }

            [string]$name = [string]::Format('{0} [{1}]', $update.Title, $update.LastDeploymentChangeTime);

            if ($PendingUpdateNameCache.ContainsKey($name) -eq $FALSE) {
                $PendingUpdateNameCache.Add($name, 1);
            } else {
                $PendingUpdateNameCache[$name] += 1;
                $name = [string]::Format('{0} ({1})', $name, $PendingUpdateNameCache[$name]);
            }

            [bool]$IsSecurity = $FALSE;
            [bool]$IsDefender = $FALSE;
            [bool]$IsRollUp   = $FALSE;

            foreach ($category in $update.Categories) {
                if ($category.Name -eq 'Update Rollups') {
                    $IsRollUp = $TRUE;
                    $PendingUpdateDetails.Category = $category;
                }
                if ($category.Name -eq 'Definition Updates' -Or $category.Name -eq 'Microsoft Defender Antivirus') {
                    $IsDefender = $TRUE;
                    $PendingUpdateDetails.Category = $category;
                    break;
                }
                if ($category.Name -eq 'Security Updates') {
                    $IsSecurity = $TRUE;
                    $PendingUpdateDetails.Category = $category;
                    break;
                }
            }

            if ($null -eq $PendingUpdateDetails.Category) {
                $PendingUpdateDetails.Category = $update.Categories[0];
            }

            if ($IsSecurity) {
                $PendingUpdates.updates.security.Add($name, $PendingUpdateDetails);
                continue;
            }
            if ($IsDefender) {
                $PendingUpdates.updates.defender.Add($name, $PendingUpdateDetails);
                continue;
            }
            if ($IsRollUp) {
                $PendingUpdates.updates.rollups.Add($name, $PendingUpdateDetails);
                continue;
            }

            $PendingUpdates.updates.other.Add($name, $PendingUpdateDetails);
        }
    } catch {
        if ($PendingUpdates.ContainsKey('Count') -eq $FALSE) {
            $PendingUpdates.Add('count', 0);
        } else {
            $PendingUpdates['count'] =  0;
        }
        $PendingUpdates.Add('error', $_.Exception.Message);
    }

    return $PendingUpdates;
}
