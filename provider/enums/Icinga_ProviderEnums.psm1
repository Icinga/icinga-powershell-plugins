
<##################################################################################################
################# /lib/provider/bios ##############################################################
##################################################################################################>

[hashtable]$BiosCharacteristics = @{
    0  = 'Reserved'; 
    1  = 'Reserved'; 
    2  = 'Unknown';
    3  = 'BIOS Characteristics Not Supported';
    4  = 'ISA is supported';
    5  = 'MCA is supported';
    6  = 'EISA is supported';
    7  = 'PCI is supported';
    8  = 'PC Card (PCMCIA) is supported';
    9  = 'Plug and Play is supported';
    10 = 'APM is supported';
    11 = 'BIOS is Upgradeable (Flash)';
    12 = 'BIOS shadowing is allowed';
    13 = 'VL-VESA is supported';
    14 = 'ESCD support is available';
    15 = 'Boot from CD is supported';
    16 = 'Selectable Boot is supported';
    17 = 'BIOS ROM is socketed';
    18 = 'Boot From PC Card (PCMCIA) is supported';
    19 = 'EDD (Enhanced Disk Drive) Specification is supported';
    20 = 'Int 13h - Japanese Floppy for NEC 9800 1.2mb (3.5, 1k Bytes/Sector, 360 RPM) is supported';
    21 = 'Int 13h - Japanese Floppy for Toshiba 1.2mb (3.5, 360 RPM) is supported';
    22 = 'Int 13h - 5.25 / 360 KB Floppy Services are supported';
    23 = 'Int 13h - 5.25 /1.2MB Floppy Services are supported';
    24 = 'Int 13h - 3.5 / 720 KB Floppy Services are supported';
    25 = 'Int 13h - 3.5 / 2.88 MB Floppy Services are supported';
    26 = 'Int 5h, Print Screen Service is supported';
    27 = 'Int 9h, 8042 Keyboard services are supported';
    28 = 'Int 14h, Serial Services are supported';
    29 = 'Int 17h, printer services are supported';
    30 = 'Int 10h, CGA/Mono Video Services are supported';
    31 = 'NEC PC-98';
    32 = 'ACPI is supported';
    33 = 'USB Legacy is supported';
    34 = 'AGP is supported';
    35 = 'I2O boot is supported';
    36 = 'LS-120 boot is supported';
    37 = 'ATAPI ZIP Drive boot is supported';
    38 = '1394 boot is supported';
    39 = 'Smart Battery is supported';
    40 = 'Reserved for BIOS vendor';
    41 = 'Reserved for BIOS vendor';
    42 = 'Reserved for BIOS vendor';
    43 = 'Reserved for BIOS vendor';
    44 = 'Reserved for BIOS vendor';
    45 = 'Reserved for BIOS vendor';
    46 = 'Reserved for BIOS vendor';
    47 = 'Reserved for BIOS vendor';
    48 = 'Reserved for system vendor';
    49 = 'Reserved for system vendor';
    50 = 'Reserved for system vendor';
    51 = 'Reserved for system vendor';
    52 = 'Reserved for system vendor';
    53 = 'Reserved for system vendor';
    54 = 'Reserved for system vendor';
    55 = 'Reserved for system vendor';
    56 = 'Reserved for system vendor';
    57 = 'Reserved for system vendor';
    58 = 'Reserved for system vendor';
    59 = 'Reserved for system vendor';
    60 = 'Reserved for system vendor';
    61 = 'Reserved for system vendor';
    62 = 'Reserved for system vendor';
    63 = 'Reserved for system vendor'
}

<##################################################################################################
################# /lib/provider/disks #############################################################
##################################################################################################>

[hashtable]$DiskCapabilities = @{
    0  = 'Unknown';
    1  = 'Other';
    2  = 'Sequential Access';
    3  = 'Random Access';
    4  = 'Supports Writing';
    5  = 'Encryption';
    6  = 'Compression';
    7  = 'Supports Removeable Media';
    8  = 'Manual Cleaning';
    9  = 'Automatic Cleaning';
    10 = 'SMART Notification';
    11 = 'Supports Dual Sided Media';
    12 = 'Predismount Eject Not Required';
}

