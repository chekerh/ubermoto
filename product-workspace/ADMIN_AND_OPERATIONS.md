## Admin and operations

### Daily ops workflows
- Review driver registrations + document approvals
- Monitor delivery SLA metrics + surge rules
- Handle support tickets (triage → resolve → CSAT)
- Publish announcements and update FAQ

### Incident basics
- Health endpoint alerts (DB down, error rate spike)
- Billing webhooks backlog alert
- Notification failures (FCM)
- Runbook: acknowledge, mitigate, communicate, postmortem

### Auditability
- All sensitive admin actions write `AuditLog`
- Billing webhook processing writes `WebhookEvent` + audit entries

### Support tooling
- Ticket templates/macros
- Reference linking: ticket → order/delivery/user

