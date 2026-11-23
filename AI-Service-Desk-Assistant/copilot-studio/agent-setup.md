# Copilot Studio Agent Setup

## 1. Create the agent
1. Go to https://copilotstudio.microsoft.com and sign in with the lab tenant.
2. **Create** > **New agent** > skip the conversation and configure directly.
3. Name: **IT Help**
4. Description: Answers common IT questions for staff and logs tickets when needed.

## 2. Instructions
Paste into the **Instructions** box:

```
You are the IT Help assistant for staff.
- Answer IT questions only using the knowledge sources provided.
- Keep answers short: numbered steps where possible, and name the article you used.
- If the knowledge sources don't cover the question, say you don't have a guide for that and offer to log a ticket.
- Never ask for, accept or repeat passwords, MFA codes or ID numbers. If a user shares one, tell them not to and that they should change it.
- If the user mentions a security concern (phishing, clicked a link, account compromised), tell them to call the service desk immediately and offer to log an urgent ticket.
- Be friendly and use plain English.
```

## 3. Knowledge
1. **Knowledge** > **Add knowledge**.
2. Upload the 15 files from `Remote-Support-and-Ticketing-Showcase/knowledge-base/` (or add the published IT Help Centre URL as a public website).
3. Turn **off** "Allow the AI to use its own general knowledge" so answers come only from your articles.

## 4. Topic: Log a ticket
**Topics** > **Add a topic** > **From blank**. Name: Log a ticket.

| Node | Setting |
|---|---|
| Trigger phrases | log a ticket, raise a ticket, still not working, speak to IT, I need help from a person, report a problem |
| Question 1 | "What's your full name?" → save as `UserName` (User's entire response) |
| Question 2 | "Which device is affected? For example, your laptop name or 'phone'." → `Device` |
| Question 3 | "What type of problem is it?" → multiple choice: Password, Email, Hardware, Network, Access, Software → `Category` |
| Question 4 | "Briefly describe the problem, including any error message." → `Description` |
| Action | Call the Power Automate flow **Log Service Desk Ticket** with the four variables |
| Message | "Thanks {UserName}. Your ticket {TicketRef} has been logged and the service desk will be in touch." |
| End | End conversation |

Also edit the system **Fallback** topic to redirect to **Log a ticket** after the agent says it doesn't have a guide.

## 5. Publish to Teams
1. **Publish** > **Publish**.
2. **Channels** > **Teams and Microsoft 365 Copilot** > **Turn on Teams** > **Availability options** > share with your lab users.
3. Sign in to Teams as a lab user (for example thabo.mokoena) and test.

## 6. Export for the repo
**Solutions** (in Power Apps, https://make.powerapps.com) > select the solution containing the agent > **Export** > Managed. Save the `.zip` into this folder.
