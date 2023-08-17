# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Prompt the user for the AD group
$group = Read-Host -Prompt "Enter the name of the AD group"

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

# Retrieve all members from the group
$members = Get-ADGroupMembersRecursive -GroupName $group

# Extract email addresses from each member and display it
$emails = @()

foreach ($member in $members) {
    if ($member.objectClass -eq 'user') {
        $user = Get-ADUser -Identity $member.SamAccountName -Properties EmailAddress
        if ($user.EmailAddress) {
            $emails += $user.EmailAddress
        }
    }
}

if ($emails.Count -eq 0) {
    Write-Host "No email addresses found for members of $group." -ForegroundColor Yellow
} else {
    Write-Host "Email addresses for members of $group`:" -ForegroundColor Green
    $emails | ForEach-Object {
        Write-Host $_
    }
}

# Optional: If you want to copy the emails to clipboard
$emails -join ";" | Set-Clipboard

Write-Host "Email addresses copied to clipboard."
