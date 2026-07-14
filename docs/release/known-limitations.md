# Known Limitations — RC1

## Phase 14 — Automation

| Limitation | Impact | Workaround |
|------------|--------|------------|
| AI services are NoOp abstractions | No real LLM insights or NL queries | Wire `AIProvider` to OpenAI/Anthropic/etc. |
| Visual workflow designer not implemented | List-based workflow management only | Use rule designer for simple automations |
| Cron scheduler has no background worker | Jobs computed but not auto-executed in background | Platform worker/isolate integration in v2 |
| Webhook/email/SMS actions are stubs | Actions logged but not sent externally | Configure integrations module providers |
| Smart suggestions use heuristic rules | Not ML-based recommendations | Connect RecommendationService to AI backend |

## Phase 15 — Integrations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| All communication providers are NoOp | No real email/SMS/push delivery | Implement real providers in DI |
| OAuth flows not wired | Cannot connect Google/Microsoft/Apple accounts | Implement OAuth redirect + token storage |
| Thermal printer SDK not integrated | Printer profiles stored only | Integrate esc_pos or platform print APIs |
| GraphQL connector stub | REST only for custom connectors | Add graphql package + connector type |
| Marketplace/third-party apps UI scaffold | Connector list only | Expand marketplace in v2 |

## Phase 16 — System

| Limitation | Impact | Workaround |
|------------|--------|------------|
| MFA abstraction only | No TOTP/WebAuthn enforcement | Wire Supabase MFA or custom provider |
| Monitors are on-demand snapshots | No continuous real-time telemetry | Integrate Datadog/Sentry in production |
| License/subscription management is local | No billing provider integration | Connect Stripe/RevenueCat |
| Fraud detection hooks defined but empty | No automated fraud blocking | Implement rules in automation module |
| Performance dashboard uses cached snapshots | Not live profiling | Add DevTools integration |

## Carryover from Prior Phases

| Limitation | Module |
|------------|--------|
| Picking/packing UI scaffolds | Sales OMS |
| Accounting auto-posting partial | Sales OMS |
| OMS sales_order separate from POS sale_order | Sales/POS |
| Analytics charts are lightweight custom | Analytics |
| Report scheduling email delivery stub | Analytics |
| Invoice UI incomplete | Sales OMS |

## Platform

| Limitation | Notes |
|------------|-------|
| Route-level permission guards | Permissions enforced in services, not GoRouter redirect |
| Localization | Infrastructure ready; not all new strings in ARB files |
| CI pipeline | Not configured in repository |
