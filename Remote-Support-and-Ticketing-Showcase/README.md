# Remote Support and Ticketing Showcase

## The problem
Most Tier 1 issues are fixed remotely, and the quality of the ticket notes decides how fast the next analyst can help. Poor notes mean repeated questions, slow escalations and unhappy users.

## What it does
- Five PowerShell tools to diagnose and fix common issues on a remote client
- A ticketing setup with categories, priorities and SLAs
- Ten complete tickets written to a clear standard, including one escalation
- A 15-article knowledge base published as a website on Azure Static Web Apps through GitHub Actions

## Tech used
PowerShell remoting (WinRM), Quick Assist, osTicket or Zammad, Markdown, Python, Azure Static Web Apps, GitHub Actions

## Setup
1. Build the lab: [../docs/lab-setup-guide.md](../docs/lab-setup-guide.md). Make sure `Enable-PSRemoting -Force` was run on CLIENT01.
2. From DC01: `Test-WSMan CLIENT01`
3. Run the tools from `src/`:

| Script | Fixes |
|---|---|
| `Get-ClientHealth.ps1` | First look: uptime, disk, memory, stopped services, recent errors |
| `Clear-DiskSpace.ps1` | Full disk |
| `Reset-PrintQueue.ps1` | Stuck print jobs |
| `Repair-OutlookProfile.ps1` | Outlook won't open or keeps crashing (run in the user's session) |
| `Get-StartupImpact.ps1` | Slow startup |
| `Test-MappedDrive.ps1` | Missing mapped drive |

4. Ticketing tool: [docs/ticketing-setup.md](docs/ticketing-setup.md)
5. Knowledge base site: create an Azure Static Web App (Free plan, "Other" deployment source), add its deployment token as the GitHub secret `AZURE_STATIC_WEB_APPS_API_TOKEN`, then push. The workflow in `.github/workflows/` builds and deploys it.

Build the site locally:
```bash
pip install markdown
python src/build_kb_site.py
```

## Tickets
| Ticket | Issue | Priority |
|---|---|---|
| [TKT-001](tickets/TKT-001.md) | Account locked out before month-end | P2 |
| [TKT-002](tickets/TKT-002.md) | Mailbox full, can't send | P3 |
| [TKT-003](tickets/TKT-003.md) | Shared mailbox not showing | P3 |
| [TKT-004](tickets/TKT-004.md) | Teams sign-in loop | P3 |
| [TKT-005](tickets/TKT-005.md) | Printer jobs stuck | P3 |
| [TKT-006](tickets/TKT-006.md) | Mapped drive missing | P3 |
| [TKT-007](tickets/TKT-007.md) | Slow laptop | P4 |
| [TKT-008](tickets/TKT-008.md) | New phone, MFA not working | P2 |
| [TKT-009](tickets/TKT-009.md) | New starter setup | P3 |
| [TKT-010](tickets/TKT-010.md) | Several users can't open the Finance share (escalated) | P2 |

Writing standard: [docs/ticket-writing-standard.md](docs/ticket-writing-standard.md)

## Screenshots
| File | Shows |
|---|---|
| `screenshots/01-client-health.png` | Health check output against CLIENT01 |
| `screenshots/02-disk-before-after.png` | Free space before and after cleanup |
| `screenshots/03-print-queue-reset.png` | Spooler reset |
| `screenshots/04-ticketing-sla.png` | SLA plans in the ticketing tool |
| `screenshots/05-ticket-example.png` | A completed ticket |
| `screenshots/06-knowledge-base-site.png` | Published knowledge base |

## What I learned
<your notes>

## Challenges
<your notes>

## Future improvements
- Search on the knowledge base site
- Link each ticket category to its knowledge base article automatically

## Data notice
All tickets, names and details are synthetic.
