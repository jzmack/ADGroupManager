##function to check AD groups for a user
function Global:CheckGroups {
    param (
        [string]$name, #works with both users and computers
        [string]$group,
        [switch]$list
    )
    
    if ($list) {
        $filePath = ".\userlist.txt"
        if (Test-Path $filePath) {
            $names = Get-Content $filePath
        } else {
            Write-Host "The file userlist.txt was not found in the current directory." -ForegroundColor Red
            return
        }
    } else {
        $names = @($name)
    }
    
    foreach ($n in $names) {
        $adObject = Get-ADUser -Filter { SamAccountName -eq $n } -Properties MemberOf -ErrorAction SilentlyContinue

        # if no user found, try to find as a computer
        if (-not $adObject) {
            $computerName = "$n$"  # append $ for computers
            $adObject = Get-ADComputer -Filter { SamAccountName -eq $computerName } -Properties MemberOf -ErrorAction SilentlyContinue
        }

        if (-not $adObject) {
            Write-Host "$n not found in Active Directory." -ForegroundColor Red
            continue
        }

        # determine if it's a user or computer
        $objectType = if ($adObject.ObjectClass -eq "computer") { "computer" } else { "user" }
        $objectGroups = $adObject.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }

        if ($group) {
            if ($objectGroups -contains $group) {
                Write-Host "$n ($objectType) is a member of the $group group." -ForegroundColor Green
            } else {
                Write-Host "$n ($objectType) is not a member of the $group group." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Groups for $n ($objectType):" -ForegroundColor Cyan
            $objectGroups
        }
    }
}

#function to add user to AD Group
function Global:AddToGroup {
    param (
        [string]$name,
        [string]$group,
        [switch]$list
    )
    
    if ($list) {
        $filePath = ".\userlist.txt"
        if (Test-Path $filePath) {
            $names = Get-Content $filePath
        } else {
            Write-Host "The file userlist.txt was not found in the current directory." -ForegroundColor Red
            return
        }
    } else {
        $names = @($name)
    }

    # retrieve group Distinguished Name
    $groupObject = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue
    if (-not $groupObject) {
        Write-Host "Group '$group' not found in Active Directory." -ForegroundColor Red
        return
    }
    $groupDN = $groupObject.DistinguishedName

    foreach ($n in $names) {
        # first check if it's a user
        $adObject = Get-ADUser -Filter { SamAccountName -eq $n } -ErrorAction SilentlyContinue
        # if no user found check for computer appending $
        if (-not $adObject) {
            $computerName = "$n$"
            $adObject = Get-ADComputer -Filter { SamAccountName -eq $computerName } -ErrorAction SilentlyContinue
        }
        if (-not $adObject) {
            Write-Host "$n not found in Active Directory." -ForegroundColor Red
            continue
        }
        # determine if it's a user or computer object
        $objectType = if ($adObject.ObjectClass -eq "computer") { "computer" } else { "user" }
        # check if already in the group
        $currentGroups = $adObject.MemberOf
        if ($currentGroups -contains $groupDN) {
            Write-Host "$n ($objectType) is already a member of the $group group." -ForegroundColor Yellow
            continue
        }
        # attempt to add the object to the group
        try {
            Add-ADGroupMember -Identity $groupDN -Members $adObject.SamAccountName
            Write-Host "Successfully added $n ($objectType) to the $group group." -ForegroundColor Green
        } catch {
            Write-Host "Failed to add $n ($objectType) to the $group group. Error: $_" -ForegroundColor Red
        }
    }
}

# function to remove user from AD Group
function Global:RemoveFromGroup {
    param (
        [string]$name,
        [string]$group,
        [switch]$list
    )
    if ($list) {
        $filePath = ".\userlist.txt"
        if (Test-Path $filePath) {
            $names = Get-Content $filePath
        } else {
            Write-Host "The file userlist.txt was not found in the current directory." -ForegroundColor Red
            return
        }
    } else {
        $names = @($name)
    }

    # retrieve group DN
    $groupObject = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue
    if (-not $groupObject) {
        Write-Host "Group '$group' not found in Active Directory." -ForegroundColor Red
        return
    }
    $groupDN = $groupObject.DistinguishedName

    foreach ($n in $names) {
        # first check as if it's a user
        $adObject = Get-ADUser -Filter { SamAccountName -eq $n } -ErrorAction SilentlyContinue

        # if no user found, check for a computer (append $)
        if (-not $adObject) {
            $computerName = "$n$"
            $adObject = Get-ADComputer -Filter { SamAccountName -eq $computerName } -ErrorAction SilentlyContinue
        }
        if (-not $adObject) {
            Write-Host "$n not found in Active Directory." -ForegroundColor Red
            continue
        }
        # determine if it's a user or computer
        $objectType = if ($adObject.ObjectClass -eq "computer") { "computer" } else { "user" }
        # retrieve members of the group
        $groupMembers = Get-ADGroupMember -Identity $groupDN | Select-Object -ExpandProperty SamAccountName
        # check if the user/computer is in the group
        if (-not ($groupMembers -contains $adObject.SamAccountName)) {
            Write-Host "$n ($objectType) is not a member of the $group group." -ForegroundColor Yellow
            continue
        }
        # attempt to remove the object from the group
        try {
            Remove-ADGroupMember -Identity $groupDN -Members $adObject.SamAccountName -Confirm:$false
            Write-Host "Successfully removed $n ($objectType) from the $group group." -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove $n ($objectType) from the $group group. Error: $_" -ForegroundColor Red
        }
    }
}