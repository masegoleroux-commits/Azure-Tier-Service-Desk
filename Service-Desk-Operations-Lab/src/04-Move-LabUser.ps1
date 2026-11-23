<#
.SYNOPSIS
    Mover process: changes a user's department, title and OU.
.DESCRIPTION
    Records the user's groups before the move, updates the department and title,
    moves the account to the new department OU and appends to sample-output/mover-log.csv.
    Entra ID dynamic groups update automatically once the change syncs.
.EXAMPLE
    .\04-Move-LabUser.ps1 -SamAccountName sipho.nkosi -NewDepartment Finance -NewTitle "Junior Accountant"
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$SamAccountName,
    [Parameter(Mandatory)][ValidateSet("Finance", "Sales", "IT")][string]$NewDepartment,
    [string]$NewTitle,
    [string]$LogPath = (Join-Path $PSScriptRoot "..\sample-output\mover-log.csv")
)

Import-Module ActiveDirectory -ErrorAction Stop
$domainDN = (Get-ADDomain).DistinguishedName
$user     = Get-ADUser $SamAccountName -Properties Department, Title, MemberOf -ErrorAction Stop
$before   = $user.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }

if ($PSCmdlet.ShouldProcess($SamAccountName, "Move to $NewDepartment")) {
    $set = @{ Department = $NewDepartment }
    if ($NewTitle) { $set.Title = $NewTitle }
    Set-ADUser $user @set
    Move-ADObject $user.DistinguishedName -TargetPath "OU=$NewDepartment,OU=Company,$domainDN"

    [PSCustomObject]@{
        Date          = Get-Date -Format "yyyy-MM-dd HH:mm"
        User          = $SamAccountName
        OldDepartment = $user.Department
        NewDepartment = $NewDepartment
        OldTitle      = $user.Title
        NewTitle      = $(if ($NewTitle) { $NewTitle } else { $user.Title })
        GroupsBefore  = ($before -join "; ")
    } | Export-Csv $LogPath -Append -NoTypeInformation

    Write-Host "$SamAccountName moved from $($user.Department) to $NewDepartment." -ForegroundColor Green
    Write-Host "Review on-premises group memberships; Entra dynamic groups update after sync."
}
