function Get-ValueFromJsonObject()
{
    param (
        # object to get the value from
        [PSCustomObject]$JsonObjectToCheck = $null,
        # path to get the value from (examples: "valpath", "subobj.val", "'sub.obj'.obj.'my.val'" )
        [String]$Path                      = ''
    );

    if ($null -eq $JsonObjectToCheck) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-JsonObjectToCheck" on "Get-ValueFromJsonObject"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ([string]::IsNullOrEmpty($Path)) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-Path" on "Get-ValueFromJsonObject"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    $Value = $null;

    if ($Path.IndexOf(".") -le 0) {
        $Value = $JsonObjectToCheck."$($Path)";
    } else {
        # we have a nested object -> RECURSE!
        $pathParts = $path.Split(".");
        $tmpPath   = $pathParts[0];
        $nextIndex = $tmpPath.Length + 1;

        if ($tmpPath.StartsWith("'")) {
            $nextPartIndex = 1;
            do {
                $tmpPath = $tmpPath + "." + $pathParts[$nextPartIndex];
                $nextPartIndex = $nextPartIndex + 1;
            } while ($pathParts[$nextPartIndex].EndsWith("'") -eq $false);

            $nextIndex = $tmpPath.Length + 1;
        }

        $Value   = $JsonObjectToCheck."$($tmpPath)";
        $newPath = $Path.Substring($nextIndex);

        if ($null -ne $Value) {
            $Value = Get-ValueFromJsonObject -JsonObjectToCheck $Value -Path $newPath;
        }
    }

    return $Value;
}
