# Communication Channels

Log/reference entities (not synced): `EmailMessage`, `SmsMessage`, `PushMessage`, `WhatsAppMessage`.

## Provider abstractions

| Interface | NoOp | Service |
|-----------|------|---------|
| `EmailProvider` | `NoOpEmailProvider` | `EmailIntegrationService` |
| `SmsProvider` | `NoOpSmsProvider` | `SmsIntegrationService` |
| `PushProvider` | `NoOpPushProvider` | `PushIntegrationService` |
| `WhatsAppProvider` | `NoOpWhatsAppProvider` | — |

Replace NoOp providers in `integrations_providers.dart` with real implementations (SendGrid, Twilio, FCM, etc.).

All outbound messages are logged via `IntegrationLogService`.
