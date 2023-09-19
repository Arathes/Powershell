# Initialize variables
$domain = "example.com" # Replace with your domain
$typeofdepartment = "DeptType" # Replace with the type of department
$prefixdepartment = "prefix" # Replace with your prefix
$suffixdepartment = "suffix" # Replace with your suffix

# Sample list of departments; you can populate this dynamically if needed
$departments = @("HR", "Finance", "IT", "Sales")

# Loop through each department
foreach ($department in $departments) {
    # Build the mailbox identity and user strings
    $mailboxIdentity = "$($typeofdepartment).$($department)@$($domain)"
    $user = "$($prefixdepartment)$($department)$($suffixdepartment)"

    # Execute Add-MailboxPermission
    Add-MailboxPermission -Identity $mailboxIdentity -User $user -AccessRights FullAccess -AutoMapping $true

    # Execute Set-Mailbox
    Set-Mailbox -Identity $mailboxIdentity -MessageCopyForSendOnBehalfEnabled $true -MessageCopyForSentAsEnabled $true

    # Output status to the console
    Write-Host "Commands executed for department: $department"
}

Write-Host "Script execution complete."
