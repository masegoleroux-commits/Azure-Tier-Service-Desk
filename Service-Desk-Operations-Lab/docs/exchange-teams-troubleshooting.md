# Exchange Online and Teams Troubleshooting

## Mailbox full
1. `.\07-Exchange-Ticket-Fixes.ps1 -Fix MailboxSize -User <upn>`
2. If close to quota: enable the online archive, or help the user sort by size and delete or archive large items.
3. Empty Deleted Items and Recoverable Items if needed.

## Calendar delegate access
1. Confirm the request with the calendar owner.
2. `.\07-Exchange-Ticket-Fixes.ps1 -Fix CalendarDelegate -User <owner> -Delegate <delegate>`
3. The delegate adds the calendar in Outlook: Calendar > Add calendar > From address book.

## Shared mailbox not showing
1. Confirm the user should have access (approval from the mailbox owner).
2. `.\07-Exchange-Ticket-Fixes.ps1 -Fix SharedMailbox -User <upn> -SharedMailbox <shared>`
3. Wait up to 60 minutes, then restart Outlook. Still missing: add it manually under Account Settings > More Settings > Advanced.

## Unexpected forwarding
1. `.\07-Exchange-Ticket-Fixes.ps1 -Fix CheckForwarding -User <upn>`
2. Forwarding the user didn't set up is a sign of compromise: block sign-in, reset password, revoke sessions and escalate to security.

## Teams sign-in loop
1. Sign out of Teams and quit it fully (system tray > Quit).
2. **New Teams:** Settings > Apps > Microsoft Teams > Advanced options > Reset.
3. Windows Credential Manager: remove entries starting with `MicrosoftOffice` or `msteams`.
4. Confirm the user has a Teams licence in the Microsoft 365 admin centre.
5. Sign in again. Still failing: check Entra sign-in logs for the error code.
