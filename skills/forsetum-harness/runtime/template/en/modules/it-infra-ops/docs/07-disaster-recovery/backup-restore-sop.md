# Backup & Disaster Recovery (DR) SOP — {{PROJECT_NAME}}

## 1. Backup Strategy & Standards

The `{{INFRA_ENVIRONMENT}}` infrastructure adheres to an adapted 3-2-1 backup strategy for on-premises operations:
- 3 Copies of data (1 primary production, 2 backup copies).
- 2 Different physical media types (local high-speed disk and network volume).
- 1 Off-site or network-isolated repository: `{{BACKUP_DESTINATION}}`.

## 2. Backup Schedule & Cadence

| Data Category | Backup Method | Cadence | Retention Window |
|---|---|---|---|
| **Relational Database** | Compressed logical SQL dump | Daily at 01:00 AM | 30 Days |
| **System Configurations (`/etc`)** | Encrypted tar.gz archive | Daily at 02:00 AM | 14 Days |
| **Complete VM Snapshot** | Hypervisor VM snapshot / image | Weekly inside `{{MAINTENANCE_WINDOW}}` | 4 Weeks |

## 3. Disaster Recovery Restoration Drill

A backup that has never been restored is considered invalid. Conduct quarterly restoration drills:

1. **Isolation:** Provision an isolated staging VM disconnected from production networks.
2. **Retrieval:** Pull latest backup archives from `{{BACKUP_DESTINATION}}`.
3. **Restoration:** Execute standard restoration procedures (e.g. `pg_restore` or `tar -xzvf`).
4. **Validation:** Execute row-count checks, referential integrity tests, and service startup checks.
5. **Post-Mortem:** Record actual recovery time (RTO achieved) and compare against target SLAs.
