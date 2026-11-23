# SOP: MFA Method Reset (Lost or New Phone)

## Steps
1. **Verify identity** with [identity-verification-checklist.md](identity-verification-checklist.md). MFA resets are high-risk; use manager callback.
2. Entra admin centre > Users > select user > **Authentication methods**.
3. **Lost phone:** delete the old Microsoft Authenticator and phone methods. Select **Require re-register multifactor authentication**. Select **Revoke multifactor authentication sessions**.
4. **New phone (old phone still available):** guide the user to add the new device at https://mysignins.microsoft.com/security-info, then remove the old one.
5. Ask the user to sign in and register at https://aka.ms/mfasetup.
6. Check **Sign-in logs** to confirm a successful sign-in with MFA.

## Checking a blocked sign-in
Entra admin centre > Users > Sign-in logs > filter by user. Note:
- **Failure reason** (for example, wrong password, MFA denied, blocked by Conditional Access)
- **Location and IP** (unexpected country = possible compromise, escalate to security)
- **Conditional Access** tab (which policy blocked it)

## SSPR and MFA settings in this lab
- Entra admin centre > Protection > Password reset: enabled for the `DYN-IT` pilot group, two methods required
- Authentication methods policy: Microsoft Authenticator and SMS enabled
