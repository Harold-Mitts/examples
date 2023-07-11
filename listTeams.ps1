# This PowerShell script lists all teams, owners, members, and channels in your tenant

# Fetch each team using Get-Team
Get-Team | ForEach-Object { 

    # Assign team ID to a variable
    $currentTeamId = $_.GroupId 

    # Display the name and ID of the team
    Write-Host "`nTeam Name: $($_.DisplayName), Team ID: $currentTeamId" 

    # Fetch the owners and members of the team by their roles
    $teamOwners = Get-TeamUser -GroupId $currentTeamId -Role Owner
    $teamMembers = Get-TeamUser -GroupId $currentTeamId -Role Member

    # Check if the team has owners or members
    if($teamOwners -or $teamMembers) {
        # Print the owners and members if found
        Write-Host "Owners: $($teamOwners.User)"
        Write-Host "Members: $($teamMembers.User)"
    } else {
        # Print a message if no users are found
        Write-Host "No users found"
    }

    # Fetch and display each channel in the current team
    Get-TeamChannel -GroupId $currentTeamId | ForEach-Object { 
        Write-Host "`tChannel Name, Type: $($_.DisplayName), $($_.MembershipType)" 
    } 
}
