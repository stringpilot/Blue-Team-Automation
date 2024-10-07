#Note: This script uses Active Directory module
#Note: This is used to query all IP within the reah of the script

# Import Active Directory module
Import-Module ActiveDirectory

# Get all computers from Active Directory
$computers = Get-ADComputer -Filter * -Property Name | Select-Object -ExpandProperty Name

# Create an array to store the results
$computerIPs = @()

# Loop through each computer to get its IP address
foreach ($computer in $computers) {
    # Use Test-Connection to get the IP address
    $pingResult = Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue

    if ($pingResult) {
        $ipAddress = $pingResult.IPv4Address.IPAddressToString
        $computerIPs += [PSCustomObject]@{
            ComputerName = $computer
            IPAddress    = $ipAddress
        }
    } else {
        $computerIPs += [PSCustomObject]@{
            ComputerName = $computer
            IPAddress    = "Not reachable"
        }
    }
}

# Display the results
$computerIPs | Format-Table -AutoSize
