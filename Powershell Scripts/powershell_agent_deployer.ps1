# Path to the agent and configuration files
$AgentFilePath = "C:\Windows\Temp\velo.exe"
$DestinationPath = "C:\Windows\Temp\velo.exe"

# Get user credentials
$UserCreds = Get-Credential -Message "Enter credentials here: "

# Create array of IP addresses to deploy agents
$array_IP = @("192.168.56.11", "192.168.56.12", "192.168.56.22", "192.168.56.23")  # Replace with your list of target IPs

# Function to deploy agent to remote machines
foreach ($ip in $array_IP) {
    try {
        # Create a new session to the remote machine
        $session = New-PSSession -ComputerName $ip -Credential $UserCreds

        # Copy the agent and configuration file to the remote host
        Copy-Item -Path $AgentFilePath -Destination "$DestinationPath" -ToSession $session

	
	#If copy does not work use this instead:
	
	    #Invoke-WebRequest -Uri "http://192.168.56.127:8112/win-agent.exe" -OutFile "C:\Windows\Temp\velo.exe"

        # Execute the agent installation on the remote host
        Invoke-Command -Session $session -ScriptBlock {
            param ($DestinationPath)
            Start-Process -FilePath $DestinationPath `
                          -ArgumentList "service install" `
                          -NoNewWindow -Wait -PassThru
        } -ArgumentList $DestinationPath

        # Start the agent service on the remote host
        Invoke-Command -Session $session -ScriptBlock {
            param ($DestinationPath)
            Start-Process -FilePath $DestinationPath `
                          -ArgumentList "service start" `
                          -NoNewWindow -Wait -PassThru
        } -ArgumentList $DestinationPath
    }
    catch {
        Write-Host "Error deploying to '$ip': $_"
    }
    finally {
        # Clean up the session
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}
