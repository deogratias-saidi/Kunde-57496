# Function to delete a single management group
function Delete-ManagementGroup {
    param (
        [string]$ManagementGroupName
    )

    Write-Host "Deleting management group: $ManagementGroupName"

    # Delete the management group without checking for subscriptions
    Remove-AzManagementGroup -GroupId $ManagementGroupName
    
}


# List of management groups to delete in order
$managementGroupsToDelete = @(
    # First group of child management groups
    "alz-57496-platform-connectivity",
    "alz-57496-platform-identity",
    "alz-57496-platform-management",
    "alz-57496-landingzones-corp",
    "alz-57496-landingzones-online",
    "alz-57496-sandbox",
    "alz-57496-decommissioned",
    
    # Next, delete parent management groups
    "alz-57496-platform",
    "alz-57496-landingzones",
    
    # Finally, delete the root management group
    "alz"
)

# Delete management groups in the specified order
foreach ($mg in $managementGroupsToDelete) {
    Delete-ManagementGroup -ManagementGroupName $mg
}
