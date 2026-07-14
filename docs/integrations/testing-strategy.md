# Integrations Testing Strategy

## Unit tests

| File | Coverage |
|------|----------|
| `integration_connector_engine_test.dart` | Health, rate limit, retry backoff |
| `integrations_sync_processor_test.dart` | Entity → table mapping |
| `integrations_permissions_test.dart` | Permission code stability |
| `connector_service_test.dart` | Connector CRUD + success/failure |

## Run

```bash
flutter test test/features/integrations/
```

## Future

- Webhook dispatch integration tests with mock HTTP
- Import/export job end-to-end with fake `DataPortAdapter`
- OAuth flow with stub `OAuthProvider`
