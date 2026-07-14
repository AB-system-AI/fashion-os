# Connectors

`IntegrationConnector` entities represent third-party integrations (email, SMS, OAuth, storage, printers).

## Service

`ConnectorService` — create, record success/failure, list connectors.

## Engine rules

- Health: disabled → unhealthy after 5 failures → degraded on stale activity
- Rate limit: per-connector `rate_limit_per_minute`
- Retry: exponential backoff; no retry on 4xx (except 429)

## Permissions

`connector.manage` required for create/update.

## Remote table

`integration_connectors`
