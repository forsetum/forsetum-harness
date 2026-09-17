# Registry Variabel Template (Modul it-infra-ops) — {{PROJECT_NAME}}

Tabel ini mendaftarkan variabel konfigurasi spesifik untuk modul Operasional & Pemeliharaan Infrastruktur TI (`it-infra-ops`):

## 1. Variabel Khusus Modul

| Variabel | Wajib? | Nilai Template | Kegunaan |
|---|---:|---|---|
| `INFRA_ENVIRONMENT` | Ya | `{{INFRA_ENVIRONMENT}}` | Lingkungan infrastruktur (e.g. On-Premises Data Center, Private Cloud, VM Cluster) |
| `PRIMARY_OS` | Ya | `{{PRIMARY_OS}}` | Sistem operasi utama server (e.g. Ubuntu Server 22.04 LTS, Debian 12, RHEL, Windows Server) |
| `MAINTENANCE_WINDOW` | Ya | `{{MAINTENANCE_WINDOW}}` | Jadwal jendela pemeliharaan rutin resmi |
| `BACKUP_DESTINATION` | Ya | `{{BACKUP_DESTINATION}}` | Lokasi media target penyimpanan backup (e.g. NAS Lokal, NFS Mount, Offsite Storage) |

## 2. Indeks Placeholder Modul

```text
BACKUP_DESTINATION
INFRA_ENVIRONMENT
MAINTENANCE_WINDOW
PRIMARY_OS
```