# https://docs.microsoft.com/en-us/previous-versions/windows/desktop/stormgmt/msft-disk
[hashtable]$DiskBusType = @{
    0  = 'Unknown';
    1  = 'SCSI';
    2  = 'ATAPI';
    3  = 'ATA';
    4  = '1394';
    5  = 'SSA';
    6  = 'Fibre Channel';
    7  = 'USB';
    8  = 'RAID';
    9  = 'iSCSI';
    10 = 'SAS';
    11 = 'SATA';
    12 = 'SD';
    13 = 'MMC';
    14 = 'Virtual';
    15 = 'File Backed Virtual';
    16 = 'Storage Spaces';
    17 = 'NVMe';
}

# https://docs.microsoft.com/en-us/previous-versions/windows/desktop/stormgmt/msft-disk
[hashtable]$DiskOperationalStatus = @{
    0      = 'Unknown';
    1      = 'Other';
    2      = 'OK';
    3      = 'Degraded';
    4      = 'Stressed';
    5      = 'Predictive Failure';
    6      = 'Error';
    7      = 'Non-Recoverable Error';
    8      = 'Starting';
    9      = 'Stopping';
    10     = 'Stopped';
    11     = 'In Service';
    12     = 'No Contact';
    13     = 'Lost Communication';
    14     = 'Aborted';
    15     = 'Dormant';
    16     = 'Supporting Entity in Error';
    17     = 'Completed';
    0xD010 = 'Online';
    0xD011 = 'Not Ready';
    0xD012 = 'No Media';
    0xD013 = 'Offline';
    0xD014 = 'Failed';
}

# https://docs.microsoft.com/en-us/previous-versions/windows/desktop/stormgmt/msft-disk
[hashtable]$DiskOperationalStatusName = @{
    'Unknown'                    = 0;
    'Other'                      = 1;
    'OK'                         = 2;
    'Degraded'                   = 3;
    'Stressed'                   = 4;
    'Predictive Failure'         = 5;
    'Error'                      = 6;
    'Non-Recoverable Error'      = 7;
    'Starting'                   = 8;
    'Stopping'                   = 9;
    'Stopped'                    = 10;
    'In Service'                 = 11;
    'No Contact'                 = 12;
    'Lost Communication'         = 13;
    'Aborted'                    = 14;
    'Dormant'                    = 15;
    'Supporting Entity in Error' = 16;
    'Completed'                  = 17;
    'Online'                     = 0xD010;
    'Not Ready'                  = 0xD011;
    'No Media'                   = 0xD012;
    'Offline'                    = 0xD013;
    'Failed'                     = 0xD014;
}

<##################################################################################################
################# /lib/provider/cluster ###########################################################
##################################################################################################>

[hashtable]$ClusterEnforcedAntiAffinity = @{
    0 = 'Disabled';
    1 = 'Enabled';
}

[hashtable]$ClusterEnforcedAntiAffinityName = @{
    'Disabled' = 0;
    'Enabled'  = 1;
}

<##################################################################################################
################# /lib/provider/cpu ###############################################################
##################################################################################################>

[hashtable]$CPUArchitecture = @{
    0  = 'x86';
    1  = 'MIPS';
    2  = 'Alpha';
    3  = 'PowerPC';
    6  = 'ia64';
    9  = 'x64';
}

[hashtable]$CPUProcessorType = @{
    1  = 'Other';
    2  = 'Unknown';
    3  = 'Central Processor';
    4  = 'Math Processor';
    5  = 'DSP Processor';
    6  = 'Video Processor';
}

[hashtable]$CPUStatusInfo = @{
    1  = 'Other';
    2  = 'Unknown';
    3  = 'Enabled';
    4  = 'Disabled';
    5  = 'Not Applicable';
}

