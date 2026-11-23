# SOP: New Starter (Joiner)

**Applies to:** Service desk analysts | **Trigger:** Approved new starter request from HR or line manager

## Before you start
- Approved request with full name, department, job title, manager, start date and office
- Start date at least 2 working days away (otherwise flag to the IT manager)

## Steps
1. Add the user to `data/users.csv` (or a new CSV with the same columns).
2. Run `02-New-LabUsers.ps1` and enter a temporary password.
3. Confirm the account is in the correct department OU.
4. Confirm the manager is set: `Get-ADUser <sam> -Properties Manager`.
5. After sync, confirm the user appears in the correct `DYN-<Department>` group in Entra ID and has a licence.
6. Send the temporary password to the **manager** by a separate channel (phone or SMS), never in the same email as the username.
7. Add the welcome guide link to the ticket and set it to Resolved.

## Done when
- [ ] Account exists in the right OU with correct department and title
- [ ] Manager set
- [ ] Licence assigned through group membership
- [ ] Credentials shared securely with the manager
