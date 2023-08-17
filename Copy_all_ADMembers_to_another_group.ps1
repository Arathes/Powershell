# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Prompt the user for the source and destination AD groups
$sourceGroup = Read-Host -Prompt "Enter the name of the source AD group"
$destGroup = Read-Host -Prompt "Enter the name of the destination AD group"

# Function to get all members including nested groups
function Get-ADGroupMembersRecursive {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    $groupMembers = Get-ADGroupMember -Identity $GroupName

    foreach ($member in $groupMembers) {
        if ($member.objectClass -eq 'group') {
            Get-ADGroupMembersRecursive -GroupName $member.SamAccountName
        }
        else {
            $member
        }
    }
}

# Retrieve all members from the source group
$sourceMembers = Get-ADGroupMembersRecursive -GroupName $sourceGroup

# Copy each member to the destination group
foreach ($member in $sourceMembers) {
    try {
        Add-ADGroupMember -Identity $destGroup -Members $member.SamAccountName -ErrorAction Stop
        Write-Host "Added $($member.SamAccountName) to $destGroup"
    } catch {
        Write-Host "Error adding $($member.SamAccountName) to $destGroup: $_" -ForegroundColor Red
    }
}

Write-Host "Members copying process completed."