[hashtable]$CPUFamily = @{
    1  = 'Other';
    2  = 'Unknown';
    3  = '8086';
    4  = '80286';
    5  = '80386';
    6  = '80486';
    7  = '8087';
    8  = '80287';
    9  = '80387';
   10  = '80487';
   11  = 'Pentium(R) brand';
   12  = 'Pentium(R) Pro';
   13  = 'Pentium(R) II';
   14  = 'Pentium(R) processor with MMX(TM) technology';
   15  = 'Celeron(TM)';
   16  = 'Pentium(R) II Xeon(TM)';
   17  = 'Pentium(R) III';
   18  = 'M1 Family';
   19  = 'M2 Family';
   24  = 'K5 Family';
   25  = 'K6 Family';
   26  = 'K6-2';
   27  = 'K6-3';
   28  = 'AMD Athlon(TM) Processor Family';
   29  = 'AMD(R) Duron(TM) Processor';
   30  = 'AMD29000 Family';
   31  = 'K6-2+';
   32  = 'Power PC Family';
   33  = 'Power PC 601';
   34  = 'Power PC 603';
   35  = 'Power PC 603+';
   36  = 'Power PC 604';
   37  = 'Power PC 620';
   38  = 'Power PC X704';
   39  = 'Power PC 750';
   48  = 'Alpha Family';
   49  = 'Alpha 21064';
   50  = 'Alpha 21066';
   51  = 'Alpha 21164';
   52  = 'Alpha 21164PC';
   53  = 'Alpha 21164a';
   54  = 'Alpha 21264';
   55  = 'Alpha 21364';
   64  = 'MIPS Family';
   65  = 'MIPS R4000';
   66  = 'MIPS R4200';
   67  = 'MIPS R4400';
   68  = 'MIPS R4600';
   69  = 'MIPS R10000';
   80  = 'SPARC Family';
   81  = 'SuperSPARC';
   82  = 'microSPARC II';
   83  = 'microSPARC IIep';
   84  = 'UltraSPARC';
   85  = 'UltraSPARC II';
   86  = 'UltraSPARC IIi';
   87  = 'UltraSPARC III';
   88  = 'UltraSPARC IIIi';
   96  = ' 68040';
   97  = '68xxx Family';
   98  = '68000';
   99  = '68010';
  100  = '68020';
  101  = '68030';
  112  = 'Hobbit Family';
  120  = 'Crusoe(TM) TM5000 Family';
  121  = 'Crusoe(TM) TM3000 Family';
  122  = 'Efficeon(TM) TM8000 Family';
  128  = 'Weitek';
  130  = 'Itanium(TM) Processor';
  131  = 'AMD Athlon(TM) 64 Processor Family';
  132  = 'AMD Opteron(TM) Family';
  144  = 'PA-RISC Family';
  145  = 'PA-RISC 8500';
  146  = 'PA-RISC 8000';
  147  = 'PA-RISC 7300LC';
  148  = 'PA-RISC 7200';
  149  = 'PA-RISC 7100LC';
  150  = 'PA-RISC 7100';
  160  = 'V30 Family';
  176  = 'Pentium(R) III Xeon(TM)';
  177  = 'Pentium(R) III Processor with Intel(R) SpeedStep(TM) Technology';
  178  = 'Pentium(R) 4';
  179  = 'Intel(R) Xeon(TM)';
  180  = 'AS400 Family';
  181  = 'Intel(R) Xeon(TM) processor MP';
  182  = 'AMD AthlonXP(TM) Family';
  183  = 'AMD AthlonMP(TM) Family';
  184  = 'Intel(R) Itanium(R) 2';
  185  = 'Intel Pentium M Processor';
  190  = 'K7';
  200  = 'IBM390 Family';
  201  = 'G4';
  202  = 'G5';
  203  = 'G6';
  204  = 'z/Architecture base';
  250  = 'i860';
  251  = 'i960';
  260  = 'SH-3';
  261  = 'SH-4';
  280  = 'ARM';
  281  = 'StrongARM';
  300  = '6x86';
  301  = 'MediaGX';
  302  = 'MII';
  320  = 'WinChip';
  350  = 'DSP';
  500  = 'Video Processor';
}

