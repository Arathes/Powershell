# Import necessary modules if required
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

# Prompt for the public folder name
$publicFolder = Read-Host -Prompt "Enter the name of the public folder"

# Initialize array to hold final list of users
$userList = @()

# Get all permissions on the public folder
$permissions = Get-PublicFolderClientPermission -Identity $publicFolder

# Loop through each permission and resolve users and groups
foreach ($permission in $permissions) {
    $identity = $permission.User.DisplayName
    if ($identity -eq 'Default' -or $identity -eq 'Anonymous') {
        continue
    }

    # Check if the identity is a group or a user
    $object = Get-ADObject -Filter {Name -eq $identity} -Properties objectClass
    if ($object.objectClass -eq 'group') {
        $groupMembers = Get-ADGroupMembersRecursive -GroupName $object.DistinguishedName
        $userList += $groupMembers | Select-Object -ExpandProperty SamAccountName
    }
    else {
        $userList += $identity
    }
}

# Export the user list to CSV
$userList | Select-Object @{Name='Username'; Expression={$_}} | Export-Csv -Path "${publicFolder}_Permissions.csv" -NoTypeInformation

Write-Host "Exported to ${publicFolder}_Permissions.csv"
