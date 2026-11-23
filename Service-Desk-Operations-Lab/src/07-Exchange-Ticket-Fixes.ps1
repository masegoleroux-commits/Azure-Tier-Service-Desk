<#
.SYNOPSIS
    Common Exchange Online ticket fixes.
.DESCRIPTION
    Run the section that matches the ticket. Replace <tenant> with your tenant name.
.EXAMPLE
    .\07-Exchange-Ticket-Fixes.ps1 -Fix MailboxSize -User thabo.mokoena@<tenant>.onmicrosoft.com
    .\07-Exchange-Ticket-Fixes.ps1 -Fix CalendarDelegate -User thabo.mokoena@<tenant>.onmicrosoft.com -Delegate lerato.dlamini@<tenant>.onmicrosoft.com
    .\07-Exchange-Ticket-Fixes.ps1 -Fix SharedMailbox -User thabo.mokoena@<tenant>.onmicrosoft.com -SharedMailbox finance@<tenant>.onmicrosoft.com
    .\07-Exchange-Ticket-Fixes.ps1 -Fix CheckForwarding -User thabo.mokoena@<tenant>.onmicrosoft.com
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateSet("MailboxSize", "CalendarDelegate", "SharedMailbox", "CheckForwarding")][string]$Fix,
    [Parameter(Mandatory)][string]$User,
    [string]$Delegate,
    [string]$SharedMailbox
)

Import-Module ExchangeOnlineManagement -ErrorAction Stop
Connect-ExchangeOnline -ShowBanner:$false

switch ($Fix) {
    "MailboxSize" {
        Get-EXOMailboxStatistics $User | Select-Object DisplayName, ItemCount, TotalItemSize
        Get-EXOMailbox $User -Properties ProhibitSendQuota, ArchiveStatus |
            Select-Object ProhibitSendQuota, ArchiveStatus
        Write-Host "If near quota: enable the archive (Enable-Mailbox -Archive) or guide the user to clean up large items."
    }
    "CalendarDelegate" {
        if (-not $Delegate) { throw "Provide -Delegate" }
        if ($PSCmdlet.ShouldProcess($User, "Give $Delegate Editor on Calendar")) {
            Add-MailboxFolderPermission -Identity "$($User):\Calendar" -User $Delegate -AccessRights Editor
        }
        Get-MailboxFolderPermission -Identity "$($User):\Calendar"
    }
    "SharedMailbox" {
        if (-not $SharedMailbox) { throw "Provide -SharedMailbox" }
        if ($PSCmdlet.ShouldProcess($SharedMailbox, "Grant $User FullAccess and SendAs")) {
            Add-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -AutoMapping $true
            Add-RecipientPermission -Identity $SharedMailbox -Trustee $User -AccessRights SendAs -Confirm:$false
        }
        Write-Host "Auto-mapping can take up to 60 minutes to appear in Outlook."
    }
    "CheckForwarding" {
        Get-EXOMailbox $User -Properties ForwardingSmtpAddress, DeliverToMailboxAndForward |
            Select-Object DisplayName, ForwardingSmtpAddress, DeliverToMailboxAndForward
        Get-InboxRule -Mailbox $User | Where-Object { $_.ForwardTo -or $_.RedirectTo -or $_.ForwardAsAttachmentTo } |
            Select-Object Name, Enabled, ForwardTo, RedirectTo
        Write-Host "Unexpected external forwarding can mean a compromised account. Escalate to security if not requested by the user."
    }
}
