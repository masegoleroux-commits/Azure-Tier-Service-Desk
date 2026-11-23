<#
.SYNOPSIS
    Investigates a lockout, unlocks the account and resets the password.
.DESCRIPTION
    Shows lockout status, searches the DC Security log for event 4740 to find the
    computer causing the lockout, unlocks the account and sets a temporary password
    that must be changed at next sign-in.
    Verify the caller's identity first: docs/identity-verification-checklist.md
.EXAMPLE
    .\05-Reset-LabUserPassword.ps1 -SamAccountName thabo.mokoena
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$SamAccountName
)

Import-Module ActiveDirectory -ErrorAction Stop

$u = Get-ADUser $SamAccountName -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt, PasswordLastSet, Enabled -ErrorAction Stop
Write-Host "`n--- Account status ---" -ForegroundColor Cyan
$u | Select-Object SamAccountName, Enabled, LockedOut, BadLogonCount, LastBadPasswordAttempt, PasswordLastSet | Format-List

Write-Host "--- Lockout source (event 4740) ---" -ForegroundColor Cyan
$events = Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740 } -MaxEvents 50 -ErrorAction SilentlyContinue |
    Where-Object { $_.Properties[0].Value -eq $SamAccountName } |
    Select-Object TimeCreated, @{ n = 'CallerComputer'; e = { $_.Properties[1].Value } }
if ($events) { $events | Format-Table -AutoSize } else { Write-Host "No lockout events found for $SamAccountName." }

if ($u.LockedOut -and $PSCmdlet.ShouldProcess($SamAccountName, "Unlock")) {
    Unlock-ADAccount $SamAccountName
    Write-Host "Account unlocked." -ForegroundColor Green
}

if ($PSCmdlet.ShouldProcess($SamAccountName, "Reset password")) {
    $newPw = Read-Host "New temporary password" -AsSecureString
    Set-ADAccountPassword $SamAccountName -Reset -NewPassword $newPw
    Set-ADUser $SamAccountName -ChangePasswordAtLogon $true
    Write-Host "Password reset. User must change it at next sign-in." -ForegroundColor Green
}

if ($events) {
    Write-Host "`nNext: check saved credentials, mapped drives and mobile mail on the caller computer(s) above."
}
