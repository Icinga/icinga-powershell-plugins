# Installation Guide

There are different ways available to actually install this repository onto your machine

## Manual Installation

Installing the PowerShell plugins works like any other PowerShell module. You will have to get to know which folders are configured as PowerShell module folders and extract the content of this repository there.

To display the available list, open a PowerShell and type in the following command:

```powershell
$env:PSModulePath
```

## PowerShell Gallery

You can use the PowerShell Gallery to install the module directly from there

```powershell
Install-Module icinga-powershell-plugins
```

## Icinga Framework

The setup wizard of the PowerShell Framework will ask you if you wish to install plugins from a specific repository. In addition, you can update the plugins manually by loading the framework components and running the install Cmdlet

```powershell
Use-Icinga;
Install-IcingaFrameworkPlugins;
```
