This PowerShell script is designed to retrieve and display comprehensive data about Microsoft Teams in a tenant, 
including the names and IDs of teams, their owners, members, and associated channels.

The script is intended for use by system administrators, IT professionals, and other individuals responsible for 
managing Microsoft Teams environments, especially those overseeing large or complex organizations. By providing 
detailed insights about each team's structure and users, the script aids in the efficient management and administration 
of Microsoft Teams. It can be particularly useful during audits, user management tasks, or when a high-level overview 
of Teams structure is required.

To use the script, one must have the necessary permissions to access Microsoft Teams data in the target tenant, 
as well as the PowerShell Teams module installed. The output is provided directly to the console for immediate review 
or further processing.

Ensure that you have the necessary permissions to access Microsoft Teams data within your organization's tenant. You should typically be an administrator to use this script.

Copy the script into a new .ps1 file. This is easier than attempting to pass an unsigned script. You can author the script in your editor to avoid execution policy.

After you have created your script, open Windows Terminal, connect to Microsoft-Teams, and run your script.

``` powershell

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
```

## Alternate output - JSON

You might want to capture the details in a JSON file. You can do this simply - you would modify it to build custom PowerShell objects with the required properties. When dealing with multiple results for an object (like multiple channels in a team), you can structure your output to include an array for those results.

``` powershell

# Create an empty array to hold the team data
$teamData = @()

# Fetch each team using Get-Team
Get-Team | ForEach-Object { 

    # Assign team ID to a variable
    $currentTeamId = $_.GroupId 

    # Fetch the owners and members of the team by their roles
    $teamOwners = (Get-TeamUser -GroupId $currentTeamId -Role Owner).User
    $teamMembers = (Get-TeamUser -GroupId $currentTeamId -Role Member).User

    # Create an empty array for the channels
    $teamChannels = @()

    # Fetch each channel in the current team
    Get-TeamChannel -GroupId $currentTeamId | ForEach-Object { 
        # Create a channel object and add it to the channels array
        $teamChannels += [PSCustomObject] @{
            ChannelName = $_.DisplayName
            ChannelType = $_.MembershipType
        }
    }

    # Create a team object and add it to the team data array
    $teamData += [PSCustomObject] @{
        TeamName = $_.DisplayName
        TeamId = $currentTeamId
        Owners = $teamOwners
        Members = $teamMembers
        Channels = $teamChannels
    }
}

# Convert the team data array to JSON and write it to a file
$teamData | ConvertTo-Json -Depth 5 | Out-File 'teamData.json'

```

