# Template Variable Registry (it-infra-ops Module) — {{PROJECT_NAME}}

This registry defines configuration variables specific to the IT Infrastructure Operations & Maintenance (`it-infra-ops`) module:

## 1. Module Variables

| Variable | Required? | Template Value | Purpose |
|---|---:|---|---|
| `INFRA_ENVIRONMENT` | Yes | `{{INFRA_ENVIRONMENT}}` | Infrastructure environment (e.g. On-Premises Data Center, Private Cloud, VM Cluster) |
| `PRIMARY_OS` | Yes | `{{PRIMARY_OS}}` | Primary server operating system (e.g. Ubuntu Server 22.04 LTS, Debian 12, RHEL, Windows Server) |
| `MAINTENANCE_WINDOW` | Yes | `{{MAINTENANCE_WINDOW}}` | Official scheduled maintenance window |
| `BACKUP_DESTINATION` | Yes | `{{BACKUP_DESTINATION}}` | Target storage repository for backups (e.g. Local NAS, NFS Mount, Offsite Storage) |

## 2. Module Placeholder Index

```text
BACKUP_DESTINATION
INFRA_ENVIRONMENT
MAINTENANCE_WINDOW
PRIMARY_OS
```
