<#
.SYNOPSIS
   Checks on memory usage
.DESCRIPTION
   Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g memory is currently at 60% usage, WARNING is set to 50, CRITICAL is set to 90. In this case the check will return WARNING.

   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check on memory usage.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckMemory -Verbosity 3 -Warning 60MB -Critical 80MB
   [WARNING]: % Memory Check 78.74 is greater than 60
.EXAMPLE
   PS> Invoke-IcingaCheckMemory -WarningPercent 30 -CriticalPercent 50
   [WARNING] Check package "Memory Usage" - [WARNING] Memory Percent Used
   \_ [WARNING] Memory Percent Used: Value "48.07%" is greater than threshold "30%"
   | 'memory_percent_used'=48.07%;0:30;0:50;0;100 'used_bytes'=3.85GB;;;0;8
   1
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20PB"

.PARAMETER Pagefile
   Switch which determines whether the pagefile should be used instead.
   If not set memory will be checked.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is below 30%, the check will return CRITICAL.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is below 30%, the check will return Warning.

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckMemory()
{
   param(
      [string]$Critical        = $null,
      [string]$Warning         = $null,
      $CriticalPercent         = 100,
      $WarningPercent          = 100,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity          = 0,
      [switch]$NoPerfData
   );

   $MemoryPackage = New-IcingaCheckPackage -Name 'Memory Usage' -OperatorAnd -Verbos $Verbosity;
   $MemoryData    = (Get-IcingaMemoryPerformanceCounter);

   # Auto-Detect?
   If (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 50)) -ge 1) {
      [string]$CalcUnit = 'PiB';
      [string]$Unit = "PB";
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 40)) -ge 1) {
      [string]$CalcUnit = 'TiB';
      [string]$Unit = "TB";
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 30)) -ge 1) {
      [string]$CalcUnit = 'GiB';
      [string]$Unit = "GB";
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 20)) -ge 1) {
      [string]$CalcUnit = 'MiB';
      [string]$Unit = "MB";
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 10)) -ge 1) {
      [string]$CalcUnit = 'KiB';
      [string]$Unit = "KB";
   } else {
      [string]$CalcUnit = 'B';
      [string]$Unit = "B";
   }

   If ([string]::IsNullOrEmpty($Critical) -eq $FALSE) {
      $CriticalConvertedAll = Convert-Bytes $Critical -Unit $Unit;
      [decimal]$CriticalConverted = $CriticalConvertedAll.value;
      if ($null -eq $CriticalPercent) {
         $CriticalPercent = $CriticalConverted / $MemoryData['Memory Total Bytes'] * 100
      }
   }

   If ([string]::IsNullOrEmpty($Warning) -eq $FALSE) {
      $WarningConvertedAll = Convert-Bytes $Warning -Unit $Unit;
      [decimal]$WarningConverted = $WarningConvertedAll.value;
      if ($null -eq $WarningPercent) {
         $WarningPercent = $CriticalConverted / $MemoryData['Memory Total Bytes'] * 100
      }
   }

   If ($null -ne $CriticalPercent) {
      if ([string]::IsNullOrEmpty($Critical)) {
         $CriticalConverted = (Convert-Bytes ([string]::Format('{0}B', $MemoryData['Memory Total Bytes'] / 100 * $CriticalPercent)) -Unit $CalcUnit).Value;
      }
   }

   If ($null -ne $WarningPercent) {
      if ([string]::IsNullOrEmpty($Warning)) {
         $WarningConverted = (Convert-Bytes ([string]::Format('{0}B', $MemoryData['Memory Total Bytes'] / 100 * $WarningPercent)) -Unit $CalcUnit).Value;
      }
   }

   $UsedMemory     = Convert-Bytes ([string]::Format('{0}B', $MemoryData['Memory Used Bytes'])) -Unit $CalcUnit;
   $TotalMemory    = Convert-Bytes ([string]::Format('{0}B', $MemoryData['Memory Total Bytes'])) -Unit $CalcUnit;
   $MemoryPerc     = New-IcingaCheck -Name 'Memory Percent Used' -Value $MemoryData['Memory Used %'] -Unit '%';
   $MemoryByteUsed = New-IcingaCheck -Name "Used Bytes" -Value $UsedMemory.value -Unit $Unit -Minimum 0 -Maximum $TotalMemory.value;

   # PageFile To-Do
   $MemoryByteUsed.WarnOutOfRange($WarningConverted).CritOutOfRange($CriticalConverted) | Out-Null;
   $MemoryPerc.WarnOutOfRange($WarningPercent).CritOutOfRange($CriticalPercent) | Out-Null;

   $MemoryPackage.AddCheck($MemoryPerc);
   $MemoryPackage.AddCheck($MemoryByteUsed);
      
   return (New-IcingaCheckResult -Check $MemoryPackage -NoPerfData $NoPerfData -Compile);
}
