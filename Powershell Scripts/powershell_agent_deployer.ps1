# Path to the agent and configuration files
$AgentFilePath = "C:\path\to\velociraptor_agent.exe"
$ConfigFilePath = "C:\path\to\config.yaml"
$DestinationPath = "C:\Windows\Temp"

# Take in domain credentials
$Creds = Get-Credential -Message "Enter domain credentials"

# Get all computers in the domain from the Domain Controller
$DC = "YourDomainControllerNameOrIP"  # Replace with your DC's hostname or IP
$Computers = Invoke-Command -ComputerName $DC -Credential $Creds -ScriptBlock {
    Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
}

# Function to push files and execute agent
function Deploy-Agent {
    param (
        [string]$ComputerName
    )

    try {
        # Create a remote PowerShell session with domain credentials
        $session = New-PSSession -ComputerName $ComputerName -Credential $Creds

        # Ensure the destination directory exists on the remote host
        Invoke-Command -Session $session -ScriptBlock {
            New-Item -Path "C:\temp" -ItemType Directory -Force
        }

        # Copy the files to the remote host
        Copy-Item -Path $AgentFilePath -Destination $DestinationPath -ToSession $session -Force
        Copy-Item -Path $ConfigFilePath -Destination $DestinationPath -ToSession $session -Force

        # Verify if the files are there
        $AgentExists = Invoke-Command -Session $session -ScriptBlock {
            Test-Path -Path "$DestinationPath\velociraptor_agent.exe"
        }
        $ConfigExists = Invoke-Command -Session $session -ScriptBlock {
            Test-Path -Path "$DestinationPath\config.yaml"
        }

        if ($AgentExists -and $ConfigExists) {
            Write-Host "Files are successfully copied to $ComputerName. Executing agent..."

            # Execute the agent on the remote host
            Invoke-Command -Session $session -ScriptBlock {
                Start-Process -FilePath "$DestinationPath\velociraptor_agent.exe" -ArgumentList "--config C:\temp\config.yaml" -NoNewWindow -Wait
            }
        } else {
            Write-Host "Failed to verify files on $ComputerName."
        }

        # Close the remote session
        Remove-PSSession -Session $session
    }
    catch {
        Write-Host "Error deploying to $ComputerName: $_"
    }
}

# Loop through each computer and deploy the agent
foreach ($Computer in $Computers) {
    Deploy-Agent -ComputerName $Computer
}

Write-Host "Deployment complete."
