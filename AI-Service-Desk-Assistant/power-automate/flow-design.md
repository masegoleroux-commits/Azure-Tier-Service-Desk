# Power Automate Flow: Log Service Desk Ticket

## Trigger
**When Copilot Studio calls a flow** (also called "Run a flow from Copilot") with text inputs:
- `UserName`
- `Device`
- `Category`
- `Description`

## Actions
1. **Initialize variable** `TicketRef` (String) = `concat('WEB-', formatDateTime(utcNow(), 'yyyyMMdd-HHmmss'))`
2. **Send an email (V2)** (Office 365 Outlook)
   - To: the ticketing tool's intake mailbox (for example `servicedesk@<tenant>.onmicrosoft.com`)
   - Subject: `[@{triggerBody()['Category']}] @{triggerBody()['UserName']} - @{triggerBody()['Device']} (@{variables('TicketRef')})`
   - Body:
     ```
     Logged by: IT Help agent in Teams
     Reference: @{variables('TicketRef')}
     Name: @{triggerBody()['UserName']}
     Device: @{triggerBody()['Device']}
     Category: @{triggerBody()['Category']}
     Description: @{triggerBody()['Description']}
     ```
3. **Post card in a chat or channel** (Microsoft Teams)
   - Post as: Flow bot | Post in: Channel | Team: IT | Channel: Service Desk
   - Adaptive card: see `adaptive-card.json`
4. **Respond to Copilot** with output `TicketRef` = `variables('TicketRef')`

## Test
Trigger the topic in Teams and check:
- [ ] Email arrives and creates a ticket in osTicket or Zammad
- [ ] Card appears in the Service Desk channel
- [ ] The agent shows the reference to the user

## Export
My flows > the flow > **Export** > Package (.zip). Save into this folder.
