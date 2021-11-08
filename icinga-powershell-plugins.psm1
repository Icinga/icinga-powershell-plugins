function Use-IcingaPlugins()
{
    Import-IcingaPlugins -Directory 'provider';
}

function Import-IcingaPlugins()
{
    param (
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [String]$Directory
    );

    [string]$module = Join-Path -Path $PSScriptRoot -ChildPath $Directory;

    if ((Test-Path $module) -eq $FALSE) {
        return;
    }

    # Load modules from directory
    if ((Test-Path $module -PathType Container)) {
        Get-ChildItem -Path $module -Recurse -Filter *.psm1 |
            ForEach-Object {
                [string]$modulePath = $_.FullName;
                Import-Module ([string]::Format('{0}', $modulePath)) -Global;
            }
    } else {
        $module = $module.Replace('.psm1', ''); # Cut possible .psm1 ending
        Import-Module ([string]::Format('{0}.psm1', $module)) -Global;
    }
}
