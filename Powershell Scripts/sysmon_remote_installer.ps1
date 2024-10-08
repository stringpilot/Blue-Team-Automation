# Global Variables to be modified
$destFolder = "C:\" # Directory where exe and conf are located - ensure it ends with a backslash \
$executableName = "Sysmon64.exe" 
$configFileName = "sysmonconfig-export.xml"
$destPath = "C:\" # Where we want to place the files on the host - ensure to ends with a backslash \


##### Modifiy above this line only ----------------------------------------------------------------

# Hardcoded Globals Don't touch
$exePath = Join-Path $destfolder $executableName
$configPath = Join-Path $destFolder $configFileName
$DestExePath = Join-Path $destPath $executableName
$destConfigPath = Join-Path $destPath $configFileName

# Hardcoded IP addresses
$computers = @('192.168.56.11', "192.168.56.12", "192.168.56.22", "192.168.56.23")

$userCreds = Get-Credential -Message "Enter Credentials here: "

# Loop each computer, copy the file(s) and run the executable
foreach ($computer in $computers) {
    $session = New-PSSession -ComputerName $computer -Credential $userCreds

    #Copy-Item -Path $exePath -Destination $destPath -ToSession $session -Force 
    #Copy-Item -Path $configPath -Destination $destPath -ToSession $session -Force 
        
   # Invoke-Command -Session $session Start-Process -FilePath C:\Sysmon64.exe -ArgumentList "-accepteula -i C:\sysmonconfig-export.xml"
    Invoke-Command -Session $session -ScriptBlock {cmd.exe /C "c:\Sysmon64.exe" -accepteula -i "C:\sysmonconfig-export.xml"}
   
    
    Remove-PSSession -Session $session
}
