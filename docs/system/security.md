# Security

- `SecurityCenterService` manages sessions, device trust, and login history.
- Permission: `security.manage`.
- Remote tables: `security_sessions`, `device_registrations`, `login_history_entries`.
- RLS: tenant-scoped via JWT `tenant_id`.
