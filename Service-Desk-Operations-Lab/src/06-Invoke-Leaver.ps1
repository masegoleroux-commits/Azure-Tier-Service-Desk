<#
.SYNOPSIS
    Leaver process across Active Directory and Microsoft Entra ID with an audit log.
.DESCRIPTION
    Order matters: access is removed first, data handling comes after.
      1. Block Entra ID sign-in and revoke sessions
      2. Disable the AD account and remove group memberships
      3. Move to the Leavers OU and stamp the description
      4. Optionally convert the mailbox to shared (before licence removal)
      5. Remove licences
    Every step is logged to sample-output/leaver-audit.log, including failures.
.EXAMPLE
    .\06-Invoke-Leaver.ps1 -SamAccountName johan.botha -UserPrincipalName johan.botha@<tenant>.onmicrosoft.com -ConvertMailboxToShared
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$SamAccountName,
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [switch]$ConvertMailboxToShared,
    [string]$LogPath = (Join-Path $PSScriptRoot "..\sample-output\leaver-audit.log")
)

function Write-Audit([string]$Step, [string]$Result) {
    $line = "{0} | {1} | {2} | {3}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $SamAccountName, $Step, $Result
    Add-Content -Path $LogPath -Value $line
    $colour = if ($Result -like "FAILED*") { "Red" } else { "Green" }
    Write-Host $line -ForegroundColor $colour
}

function Invoke-Step([string]$Step, [scriptblock]$Action) {
    if (-not $PSCmdlet.ShouldProcess($SamAccountName, $Step)) { return }
    try { & $Action; Write-Audit $Step "OK" }
    catch { Write-Audit $Step "FAILED: $($_.Exception.Message)" }
}

Import-Module ActiveDirectory -ErrorAction Stop
Import-Module Microsoft.Graph.Users, Microsoft.Graph.Users.Actions -ErrorAction Stop
$domainDN = (Get-ADDomain).DistinguishedName

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome
$mg = Get-MgUser -UserId $UserPrincipalName -Property Id, AssignedLicenses -ErrorAction Stop
Write-Audit "Leaver started" "Requested by $env:USERNAME"

# 1. Cloud access first
Invoke-Step "Block Entra ID sign-in" { Update-MgUser -UserId $mg.Id -AccountEnabled:$false }
Invoke-Step "Revoke sign-in sessions" { Revoke-MgUserSignInSession -UserId $mg.Id | Out-Null }

# 2. On-premises access
$user = Get-ADUser $SamAccountName -Properties MemberOf -ErrorAction Stop
Invoke-Step "Disable AD account" { Disable-ADAccount $user }
Invoke-Step "Remove $($user.MemberOf.Count) AD group memberships" {
    foreach ($g in $user.MemberOf) { Remove-ADGroupMember -Identity $g -Members $user -Confirm:$false }
}

# 3. Housekeeping
Invoke-Step "Stamp description" { Set-ADUser $user -Description "Leaver $(Get-Date -Format yyyy-MM-dd)" }
Invoke-Step "Move to Leavers OU" { Move-ADObject $user.DistinguishedName -TargetPath "OU=Leavers,OU=Company,$domainDN" }

# 4. Mailbox (must happen before licence removal to keep the data)
if ($ConvertMailboxToShared) {
    Invoke-Step "Convert mailbox to shared" {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        Connect-ExchangeOnline -ShowBanner:$false
        Set-Mailbox -Identity $UserPrincipalName -Type Shared
    }
}

# 5. Licences
if ($mg.AssignedLicenses) {
    Invoke-Step "Remove $($mg.AssignedLicenses.Count) licence(s)" {
        Set-MgUserLicense -UserId $mg.Id -AddLicenses @() -RemoveLicenses @($mg.AssignedLicenses.SkuId) | Out-Null
    }
} else {
    Write-Audit "Remove licences" "None assigned"
}

Write-Audit "Leaver finished" "Review log for any FAILED steps"
