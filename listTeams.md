# Microsoft Teams Administration Scripts

## Overview

These PowerShell scripts are designed to retrieve and display comprehensive data about Microsoft Teams in your tenant. The scripts provide detailed information including:

- Team names and IDs
- Team owners and members  
- Associated channels for each team

## Target Audience

These scripts are intended for:
- System administrators
- IT professionals
- Individuals responsible for managing Microsoft Teams environments
- Those overseeing large or complex organizations

## Use Cases

The scripts are particularly useful for:
- **Audits** - Get complete overview of Teams structure
- **User management** - Review team memberships and ownership
- **Reporting** - Generate comprehensive Teams data
- **Administration** - Efficient management of Microsoft Teams environments

## Prerequisites

Before using these scripts, ensure you have:

- **Administrative permissions** to access Microsoft Teams data in your tenant
- **PowerShell Teams module** installed on your system
- **Appropriate role assignment** (typically administrator level)

> **⚠️ Important:** You must have the necessary permissions to access Microsoft Teams data within your organization's tenant.

## Getting Started

Follow these steps to set up and run the scripts:

1. **Create the script file**
   - Copy your chosen script into a new `.ps1` file
   - This approach is easier than attempting to pass an unsigned script
   - Author the script in your preferred editor to avoid execution policy issues

2. **Prepare your environment**
   - Open Windows Terminal
   - Connect to Microsoft Teams using appropriate PowerShell commands

3. **Execute the script**
   - Run your saved `.ps1` file

## Script 1: Console Output

This script displays team information directly to the console for immediate review. The output includes team details, user roles, and channel information in a readable format.

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

## Script 2: JSON Output

For data persistence and further processing, you might want to capture the team details in a JSON file. This alternative approach:

- **Builds custom PowerShell objects** with the required properties
- **Structures multiple results** (like multiple channels in a team) as arrays
- **Exports data to JSON format** for easy integration with other systems
- **Enables data analysis** and reporting through external tools

This script creates structured data that can be used for:
- Automated reporting workflows
- Data analysis and visualization
- Integration with other management systems
- Long-term archival of Teams structure

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

