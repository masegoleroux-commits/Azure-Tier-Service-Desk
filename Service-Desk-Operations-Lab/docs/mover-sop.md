# SOP: Department Change (Mover)

**Trigger:** Approved change from HR or the new manager

## Steps
1. Confirm the request with the user's **current** manager or HR.
2. Run: `.\04-Move-LabUser.ps1 -SamAccountName <sam> -NewDepartment <Dept> -NewTitle "<Title>"`
3. Check `sample-output/mover-log.csv` for the groups the user had before.
4. Remove on-premises groups from the old department that the new role should not have.
5. After sync, confirm the user has moved between `DYN-` groups in Entra ID.
6. Ask the new manager to confirm access is correct.

## Why it matters
Movers who keep old access build up permissions over time ("access creep"). Always remove, not just add.
