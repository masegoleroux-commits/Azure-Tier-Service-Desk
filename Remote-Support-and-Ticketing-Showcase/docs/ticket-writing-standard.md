# Ticket Writing Standard

A good ticket lets **anyone** pick it up without calling the user again.

## Every ticket has
1. **Title:** what is broken and for whom. "Finance user locked out before month-end", not "Help".
2. **Caller, category, priority** set correctly (see SLA table in ticketing-setup.md).
3. **Problem:** what the user sees, in their words, with any error message exactly as shown.
4. **Impact:** who is affected and what they can't do.
5. **Troubleshooting:** numbered steps, each with its result.
6. **Resolution:** the actual fix, and the root cause if known.
7. **Customer reply:** plain English, no jargon, what was done and what to do if it happens again.
8. **Escalation note** (if escalated): what was tried, what is known, what is needed. The next tier should not have to repeat anything.

## Rules
- Never write passwords, MFA codes or personal ID numbers in a ticket.
- Record identity verification method for any account change.
- Link the knowledge base article you used, or create one if none exists.
- Update the ticket when anything changes, including "waiting for user".
