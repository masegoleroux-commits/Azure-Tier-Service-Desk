<#
.SYNOPSIS
    Creates a fresh Outlook profile and sets it as default, keeping the old one.
.DESCRIPTION
    Run in the affected user's own session (for example during a Quick Assist session),
    because Outlook profiles live in the user's registry hive.
    The old profile is not deleted, so you can roll back.
.EXAMPLE
    .\Repair-OutlookProfile.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$base = "HKCU:\Software\Microsoft\Office\16.0\Outlook"
if (-not (Test-Path $base)) { throw "Outlook (Office 16.0) not found for this user." }

$old = (Get-ItemProperty $base -ErrorAction SilentlyContinue).DefaultProfile
$new = "Outlook-$(Get-Date -Format yyyyMMdd-HHmm)"

if ($PSCmdlet.ShouldProcess("Outlook", "Create profile $new and set as default")) {
    Get-Process outlook -ErrorAction SilentlyContinue | Stop-Process -Force
    New-Item -Path "$base\Profiles\$new" -Force | Out-Null
    Set-ItemProperty $base -Name DefaultProfile -Value $new
    Write-Host "Old default profile: $old"
    Write-Host "New default profile: $new" -ForegroundColor Green
    Write-Host "Open Outlook; it will set up the mailbox automatically."
    Write-Host "Roll back: Set-ItemProperty '$base' -Name DefaultProfile -Value '$old'"
}
