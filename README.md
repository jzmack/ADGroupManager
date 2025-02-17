# ADGroupManager

## Description
`ADGroupManager` is a module that provides functions to manage Active Directory (AD) group memberships for user and computer accounts. It includes functions to check group memberships, add users or computers to specified group, and remove users/computers from a specified group.

## Requirements

- Windows PowerShell
- Access to Active Directory Users and Computers
     - RSAT is used in this example - https://www.microsoft.com/en-us/download/details.aspx?id=45520

## Installation
Module will need installed then imported in order to use:
```powershell
Install-Module -Name ADGroupManager
Import-Module -Name ADGroupManager
#Module is now ready to use
```
### Adding to $PROFILE
For use with every PowerShell session, add the following to your PowerShell `$PROFILE` variable:
```shell
if (-not (Get-Module -Name ADGroupManager)) {
    Import-Module ADGroupManager
}
```
To find out where your $PROFILE variable is located, type the following in your terminal:
```powershell
$PROFILE # will return the path of your $PROFILE .ps1 file
```

More about PowerShell profiles - https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.5
## Usage

### CheckGroups
Checks which groups a user is a apart of. Also can check if the user or users are in a certain group.


#### Examples
To output all AD group memberships for a single user:
```powershell
CheckGroups username #replace 'username' with actual username
CheckGroups -name "username" # alternatively you can use the '-name' argument
```
To check a list of users group memberships, create a file called "userlist.txt" in local directory and fill in one user per line:
```powershell
CheckGroups -list
```
To Check if a user is part of a certain group:
```powershell
CheckGroups "username" -group "Finance" # will tell you if 'username" is in the 'Finance' group.
```

### AddToGroup
Used to add a single user or list of users to a specifed group.


#### Examples
Adding a single user to a group:
```powershell
AddToGroup -name "username" -group "name_of_group"
```
Adding many users to a group:
```powershell
AddToGroup -list -group "name_of_group" # 'userlist.txt' will need to be populated with one user per line
```

### RemoveFromGroup

Used to remove a single user or list of users from a group.

#### Examples
To remove a single user from a group:
```powershell
RemoveFromGroup -name "username" -group "name_of_group"
```
To remove many users from a group:
```powershell
RemoveFromGroup -list -group "name_of_group" # 'userlist.txt' will need to be populated
```

## Parameters
These are common across all of the functions below.
- **-name**: The name of the user or computer to check.
- **-list**: to check a list of users
- **-group**: specify which group to check against
> Note: if using `-list`, this will refer to a file called "userlist.txt" in the directory you run the function from.  This file will need to be created beforehand and populated with one user per line.

## Author

Jacob Mackin

## License

This project is licensed uner the MIT License. See LICENSE file for details.