[hashtable]$CPUConfigManagerErrorCode = @{
    0  = 'This device is working properly.';
    1  = 'This device is not configured correctly.';
    2  = 'Windows cannot load the driver for this device.';
    3  = 'The driver for this device might be corrupted, or your system may be running low on memory or other resources.';
    4  = 'This device is not working properly. One of its drivers or your registry might be corrupted.';
    5  = 'The driver for this device needs a resource that Windows cannot manage.';
    6  = 'The boot configuration for this device conflicts with other devices.';
    7  = 'Cannot filter.';
    8  = 'The driver loader for the device is missing.';
    9  = 'This device is not working properly because the controlling firmware is reporting the resources for the device incorrectly.';
    10 = 'This device cannot start.';
    11 = 'This device failed.';
    12 = 'This device cannot find enough free resources that it can use.';
    13 = "Windows cannot verify this device’s resources.";
    14 = 'This device cannot work properly until you restart your computer.';
    15 = 'This device is not working properly because there is probably a re-enumeration problem.';
    16 = 'Windows cannot identify all the resources this device uses.';
    17 = 'This device is asking for an unknown resource type.';
    18 = 'Reinstall the drivers for this device.';
    19 = 'Your registry might be corrupted.';
    20 = 'Failure using the VxD loader.';
    21 = 'System failure: Try changing the driver for this device. If that does not work, see your hardware documentation. Windows is removing this device.';
    22 = 'This device is disabled.';
    23 = "System failure: Try changing the driver for this device. If that doesn’t work, see your hardware documentation.";
    24 = "This device is not present, is not working properly, or does not have all its drivers installed.";
    25 = "Windows is still setting up this device.";
    26 = "Windows is still setting up this device.";
    27 = "This device does not have valid log configuration.";
    28 = "The drivers for this device are not installed.";
    29 = "This device is disabled because the firmware of the device did not give it the required resources.";
    30 = "This device is using an Interrupt Request (IRQ) resource that another device is using.";
    31 = 'This device is not working properly because Windows cannot load the drivers required for this device.';
}

[hashtable]$DeviceAvailabilityName = @{
    1  = 'Other';
    2  = 'Unknown';
    3  = 'Running/Full Power';
    4  = 'Warning';
    5  = 'In Test';
    6  = 'Not Applicable';
    7  = 'Power Off';
    8  = 'Off Line';
    9  = 'Off Duty';
    10 = 'Degraded';
    11 = 'Not Installed';
    12 = 'Install Error';
    13 = 'Power Save - Unknown';
    14 = 'Power Save - Low Power Mode';
    15 = 'Power Save - Standby';
    16 = 'Power Cycle';
    17 = 'Power Save - Warning';
    18 = 'Paused';
    19 = 'Not Ready';
    20 = 'Not Configured';
    21 = 'Quiesced';
}

[hashtable]$DeviceAvailability = @{
    'Other'                 = 1;
    'Unknown'               = 2;
    'RunningFullPower'      = 3;
    'Warning'               = 4;
    'InTest'                = 5;
    'NotApplicable'         = 6;
    'PowerOff'              = 7;
    'OffLine'               = 8;
    'OffDuty'               = 9;
    'Degraded'              = 10;
    'NotInstalled'          = 11;
    'InstallError'          = 12;
    'PowerSaveUnknown'      = 13;
    'PowerSaveLowPowerMode' = 14;
    'PowerSaveStandby'      = 15;
    'PowerCycle'            = 16;
    'PoweSaveWarning'       = 17;
    'Paused'                = 18;
    'NotReady'              = 19;
    'NotConfigured'         = 20;
    'Quiesced'              = 21;
}

