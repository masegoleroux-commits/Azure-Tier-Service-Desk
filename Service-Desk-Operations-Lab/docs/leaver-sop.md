# SOP: Leaver

**Trigger:** Approved leaver notice from HR. For urgent or hostile exits, run immediately and notify the IT manager.

## Before you start
- Confirm the leaving date and time with HR
- Ask the manager: should the mailbox be kept (convert to shared) and who needs access?
- Ask the manager who should receive the user's files

## Steps
1. Run:
   ```powershell
   .\06-Invoke-Leaver.ps1 -SamAccountName <sam> -UserPrincipalName <upn> -ConvertMailboxToShared
   ```
2. Open `sample-output/leaver-audit.log` and check for any `FAILED` lines. Fix those by hand.
3. If the mailbox was converted, give the manager access with `07-Exchange-Ticket-Fixes.ps1 -Fix SharedMailbox`.
4. Collect the device and record the asset return on the ticket.
5. Attach the audit log to the ticket and resolve.

## Order of steps
Access is removed **first** (block sign-in, revoke sessions), then data is handled. If the script stops halfway, the user is already locked out.

## Done when
- [ ] Sign-in blocked and sessions revoked
- [ ] AD account disabled and in Leavers OU
- [ ] Groups removed
- [ ] Mailbox handled as agreed
- [ ] Licences removed
- [ ] Audit log attached to the ticket
