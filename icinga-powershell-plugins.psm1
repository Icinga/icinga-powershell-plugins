function Import-IcingaPowerShellComponentPlugins()
{
    # Allows other components to load this component
}

Export-ModuleMember -Variable @('ProviderEnums', 'IcingaPluginExceptions');