[hashtable]$CPUAvailability = $DeviceAvailabilityName;

[hashtable]$CPUPowerManagementCapabilities = @{
    0  = 'Unknown';
    1  = 'Not Supported';
    2  = 'Disabled';
    3  = 'Enabled';
}

<##################################################################################################
################# /lib/provider/memory ############################################################
##################################################################################################>

[hashtable]$MemoryFormFactor = @{
    0  = 'Unknown';
    1  = 'Other';
    2  = 'SIP';
    3  = 'DIP';
    4  = 'ZIP';
    5  = 'SOJ';
    6  = 'Proprietary';
    7  = 'SIMM';
    8  = 'DIMM';
    9  = 'TSOP';
    10 = 'PGA';
    11 = 'RIMM';
    12 = 'SODIMM';
    13 = 'SRIMM';
    14 = 'SMD';
    15 = 'SSMP';
    16 = 'QFP';
    17 = 'TQFP';
    18 = 'SOIC';
    19 = 'LCC';
    20 = 'PLCC';
    21 = 'BGA';
    22 = 'FPBGA';
    23 = 'LGA';
}

[hashtable]$MemoryInterleavePosition = @{
    0  = 'Noninterleaved';
    1  = 'First position';
    2  = 'Second position';
}

[hashtable]$MemoryMemoryType = @{
    0  = 'Unknown';
    1  = 'Other';  
    2  = 'DRAM';
    3  = 'Synchronous DRAM';
    4  = 'Cache DRAM';
    5  = 'EDO';
    6  = 'EDRAM';
    7  = 'VRAM';
    8  = 'SRAM';
    9  = 'RAM';
    10 = 'ROM';
    11 = 'Flash';
    12 ='EEPROM';
    13 = 'FEPROM';
    14 = 'EPROM';
    15 = 'CDRAM';
    16 = '3DRAM';
    17 = 'SDRAM';
    18 = 'SGRAM';
    19 = 'RDRAM';
    20 = 'DDR';
    21 = 'DDR2';
    22 = 'DDR2 FB-DIMM';
    23 = 'DDR2—FB-DIMM,May not be available; see note above.';
    24 = 'DDR3—May not be available; see note above.';
    25 = 'FBD2';
}

[hashtable]$MemoryTypeDetail = @{
    1    = 'Reserved';
    2    = 'Other';
    4    = 'Unknown';
    8    = 'Fast-paged';
    16   = 'Static column';
    32   = 'Pseudo-static';
    64   = 'RAMBUS';
    128  = 'Synchronous';
    256  = 'CMOS';
    512  = 'EDO';
    1024 = 'Window DRAM';
    2048 = 'Cache DRAM';
    4096 = 'Non-volatile';
}

<##################################################################################################
################# /lib/provider/Windows ###########################################################
##################################################################################################>

[hashtable]$WindowsOSProductSuite = @{
    1     = 'Microsoft Small Business Server was once installed, but may have been upgraded to another version of Windows.';
    2     = 'Windows Server 2008 Enterprise is installed.';
    4     = 'Windows BackOffice components are installed.';
    8     = 'Communication Server is installed.';
    16    = 'Terminal Services is installed.';
    32    = 'Microsoft Small Business Server is installed with the restrictive client license.';
    64    = 'Windows Embedded is installed.';
    128   = 'Datacenter edition is installed.';
    256   = 'Terminal Services is installed, but only one interactive session is supported.';
    512   = 'Windows Home Edition is installed.';
    1024  = 'Web Server Edition is installed.';
    8192  = 'Storage Server Edition is installed.';
    16384 = 'Compute Cluster Edition is installed.';
}

[hashtable]$WindowsProductType = @{
    1 = 'Work Station';
    2 = 'Domain Controller';
    3 = 'Server';
}

