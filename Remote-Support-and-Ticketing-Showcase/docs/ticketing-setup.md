# Ticketing Tool Setup

Use **osTicket** (self-hosted, free) on a small Linux VM in `lab-vnet`, or the **Zammad** hosted trial.

## Categories (help topics)
Password · Email · Hardware · Network · Access · Software

## Priorities and SLAs

| Priority | Meaning | Example | First response | Resolve |
|---|---|---|---|---|
| P1 | Critical: many users or a key system down | Email down for everyone | 1 hour | 4 hours |
| P2 | High: one user fully blocked, or a team affected | Locked out on a deadline day | 4 hours | 8 hours |
| P3 | Medium: user can work with a workaround | Printer not working, other printer available | 8 hours | 24 hours |
| P4 | Low: request or minor issue | Software request, slow laptop | 24 hours | 72 hours |

## Setup steps
1. Create the six help topics above.
2. Create four SLA plans matching the table.
3. Create departments: Service Desk (Tier 1), Systems (Tier 2).
4. Auto-response template: ticket number, priority, expected response time, link to the IT Help Centre.
5. Canned responses for the five most common fixes, each linking to a knowledge base article.
6. Configure email piping or polling so emails to the service desk mailbox create tickets (used by the AI Service Desk Assistant project).
