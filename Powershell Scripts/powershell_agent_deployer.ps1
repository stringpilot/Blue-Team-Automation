# Path to the agent and configuration files
$AgentFilePath = "C:\path\to\velociraptor_agent.exe"
$ConfigFilePath = "C:\path\to\config.yaml"
$DestinationPath = "C$\temp"

# Take in domain credentials
$Creds = Get-Credential -Message "Enter domain credentials"

# Function to push files and execute agent
function Deploy-Agent {
    param (
        [string]$ComputerName
    )

    try {
        # Copy the files to the remote host
        Copy-Item -Path $AgentFilePath -Destination "\\$ComputerName\$DestinationPath\" -Credential $Creds -Force
        Copy-Item -Path $ConfigFilePath -Destination "\\$ComputerName\$DestinationPath\" -Credential $Creds -Force

        # Verify if the files are there
        $AgentExists = Test-Path -Path "\\$ComputerName\$DestinationPath\velociraptor_agent.exe"
        $ConfigExists = Test-Path -Path "\\$ComputerName\$DestinationPath\config.yaml"

        if ($AgentExists -and $ConfigExists) {
            Write-Host "Files are successfully copied to $ComputerName. Executing agent..."

            # Execute the agent on the remote host
            Invoke-Command -ComputerName $ComputerName -Credential $Creds -ScriptBlock {
                Start-Process -FilePath "C:\temp\velociraptor_agent.exe" -ArgumentList "-c C:\temp\config.yaml" -NoNewWindow -Wait
            }
        } else {
            Write-Host "Failed to verify files on $ComputerName."
        }
    }
    catch {
        Write-Host "Error deploying to $ComputerName: $_"
    }
}

# Get all computers in the domain
$Computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Create a runspace pool for multi-threading
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$RunspacePool.Open()
$Runspaces = @()

foreach ($Computer in $Computers) {
    $Runspace = [powershell]::Create().AddScript({
        param ($ComputerName)
        Deploy-Agent -ComputerName $ComputerName
    }).AddArgument($Computer)
    $Runspace.RunspacePool = $RunspacePool
    $Runspaces += [PSCustomObject]@{ Pipe = $Runspace; Status = $Runspace.BeginInvoke() }
}

# Wait for all threads to complete
foreach ($Runspace in $Runspaces) {
    $Runspace.Pipe.EndInvoke($Runspace.Status)
    $Runspace.Pipe.Dispose()
}

# Close the runspace pool
$RunspacePool.Close()
$RunspacePool.Dispose()

Write-Host "Deployment complete."
