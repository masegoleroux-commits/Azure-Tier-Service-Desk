# SOP: Password Reset and Account Unlock

## Steps
1. **Verify identity** using [identity-verification-checklist.md](identity-verification-checklist.md). Do not continue if verification fails.
2. Check if the user can use self-service password reset (SSPR) first. If yes, guide them through it instead of resetting.
3. Run: `.\05-Reset-LabUserPassword.ps1 -SamAccountName <sam>`
4. Read the lockout source. If a computer keeps locking the account, look on that computer for:
   - Saved credentials in Credential Manager
   - Mapped drives using an old password
   - Mobile phone mail app with an old password
5. Give the temporary password by phone only. The user must change it at sign-in.
6. Record the lockout cause in the ticket.

## Never
- Read a password out in an open-plan area
- Send a password by email or Teams chat
- Reset a password because someone "sounds like" the user
