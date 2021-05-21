<#
.SYNOPSIS
    Tests if the Multipath-IO windows feature is installed on the system without requiring administrative privileges
.DESCRIPTION
    Tests if the Multipath-IO windows feature is installed on the system without requiring administrative privileges
.OUTPUTS
    System.Boolean
.LINK
    https://github.com/Icinga/icinga-powershell-PLUGINS
#>

function Test-IcingaMPIOInstalled()
{
    if (Test-IcingaFunction 'Get-WindowsFeature') {
        if ((Get-WindowsFeature -Name 'Multipath-IO').Installed) {
            return $TRUE;
        }
    }

    return $FALSE;
}