[hashtable]$WindowsOSType = @{
    0 = 'Unknown';
    1 = 'Other';
    2 = 'MACROS';
    3 = 'ATTUNIX';
    4 = 'DGUX';
    5 = 'DECNT';
    6 = 'Digital Unix';
    7 = 'OpenVMS'
    8 = 'HPUX';
    9 = 'AIX';
   10 = 'MVS';
   11 = 'OS400';
   12 = 'OS/2';
   13 = 'JavaVM';
   14 = 'MSDOS';
   15 = 'WIN3x';
   16 = 'WIN95';
   17 = 'WIN98';
   18 = 'WINNT';
   19 = 'WINCE';
   20 = 'NCR3000';
   21 = 'NetWare';
   22 = 'OSF';
   23 = 'DC/OS';
   24 = 'Reliant UNIX';
   25 = 'SCO UnixWare';
   26 = 'SCO OpenServer';
   27 = 'Sequent';
   28 = 'IRIX';
   29 = 'Solaris';
   30 = 'SunOS';
   31 = 'U6000';
   32 = 'ASERIES';
   33 = 'TandemNSK';
   34 = 'TandemNT';
   35 = 'BS2000';
   36 = 'LINUX';
   37 = 'Lynx';
   38 = 'XENIX';
   39 = 'VM/ESA';
   40 = 'Interactive UNIX';
   41 = 'BSDUNIX';
   42 = 'FreeBSD';
   43 = 'NetBSD';
   44 = 'GNU Hurd';
   45 = 'OS9';
   46 = 'MACH Kernel';
   47 = 'Inferno';
   48 = 'QNX';
   49 = 'EPOC';
   50 = 'IxWorks';
   51 = 'VxWorks';
   52 = 'MiNT';
   53 = 'BeOS';
   54 = 'HP MPE';
   55 = 'NextStep';
   56 = 'PalmPilot';
   57 = 'Rhapsody';
   58 = 'Windows 2000';
   59 = 'Dedicated';
   60 = 'OS/390';
   61 = 'VSE';
   62 = 'TPF';
}

<##################################################################################################
################# /lib/provider/Services ###########################################################
##################################################################################################>

[hashtable]$ServiceStatusName = @{
    1 = 'Stopped';
    2 = 'StartPending';
    3 = 'StopPending';
    4 = 'Running';
    5 = 'ContinuePending';
    6 = 'PausePending';
    7 = 'Paused';
}

[hashtable]$ServiceStatus = @{
    'Stopped'         = 1;
    'StartPending'    = 2;
    'StopPending'     = 3;
    'Running'         = 4;
    'ContinuePending' = 5;
    'PausePending'    = 6;
    'Paused'          = 7;
}

[hashtable]$ServiceStartupType = @{
    'Automatic' = 2;
    'Manual'    = 3;
    'Disabled'  = 4;
}

[hashtable]$TimeSyncStatus = @{
    'NoLeapWarning'       = 0;
    'PositiveLeapSecond'  = 1;
    'NegativeLeapSecond'  = 2;
    'ClockNotSynhronized' = 3;
}

[hashtable]$TimeSyncStatusName = @{
    0 = 'NoLeapWarning';
    1 = 'PositiveLeapSecond';
    2 = 'NegativeLeapSecond';
    3 = 'ClockNotSynhronized';
}

[hashtable]$ClientMode = @{
    'Reserved'                     = 0;
    'SymmetricActive'              = 1;
    'SymmetricPassive'             = 2;
    'Client'                       = 3;
    'Server'                       = 4;
    'Broadcast'                    = 5;
    'ReservedForNTPControlMessage' = 6;
    'ReservedForPrivateUse'        = 7;
}

[hashtable]$ClientModeName = @{
    0 = 'Reserved';
    1 = 'SymmetricActive';
    2 = 'SymmetricPassive';
    3 = 'Client';
    4 = 'Client';
    5 = 'Broadcast';
    6 = 'ReservedForNTPControlMessage';
    7 = 'ReservedForPrivateUse';
}

