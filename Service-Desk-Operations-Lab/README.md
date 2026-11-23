# Service Desk Operations Lab

## The problem
Joiners, movers and leavers, password resets and Microsoft 365 permission requests make up most of a service desk's day. Done by hand, they are slow and steps get missed, and a missed leaver step is a security risk.

## What it does
- Bulk-creates users from a CSV into department OUs on a Windows Server 2022 domain controller
- Creates Microsoft Entra ID dynamic groups per department for group-based licensing
- Automates movers, password resets with lockout investigation, and leavers with an audit log
- Fixes common Exchange Online and Teams tickets
- Maps drives and printers by department with Group Policy
- Documents every task as a standard operating procedure (SOP)

## Architecture
```
            Microsoft 365 tenant (Entra ID, Exchange Online, Teams)
                              ▲  Microsoft Graph / Exchange Online PowerShell
                              │
  lab-vnet ───────────────────┼────────────────────────────
  │  DC01 (10.0.1.4)          │          CLIENT01         │
  │  AD DS, DNS, GPO  ────────┘   ◄─── domain-joined      │
  └───────────────────────────────────────────────────────
```

## Tech used
Windows Server 2022, Active Directory, Group Policy, PowerShell 7, Microsoft Graph PowerShell, Exchange Online PowerShell, Microsoft Entra ID, Microsoft 365

## Setup
1. Build the lab: [../docs/lab-setup-guide.md](../docs/lab-setup-guide.md)
2. Copy this folder to DC01.
3. Open PowerShell as administrator in `src/`.
4. Run the scripts in order:

| Order | Script | What it does |
|---|---|---|
| 1 | `01-New-LabOUs.ps1` | Creates Company, Finance, Sales, IT and Leavers OUs |
| 2 | `02-New-LabUsers.ps1` | Creates the 20 users in `data/users.csv` and sets managers |
| 3 | `03-New-DynamicGroups.ps1` | Creates DYN-Finance, DYN-Sales, DYN-IT in Entra ID |
| 4 | `04-Move-LabUser.ps1` | Moves a user to a new department and logs it |
| 5 | `05-Reset-LabUserPassword.ps1` | Checks lockout source, unlocks, resets password |
| 6 | `06-Invoke-Leaver.ps1` | Disables, removes access, revokes sessions, logs everything |
| 7 | `07-Exchange-Ticket-Fixes.ps1` | Mailbox size, calendar delegate, shared mailbox access |

Example runs:
```powershell
.\04-Move-LabUser.ps1 -SamAccountName sipho.nkosi -NewDepartment Finance -NewTitle "Junior Accountant"
.\05-Reset-LabUserPassword.ps1 -SamAccountName thabo.mokoena
.\06-Invoke-Leaver.ps1 -SamAccountName johan.botha -UserPrincipalName johan.botha@<tenant>.onmicrosoft.com -ConvertMailboxToShared
```

Group Policy steps: [docs/group-policy-drives-printers.md](docs/group-policy-drives-printers.md)

## Screenshots
| File | Shows |
|---|---|
| `screenshots/01-ou-structure.png` | OUs in Active Directory Users and Computers |
| `screenshots/02-bulk-users-created.png` | Script output creating users |
| `screenshots/03-dynamic-groups.png` | Dynamic group membership rule in Entra admin centre |
| `screenshots/04-mover-before-after.png` | User's department and OU before and after |
| `screenshots/05-lockout-event-4740.png` | Lockout source found in Security log |
| `screenshots/06-leaver-audit-log.png` | Leaver script output and audit log |
| `screenshots/07-sspr-mfa-settings.png` | SSPR and authentication methods |
| `screenshots/08-gpresult-report.png` | Drive mapping applied on CLIENT01 |

## SOPs
| SOP | File |
|---|---|
| Joiner | [docs/joiner-sop.md](docs/joiner-sop.md) |
| Mover | [docs/mover-sop.md](docs/mover-sop.md) |
| Leaver | [docs/leaver-sop.md](docs/leaver-sop.md) |
| Password reset and unlock | [docs/password-reset-sop.md](docs/password-reset-sop.md) |
| MFA reset | [docs/mfa-reset-sop.md](docs/mfa-reset-sop.md) |
| Identity verification | [docs/identity-verification-checklist.md](docs/identity-verification-checklist.md) |
| Exchange and Teams | [docs/exchange-teams-troubleshooting.md](docs/exchange-teams-troubleshooting.md) |
| Mapped drives and printers | [docs/group-policy-drives-printers.md](docs/group-policy-drives-printers.md) |

## Sample output
`sample-output/` holds example log formats. Replace them with the output from your own runs.

## What I learned
<your notes>

## Challenges
<your notes>

## Future improvements
- Trigger joiners and leavers from an HR system export instead of running scripts by hand
- Move to Entra ID lifecycle workflows for cloud-only users
- Add Pester tests for each script

## Data notice
All users and data are synthetic.
