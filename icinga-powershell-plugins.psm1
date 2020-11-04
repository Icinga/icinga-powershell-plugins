function Publish-IcingaPluginDocumentation()
{
    param (
        [string]$ModulePath = $PSScriptRoot
    );

    [string]$PluginDir     = Join-Path -Path $ModulePath -ChildPath 'plugins';
    [string]$DocDir        = Join-Path -Path $ModulePath -ChildPath 'doc';
    [string]$PluginDocFile = Join-Path -Path $ModulePath -ChildPath 'doc/10-Icinga-Plugins.md';
    [string]$PluginDocDir  = Join-Path -Path $ModulePath -ChildPath 'doc/plugins';

    if ((Test-Path $PluginDocDir) -eq $FALSE) {
        New-Item -Path $PluginDocDir -ItemType Directory -Force | Out-Null;
    }

    $MDFiles               = Get-ChildItem -Path $PluginDocDir;
    [int]$FileCount        = $MDFiles.Count;
    [string]$FileCountStr  = '';

    Set-Content -Path $PluginDocFile -Value '# Icinga Plugins';
    Add-Content -Path $PluginDocFile -Value '';
    Add-Content -Path $PluginDocFile -Value 'Below you will find a documentation for every single available plugin provided by this repository. Most of the plugins allow the usage of default Icinga threshold range handling, which is defined as follows:';
    Add-Content -Path $PluginDocFile -Value '';
    Add-Content -Path $PluginDocFile -Value '| Argument | Throws error on | Ok range                     |';
    Add-Content -Path $PluginDocFile -Value '| ---      | ---             | ---                          |';
    Add-Content -Path $PluginDocFile -Value '| 20       | < 0 or > 20     | 0 .. 20                      |';
    Add-Content -Path $PluginDocFile -Value '| 20:      | < 20            | between 20 .. ∞              |';
    Add-Content -Path $PluginDocFile -Value '| ~:20     | > 20            | between -∞ .. 20             |';
    Add-Content -Path $PluginDocFile -Value '| 30:40    | < 30 or > 40    | between {30 .. 40}           |';
    Add-Content -Path $PluginDocFile -Value '| `@30:40  | ≥ 30 and ≤ 40   | outside -∞ .. 29 and 41 .. ∞ |';
    Add-Content -Path $PluginDocFile -Value '';
    Add-Content -Path $PluginDocFile -Value 'Please ensure that you will escape the `@` if you are configuring it on the Icinga side. To do so, you will simply have to write an *\`* before the `@` symbol: \``@`';
    Add-Content -Path $PluginDocFile -Value '';
    Add-Content -Path $PluginDocFile -Value 'To test thresholds with different input values, you can use the Framework Cmdlet `Get-IcingaHelpThresholds`.';
    Add-Content -Path $PluginDocFile -Value '';

    $AvailablePlugins = Get-ChildItem -Path $PluginDir -Recurse -Filter *.psm1;
    foreach ($plugin in $AvailablePlugins) {
        [string]$PluginName    = $plugin.Name.Replace('.psm1', '');
        [string]$PluginDocName = '';
        foreach ($DocFile in $MDFiles) {
            $DocFileName = $DocFile.Name;
            if ($DocFileName -Like "*$PluginName*") {
                $PluginDocName = $DocFile.Name;
                break;
            }
        }

        if ([string]::IsNullOrEmpty($PluginDocName)) {
            $FileCount += 1;
            if ($FileCount -lt 10) {
                $FileCountStr = [string]::Format('0{0}', $FileCount);
            } else {
                $FileCountStr = $FileCount;
            }

            $PluginDocName = [string]::Format('{0}-{1}.md', $FileCountStr, $PluginName);
        }
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
        Add-Content -Path $PluginDescriptionFile -Value '';
        Add-Content -Path $PluginDescriptionFile -Value '## Permissions';
        Add-Content -Path $PluginDescriptionFile -Value '';

        if ([string]::IsNullOrEmpty($PluginHelp.Role)) {
            Add-Content -Path $PluginDescriptionFile -Value 'No special permissions required.';
        } else {
            Add-Content -Path $PluginDescriptionFile -Value 'To execute this plugin you will require to grant the following user permissions.';
            Add-Content -Path $PluginDescriptionFile -Value '';
            Add-Content -Path $PluginDescriptionFile -Value $PluginHelp.Role;
        }

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
    }
}

Export-ModuleMember -Variable * -Alias * -Function *;
