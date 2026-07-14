# Integration Report — RC1

## Internal Cross-Module Integrations

| Source | Target | Mechanism |
|--------|--------|-----------|
| Automation | NotificationEngine | Rule actions, approval notifications |
| Automation | RuleEngine / WorkflowEngine | Core business rule/workflow execution |
| Integrations | ImportExportService | CSV/Excel import-export hub |
| Integrations | NotificationEngine | Email/SMS/push channel dispatch |
| Sales OMS | InventoryEngine | Stock reservation on order confirm |
| Sales OMS | ManufacturingEngine | Make-to-order production orders |
| Sales OMS | CRM | Credit check, customer timeline |
| Manufacturing | Inventory | Material consumption, finished goods |
| HR | Accounting | Payroll journal posting |
| POS | Accounting | Sale journal entries |
| System | AuditService | Audit explorer reads |

## External Integration Points (Abstraction Layer)

| Channel | Interface | RC1 Implementation |
|---------|-----------|-------------------|
| AI/LLM | AIProvider | NoOpAIProvider |
| Email | EmailProvider | NoOpEmailProvider |
| SMS | SmsProvider | NoOpSmsProvider |
| WhatsApp | WhatsAppProvider | NoOpWhatsAppProvider |
| Push (FCM) | PushProvider | NoOpPushProvider |
| OAuth Google | OAuthProvider | NoOpOAuthProvider |
| OAuth Microsoft | OAuthProvider | NoOpOAuthProvider |
| OAuth Apple | OAuthProvider | NoOpOAuthProvider |
| Cloud Storage | CloudStorageProvider | NoOpCloudStorageProvider |
| Webhooks | WebhookService | Outbound HTTP stub |
| Thermal Printer | PrinterService | Profile storage only |

## Connector Manager

`IntegrationConnectorEngine` provides:
- Health check per connector
- Rate limiting (configurable per minute)
- Exponential retry with 4xx non-retry
- Consecutive failure tracking

## Extension Path

Replace NoOp providers in module DI with real implementations. See:
- `docs/integrations/extension-guide.md`
- `docs/automation/extension-guide.md`
