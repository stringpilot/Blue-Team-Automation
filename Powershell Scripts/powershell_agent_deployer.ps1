# Path to the agent and configuration files
$AgentFilePath = "C:\path\to\velociraptor_agent.exe"
$ConfigFilePath = "C:\path\to\config.yaml"
$DestinationPath = "C:\Windows\Temp"

# Get user credentials
$UserCreds = Get-Credential -Message "Enter credentials here: "

# Create array of IP addresses to deploy agents
$array_IP = @("IP1", "IP2", "IP3")  # Replace with your list of target IPs

# Function to deploy agent to remote machines
foreach ($ip in $array_IP) {
    try {
        # Create a new session to the remote machine
        $session = New-PSSession -ComputerName $ip -Credential $UserCreds

        # Copy the agent and configuration file to the remote host
        Copy-Item -Path $AgentFilePath -Destination "$DestinationPath\" -ToSession $session
        Copy-Item -Path $ConfigFilePath -Destination "$DestinationPath\" -ToSession $session

        # Execute the agent installation on the remote host
        Invoke-Command -Session $session -ScriptBlock {
            Start-Process -FilePath "C:\Windows\Temp\velociraptor_agent.exe" `
                          -ArgumentList "service install --config C:\Windows\Temp\config.yaml" `
                          -NoNewWindow -Wait -PassThru
        }

        # Start the agent service on the remote host
        Invoke-Command -Session $session -ScriptBlock {
            Start-Process -FilePath "C:\Windows\Temp\velociraptor_agent.exe" `
                          -ArgumentList "service start --config C:\Windows\Temp\config.yaml" `
                          -NoNewWindow -Wait -PassThru
        }
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
