# Azure Tier 1 Service Desk Projects

Hands-on service desk projects built in a Microsoft Azure lab: Active Directory, Microsoft Entra ID, Microsoft 365, remote support, ticketing and Azure AI services.

## Lab environment

| Component | Details |
|---|---|
| DC01 | Windows Server 2022 domain controller for `lab.local` (AD DS, DNS, Group Policy, file shares), 10.0.1.4 |
| CLIENT01 | Domain-joined client used for support and troubleshooting |
| lab-vnet | Azure virtual network with server and client subnets |
| Microsoft 365 tenant | Entra ID, Exchange Online, Teams, Intune |
| Azure AI services | AI Language, AI Translator, AI Speech, Azure OpenAI |

Full build steps: [docs/lab-setup-guide.md](docs/lab-setup-guide.md)

## Projects

| Project | Type | Skills |
|---|---|---|
| [Service Desk Operations Lab](Service-Desk-Operations-Lab) | Core | Active Directory, Entra ID, PowerShell, Microsoft Graph, MFA, SSPR, Exchange Online, Teams, Group Policy |
| [Remote Support and Ticketing Showcase](Remote-Support-and-Ticketing-Showcase) | Core | Remote PowerShell, Quick Assist, ITSM, SLAs, ticket writing, knowledge base, Azure Static Web Apps |
| [AI Service Desk Assistant](AI-Service-Desk-Assistant) | AI | Copilot Studio, Power Automate, Azure AI Speech, Azure OpenAI |
| [Smart Ticket Triage and Multilingual Support](Smart-Ticket-Triage-and-Multilingual-Support) | AI | Azure AI Language, custom text classification, PII redaction, Azure AI Translator |

## Skills demonstrated

- **Identity:** joiner, mover and leaver automation, dynamic groups, group-based licensing, password resets, lockout investigation, MFA and SSPR support
- **Microsoft 365:** Exchange Online permissions and mailbox issues, Teams troubleshooting
- **Endpoints:** remote PowerShell health checks and fixes, Group Policy drive and printer mapping
- **Service management:** ticket quality, priorities and SLAs, escalation notes, knowledge base writing
- **AI:** grounded support assistant, speech-to-ticket, ticket classification, sentiment, PII redaction, translation

## Repository structure

```
Azure-Tier1-Service-Desk-Projects/
├── docs/lab-setup-guide.md
├── Service-Desk-Operations-Lab/
├── Remote-Support-and-Ticketing-Showcase/
├── AI-Service-Desk-Assistant/
├── Smart-Ticket-Triage-and-Multilingual-Support/
└── .github/workflows/deploy-knowledge-base.yml
```

Every project follows the same layout: `README.md`, `src/`, `docs/`, `screenshots/` and `sample-output/`.

## Data notice

All data in this repository is synthetic. Names, usernames, emails, phone numbers, ID numbers, tickets, voicemails and company details are made up for lab use and do not belong to real people or organisations. Tenant names, keys and IP addresses are placeholders.

## How these were built

<your own note here>

## Contact

<LinkedIn> | <email>
