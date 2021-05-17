[hashtable]$Inputs = @{
    EventLogLogName          = 'Failed to fetch EventLog information. Please specify a valid LogName.';
    EventLogNegativeEntries  = 'Failed to fetch EventLog information. The argument `-MaxEntries` cannot be lower than 0';
    EventLogNoMessageEntries = 'Failed to fetch EventLog information. The argument `-MaxEntries` requires to be greater or equal 1';
};

if ($null -eq $IcingaPluginExceptions) {
    [hashtable]$IcingaPluginExceptions = @{
        Inputs = $Inputs;
    }
}

Export-ModuleMember -Variable @( 'IcingaPluginExceptions' );
