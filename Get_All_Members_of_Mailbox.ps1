# Import necessary modules if required
# Import-Module Exchange
# Import-Module ActiveDirectory

# Function to get all AD group members recursively
function Get-ADGroupMembersRecursive {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    $groupMembers = Get-ADGroupMember -Identity $GroupName -Recursive
    return $groupMembers
}

# Setup your Exchange session if remote (uncomment if needed)
# $UserCredential = Get-Credential
# $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<ExchangeServerFQDN>/PowerShell/ -Authentication Kerberos -Credential $UserCredential
# Import-PSSession $Session -DisableNameChecking

# Prompt for the mailbox name
$mailbox = Read-Host -Prompt "Enter the name of the mailbox"

# Initialize array to hold final list of users
$userList = @()

# Get all permissions on the mailbox
$permissions = Get-MailboxPermission -Identity $mailbox

# Loop through each permission and resolve users and groups
foreach ($permission in $permissions) {
    $identity = $permission.User.ToString()
    if ($identity -eq 'NT AUTHORITY\SELF') {
        continue
    }
    
    # Check if the identity is a group or a user
    $object = Get-ADObject -Filter {SamAccountName -eq $identity.Split('\')[-1]} -Properties objectClass
    if ($object.objectClass -eq 'group') {
        $groupMembers = Get-ADGroupMembersRecursive -GroupName $object.DistinguishedName
        $userList += $groupMembers | Select-Object -ExpandProperty SamAccountName
    }
    else {
        $userList += $identity.Split('\')[-1]
    }
}

# Export the user list to CSV
$userList | Select-Object @{Name='Username'; Expression={$_}} | Export-Csv -Path "$($mailbox)_Permissions.csv" -NoTypeInformation

# Uncomment to remove the session if you created one
# Remove-PSSession $Session

Write-Host "Exported to $($mailbox)_Permissions.csv"
