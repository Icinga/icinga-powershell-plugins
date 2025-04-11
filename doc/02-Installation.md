# Installation

To install this [Icinga for Windows](https://icinga.com/docs/icinga-for-windows) component, you can use the [official Icinga repositories](https://packages.icinga.com/IcingaForWindows/). You can read more about this on how to [install components](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/20-Install-Components/) for adding existing repositories or [create own repositories](https://icinga.com/docs/icinga-for-windows/latest/doc/120-Repository-Manager/07-Create-Own-Repositories/).

## General Note on Installation/Updates

You should always stick to one way of installing/updating any modules for the [Icinga for Windows](https://icinga.com/docs/icinga-for-windows) solution. It is **not** supported and **not** recommended to mix different installation methods.

## Install Stable Version

```powershell
Install-IcingaComponent -Name 'plugins';
```

## Install Snapshot Version

```powershell
Install-IcingaComponent -Name 'plugins' -Snapshot;
```

## Install Stable Updates

```powershell
Update-Icinga -Name 'plugins';
```

## Install Snapshot Updates

```powershell
Update-Icinga -Name 'plugins' -Snapshot;
```
