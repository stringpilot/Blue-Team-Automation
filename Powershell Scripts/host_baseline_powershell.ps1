# Define output path
$outputPath = "C:\HostBaselineSnapshot_ADDomain.txt"

# Import Active Directory module
Import-Module ActiveDirectory

# Collect system information
$osInfo = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, LastBootUpTime
$cpuInfo = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
$memoryInfo = Get-WmiObject Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed
$diskInfo = Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, FileSystem, FreeSpace, Size
$networkInfo = Get-WmiObject Win32_NetworkAdapterConfiguration | Select-Object Description, MACAddress, IPAddress

# Collect installed software
$installedSoftware = Get-WmiObject Win32_Product | Select-Object Name, Version, Vendor, InstallDate

# Collect running services
$runningServices = Get-WmiObject Win32_Service | Where-Object {$_.State -eq 'Running'} | Select-Object Name, DisplayName

# Collect domain users and groups information (Active Directory)
$adUsers = Get-ADUser -Filter * -Property Name, SamAccountName, Enabled, LastLogonDate | Select-Object Name, SamAccountName, Enabled, LastLogonDate
$adGroups = Get-ADGroup -Filter * | Select-Object Name, Description

# Collect currently logged-in users
$loggedInUsers = (Get-WmiObject Win32_ComputerSystem).UserName

# Shim cache (alternative)
$shimCache = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatibility" -ErrorAction SilentlyContinue

# Collect outbound network traffic
$outboundTraffic = netstat -an | Select-String "TCP|UDP" | Select-String ":"

# Collect net connections IP:PORTS
$netConnections = netstat -ano | Select-String "TCP|UDP" | ForEach-Object {
    $line = $_ -replace '\s+', ' '
    $parts = $line.Split(' ')
    [PSCustomObject]@{
        Protocol = $parts[1]
        LocalAddress = $parts[2]
        ForeignAddress = $parts[3]
        State = $parts[4]
        PID = $parts[5]
    }
}

# Collect admin shares
$adminShares = Get-WmiObject Win32_Share | Where-Object {$_.Type -eq 0} | Select-Object Name, Path, Description

# Collect SMB shares
$smbShares = Get-WmiObject Win32_Share | Where-Object {$_.Type -eq 2147483648} | Select-Object Name, Path, Description

# Collect security policy settings
secedit.exe /export /cfg C:\SecPol.cfg
$securityPolicy = Get-Content -Path C:\SecPol.cfg -ErrorAction SilentlyContinue

# Collect hidden files
$hiddenFiles = Get-ChildItem -Path C:\ -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Attributes -match "Hidden" }

# Collect recently deleted files (from Recycle Bin)
$recentlyDeleted = Get-ChildItem -Path "C:\$Recycle.Bin" -Recurse -ErrorAction SilentlyContinue

# Combine data into output
$output = @"
=== Operating System Information ===
$($osInfo | Out-String)

=== CPU Information ===
$($cpuInfo | Out-String)

=== Memory Information ===
$($memoryInfo | Out-String)

=== Disk Information ===
$($diskInfo | Out-String)

=== Network Adapter Information ===
$($networkInfo | Out-String)

=== Installed Software ===
$($installedSoftware | Out-String)

=== Running Services ===
$($runningServices | Out-String)

=== Domain Users ===
$($adUsers | Out-String)

=== Domain Groups ===
$($adGroups | Out-String)

=== Currently Logged-In Users ===
$($loggedInUsers | Out-String)

=== Shim Cache Information ===
$($shimCache | Out-String)

=== Outbound Network Traffic ===
$($outboundTraffic | Out-String)

=== Net Connections (IP:PORTS) ===
$($netConnections | Out-String)

=== Admin Shares ===
$($adminShares | Out-String)

=== SMB Shares ===
$($smbShares | Out-String)

=== Security Policy Settings ===
$($securityPolicy | Out-String)

=== Hidden Files ===
$($hiddenFiles | Out-String)

=== Recently Deleted Files ===
$($recentlyDeleted | Out-String)
"@

# Write to file
$output | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "Host baseline snapshot saved to $outputPath"
