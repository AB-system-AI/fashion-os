# Monitoring

Health, sync, storage, error logs, and background jobs are captured as snapshot entities:

- `system_health_snapshots`
- `sync_monitor_snapshots`
- `storage_usage_snapshots`
- `error_log_entries`
- `background_job_status`

Services read from local repositories and enqueue sync on write.
