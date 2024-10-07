# Define file paths
$text = 'C:\Users\Administrator\Desktop\pwnd.txt'
$destinationText = 'C:\pwned.txt'

#This script's purpose is to
#Iterate to all available Get-Computer Domains
#

# Get user credentials
$UserCreds = Get-Credential -Message "Enter credentials here: "

# Get list of computers from Active Directory
$array_IP = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# array_IP using hardcoded IP list if Get-ADComputer does not work

$array_IP = @("IP1", "IP2", "IP3")  # Replace with your list of target IPs

# Loop through each computer to deploy agents
foreach ($ip in $array_IP) {
    Write-Host "Checking connectivity to $ip..."

    # Check if the target computer is reachable
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        Write-Host "Computer $ip is reachable. Attempting to establish a session..."

        # Establish a remote session with the target machine
        $session = New-PSSession -ComputerName $ip -Credential $UserCreds -ErrorAction SilentlyContinue

        # Check if the session was created successfully
        if ($session) {
            Write-Host "Session established with $ip. Proceeding with file transfer and command execution."

            # Copy items to the target session directory
            Copy-Item -Path $text -Destination $destinationText -ToSession $session

            # Execute a command on the remote machine
            Invoke-Command -Session $session -ScriptBlock { Start-Process "cmd.exe" -ArgumentList "/c whoami" }

            # Close the session after completing tasks
            Remove-PSSession -Session $session
            Write-Host "Session with $ip closed successfully."
        } else {
            Write-Host "Failed to establish a session with $ip." -ForegroundColor Red
        }
    } else {
        Write-Host "Computer $ip is not reachable. Skipping this machine." -ForegroundColor Yellow
    }
}