[hashtable]$Stratum = @{
    'UnspecifiedOrUnavailable'    = 0;
    'PrimaryReference'            = 1;
    'SecondaryReferenceNTPOrSNTP' = {$_ -ge 2 -and $_ -le 15};
    'Reserved'                    = {$_ -gt 16};
}

[hashtable]$StratumTxt = @{
    0                         = 'UnspecifiedOrUnavailable';
    1                         = 'PrimaryReference';
    {$_ -ge 2 -and $_ -le 15} = 'SecondaryReferenceNTPOrSNTP';
    {$_ -gt 16}               = 'Reserved';
}

[hashtable]$DeviceAccessName = @{
    0  = 'Unknown';
    1  = 'Readable';
    2  = 'Writeable';
    3  = 'Read/Write Supported';
    4  = 'Write Once'; 
}

[hashtable]$DeviceAccess = @{
    'Unknown'              = 0;
    'Readable'             = 1;
    'Writeable'            = 2;
    'Read/Write Supported' = 3;
    'Write Once'           = 4;
}

[hashtable]$DeviceStatus = @{
    'OK'         = 'OK';
    'Erorr'      = 'Error';
    'Degraded'   = 'Degraded';
    'Unknown'    = 'Unknown';
    'PredFail'   = 'PredFail';
    'Starting'   = 'Starting';
    'Stopping'   = 'Stopping';
    'Service'    = 'Service';
    'Stressed'   = 'Stressed';
    'NonRecover' = 'NonRecover';
    'NoContact'  = 'NoContact';
    'LostComm'   = 'LostComm';
}

[hashtable]$ProviderEnums = @{
    #/lib/provider/bios
    BiosCharacteristics            = $BiosCharacteristics;
    #/lib/provider/disks
    DiskCapabilities               = $DiskCapabilities;
    DiskBusType                    = $DiskBusType;
    DiskOperationalStatus          = $DiskOperationalStatus;
    DiskOperationalStatusName      = $DiskOperationalStatusName;
    DeviceAccess                   = $DeviceAccess;
    DeviceAccessName               = $DeviceAccessName;
    DeviceStatus                   = $DeviceStatus;
    DeviceAvailability             = $DeviceAvailability;
    DeviceAvailabilityName         = $DeviceAvailabilityName;
    #/lib/provider/cluster
    ClusterEnforcedAntiAffinity    = $ClusterEnforcedAntiAffinity;
    ClusterEnforcedAntiAffinityName = $ClusterEnforcedAntiAffinityName;
    #/lib/provider/cpu
    CPUArchitecture                = $CPUArchitecture;
    CPUProcessorType               = $CPUProcessorType;
    CPUStatusInfo                  = $CPUStatusInfo;
    CPUFamily                      = $CPUFamily;
    CPUConfigManagerErrorCode      = $CPUConfigManagerErrorCode;
    CPUAvailability                = $CPUAvailability;
    CPUPowerManagementCapabilities = $CPUPowerManagementCapabilities;
    #/lib/provider/memory
    MemoryFormFactor               = $MemoryFormFactor;
    MemoryInterleavePosition       = $MemoryInterleavePosition;
    MemoryMemoryType               = $MemoryMemoryType;
    MemoryTypeDetail               = $MemoryTypeDetail;
    #/lib/provider/windows
    WindowsOSProductSuite          = $WindowsOSProductSuite;
    WindowsProductType             = $WindowsProductType;
    WindowsOSType                  = $WindowsOSType;
    #/lib/provider/services
    ServiceStatus                  = $ServiceStatus;
    ServiceStatusName              = $ServiceStatusName;
    ServiceStartupType             = $ServiceStartupType;
    #/lib/provider/NtpChecks
    TimeSyncStatus                 = $TimeSyncStatus;
    TimeSyncStatusName             = $TimeSyncStatusName;
    ClientMode                     = $ClientMode;
    ClientModeName                 = $ClientModeName;
    Stratum                        = $Stratum;
    StratumTxt                     = $StratumTxt;    
}

Export-ModuleMember -Variable @('ProviderEnums');
