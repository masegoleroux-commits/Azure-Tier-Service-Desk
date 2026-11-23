<#
.SYNOPSIS
    Bulk-creates lab users from a CSV file and sets their managers.
.DESCRIPTION
    Reads data/users.csv, creates each user in OU=<Department>,OU=Company,
    forces a password change at first sign-in, then sets the Manager attribute.
    Existing users are skipped. Results are written to sample-output/joiner-log.csv.
.EXAMPLE
    .\02-New-LabUsers.ps1
#>
[CmdletBinding()]
param(
    [string]$CsvPath   = (Join-Path $PSScriptRoot "..\data\users.csv"),
    [string]$UpnSuffix = "lab.local",
    [string]$LogPath   = (Join-Path $PSScriptRoot "..\sample-output\joiner-log.csv")
)

Import-Module ActiveDirectory -ErrorAction Stop
$domainDN     = (Get-ADDomain).DistinguishedName
$users        = Import-Csv $CsvPath
$tempPassword = Read-Host "Temporary password for new users" -AsSecureString
$results      = @()

function Get-SamName($first, $last) {
    (("{0}.{1}" -f $first, $last) -replace "\s", "").ToLower()
}

foreach ($u in $users) {
    $sam = Get-SamName $u.FirstName $u.LastName
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        Write-Host "Exists: $sam"
        $results += [PSCustomObject]@{ User = $sam; Action = "Skipped (exists)"; Date = Get-Date -Format "yyyy-MM-dd HH:mm" }
        continue
    }

    try {
        New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
            -GivenName $u.FirstName -Surname $u.LastName `
            -DisplayName "$($u.FirstName) $($u.LastName)" `
            -SamAccountName $sam -UserPrincipalName "$sam@$UpnSuffix" `
            -Department $u.Department -Title $u.JobTitle -Office $u.Office `
            -Company "Contoso Lab" `
            -Path "OU=$($u.Department),OU=Company,$domainDN" `
            -AccountPassword $tempPassword -ChangePasswordAtLogon $true -Enabled $true -ErrorAction Stop
        Write-Host "Created: $sam" -ForegroundColor Green
        $results += [PSCustomObject]@{ User = $sam; Action = "Created"; Date = Get-Date -Format "yyyy-MM-dd HH:mm" }
    } catch {
        Write-Warning "Failed: $sam - $($_.Exception.Message)"
        $results += [PSCustomObject]@{ User = $sam; Action = "Failed: $($_.Exception.Message)"; Date = Get-Date -Format "yyyy-MM-dd HH:mm" }
    }
}

# Managers are set after all users exist
foreach ($u in $users | Where-Object { $_.Manager }) {
    $sam = Get-SamName $u.FirstName $u.LastName
    try {
        Set-ADUser $sam -Manager $u.Manager -ErrorAction Stop
    } catch {
        Write-Warning "Could not set manager for $sam - $($_.Exception.Message)"
    }
}

$results | Export-Csv $LogPath -NoTypeInformation
Write-Host "`nLog written to $LogPath"
$results | Format-Table -AutoSize
