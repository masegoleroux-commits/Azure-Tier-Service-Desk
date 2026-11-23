# AI Service Desk Assistant

## The problem
A large share of service desk calls are simple "how do I" questions already answered in the knowledge base. Users wait in the queue for them, and voicemails left out of hours sit unread until someone types them up.

## What it does
- A Copilot Studio agent in Microsoft Teams that answers IT questions **only** from the 15 knowledge base articles
- When it can't help, it collects the user's name, device, category and description and creates a ticket through Power Automate
- A Python tool that transcribes a voicemail with Azure AI Speech and turns it into a structured ticket with Azure OpenAI

## Architecture
```
User in Teams ──► Copilot Studio agent ──► Knowledge: 15 KB articles
                        │ can't answer
                        ▼
                 Power Automate flow ──► email to ticketing tool ──► ticket
                        └──────────────► Teams channel card

Voicemail (.wav) ──► Azure AI Speech (en-ZA) ──► transcript
                                                   │
                                                   ▼
                                     Azure OpenAI (JSON output) ──► ticket fields
```

## Tech used
Microsoft Copilot Studio, Power Automate, Microsoft Teams, Azure AI Speech, Azure OpenAI (gpt-4o-mini), Python

## Setup
### Part A: Teams agent
Follow [copilot-studio/agent-setup.md](copilot-studio/agent-setup.md).

### Part B: Escalation flow
Follow [power-automate/flow-design.md](power-automate/flow-design.md).

### Part C: Voicemail-to-ticket
```bash
cd voicemail-to-ticket
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install -r requirements.txt
copy .env.example .env        # then fill in your keys
python transcribe_voicemail.py samples\vm01.wav
```
Record your own sample voicemails using the scripts in [voicemail-to-ticket/samples/voicemail-scripts.md](voicemail-to-ticket/samples/voicemail-scripts.md). They use fictional names and numbers only.

## Testing
[tests/accuracy-test.md](tests/accuracy-test.md): 20 questions, including 5 the knowledge base can't answer, to check the agent escalates instead of guessing.

## Guardrails
- The agent answers only from approved articles and says so when it doesn't know
- It never asks for or accepts passwords or MFA codes
- Voicemail transcripts are processed with fictional data only in this lab; in production, PII would be redacted before storage (see the Smart Ticket Triage project)
- A person reviews every generated ticket before it's worked

## Screenshots
| File | Shows |
|---|---|
| `screenshots/01-agent-knowledge.png` | Knowledge sources in Copilot Studio |
| `screenshots/02-teams-answer.png` | Agent answering in Teams |
| `screenshots/03-teams-escalation.png` | Agent collecting details and logging a ticket |
| `screenshots/04-flow-run.png` | Successful Power Automate run |
| `screenshots/05-voicemail-ticket.png` | Voicemail script output |

## Results
| Measure | Result |
|---|---|
| Questions answered correctly (of 15 answerable) | <fill in> |
| Unanswerable questions correctly escalated (of 5) | <fill in> |
| Voicemail fields extracted correctly (of 5 samples) | <fill in> |

## What I learned
<your notes>

## Future improvements
- Let the agent check ticket status
- Add authentication so the agent can trigger SSPR links for the signed-in user

## Data notice
All names, phone numbers and voicemails are synthetic.
