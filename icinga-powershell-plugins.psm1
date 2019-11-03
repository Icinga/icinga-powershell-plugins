function Use-IcingaPlugins()
{
    Import-IcingaPlugins -Directory 'provider';
    Import-IcingaPlugins -Directory 'plugins';
}

function Import-IcingaPlugins()
{
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [String]$Directory
    );

    [string]$module = Join-Path -Path $PSScriptRoot -ChildPath $Directory;

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

function Publish-IcingaPluginDocumentation()
{
    [string]$PluginDir = Join-Path -Path $PSScriptRoot -ChildPath 'plugins';
    [string]$DocDir = Join-Path -Path $PSScriptRoot -ChildPath 'doc';
    [string]$PluginDocFile = Join-Path -Path $PSScriptRoot -ChildPath 'doc/10-Icinga-Plugins.md';
    [string]$PluginDocDir = Join-Path -Path $PSScriptRoot -ChildPath 'doc/plugins';
    [int]$Index = 1;

    Set-Content -Path $PluginDocFile -Value '# Icinga Plugins';
    Add-Content -Path $PluginDocFile -Value '';
    Add-Content -Path $PluginDocFile -Value 'Below you will find a documentation for every single available plugin provided by this repository';
    Add-Content -Path $PluginDocFile -Value '';

    $AvailablePlugins = Get-ChildItem -Path $PluginDir -Recurse -Filter *.psm1;
    foreach ($plugin in $AvailablePlugins) {
        [string]$PluginName = $plugin.Name.Replace('.psm1', '');
        $IndexString = $Index;
        if ($Index -lt 10) {
            $IndexString = [string]::Format('0{0}', $Index);
        }
        [string]$PluginDocName = [string]::Format('{0}-{1}.md', $IndexString, $PluginName);
        [string]$PluginDescriptionFile = Join-Path -Path $PluginDocDir -ChildPath $PluginDocName;
        
        Add-Content -Path $PluginDocFile -Value ([string]::Format(
            '* [{0}](plugins/{1})',
            $PluginName,
            $PluginDocName
        ));

        $PluginHelp = Get-Help $PluginName -Full;

        Set-Content -Path $PluginDescriptionFile -Value ([string]::Format('# {0}', $PluginHelp.Name));
        Add-Content -Path $PluginDescriptionFile -Value '';
        Add-Content -Path $PluginDescriptionFile -Value '## Description';
        Add-Content -Path $PluginDescriptionFile -Value '';
        Add-Content -Path $PluginDescriptionFile -Value $PluginHelp.details.description.Text;
        Add-Content -Path $PluginDescriptionFile -Value '';
        Add-Content -Path $PluginDescriptionFile -Value $PluginHelp.description.Text;

        if ($null -ne $PluginHelp.parameters.parameter) {
            Add-Content -Path $PluginDescriptionFile -Value '';
            Add-Content -Path $PluginDescriptionFile -Value '## Arguments';
            Add-Content -Path $PluginDescriptionFile -Value '';
            Add-Content -Path $PluginDescriptionFile -Value '| Argument | Type | Required | Default | Description |';
            Add-Content -Path $PluginDescriptionFile -Value '| ---      | ---  | ---      | ---     | ---         |';
            
            foreach ($parameter in $PluginHelp.parameters.parameter) {
                [string]$ParamDescription = $parameter.description.Text;
                if ([string]::IsNullOrEmpty($ParamDescription) -eq $FALSE) {
                    $ParamDescription = $ParamDescription.Replace("`r`n", ' ');
                    $ParamDescription = $ParamDescription.Replace("`r", ' ');
                    $ParamDescription = $ParamDescription.Replace("`n", ' ');
                }
                [string]$TableContent = [string]::Format(
                    '| {0} | {1} | {2} | {3} | {4} |',
                    $parameter.name,
                    $parameter.type.name,
                    $parameter.required,
                    $parameter.defaultValue,
                    $ParamDescription
                );
                Add-Content -Path $PluginDescriptionFile -Value $TableContent;
            }
        }

        if ($null -ne $PluginHelp.examples) {
            [int]$ExampleIndex = 1;
            Add-Content -Path $PluginDescriptionFile -Value '';
            Add-Content -Path $PluginDescriptionFile -Value '## Examples';
            Add-Content -Path $PluginDescriptionFile -Value '';

            foreach ($example in $PluginHelp.examples.example) {
                [string]$ExampleDescription = $example.remarks.Text;
                if ([string]::IsNullOrEmpty($ExampleDescription) -eq $FALSE) {
                    $ExampleDescription = $ExampleDescription.Replace("`r`n", '');
                    $ExampleDescription = $ExampleDescription.Replace("`r", '');
                    $ExampleDescription = $ExampleDescription.Replace("`n", '');
                    $ExampleDescription = $ExampleDescription.Replace('  ', '');
                }

                Add-Content -Path $PluginDescriptionFile -Value ([string]::Format('### Example Command {0}', $ExampleIndex));
                Add-Content -Path $PluginDescriptionFile -Value '';
                Add-Content -Path $PluginDescriptionFile -Value '```powershell';
                Add-Content -Path $PluginDescriptionFile -Value $example.code;
                Add-Content -Path $PluginDescriptionFile -Value '```';
                Add-Content -Path $PluginDescriptionFile -Value '';
                Add-Content -Path $PluginDescriptionFile -Value ([string]::Format('### Example Output {0}', $ExampleIndex));
                Add-Content -Path $PluginDescriptionFile -Value '';
                Add-Content -Path $PluginDescriptionFile -Value '```powershell';
                Add-Content -Path $PluginDescriptionFile -Value $ExampleDescription;
                Add-Content -Path $PluginDescriptionFile -Value '```';
                Add-Content -Path $PluginDescriptionFile -Value '';
                
                $ExampleIndex += 1;
            }

            $Content = Get-Content -Path $PluginDescriptionFile;
            Set-Content -Path $PluginDescriptionFile -Value '';
            for ($entry = 0; $entry -lt ($Content.Count - 1); $entry++) {
                Add-Content -Path $PluginDescriptionFile -Value $Content[$entry];
            }
        }

        $Index += 1;
    }
}
