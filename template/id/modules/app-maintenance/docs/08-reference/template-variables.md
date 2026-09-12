# Registry Variabel Template (Modul app-maintenance) — {{PROJECT_NAME}}

Tabel ini mendaftarkan variabel konfigurasi spesifik untuk modul Perawatan & Modifikasi Aplikasi (`app-maintenance`):

## 1. Variabel Khusus Modul

| Variabel | Wajib? | Nilai Template | Kegunaan |
|---|---:|---|---|
| `HOST_APPLICATION` | Ya | `{{HOST_APPLICATION}}` | Nama dan versi aplikasi induk/upstream (e.g. Odoo 17, WordPress, Legacy ERP) |
| `SOURCE_MODEL` | Ya | `{{SOURCE_MODEL}}` | Model lisensi/sumber kode (e.g. Open Source Upstream, Closed Source Vendor) |
| `PRIMARY_LANGUAGE` | Ya | `{{PRIMARY_LANGUAGE}}` | Bahasa pemrograman utama modul/aplikasi |
| `EXTENSION_PATTERN` | Ya | `{{EXTENSION_PATTERN}}` | Pola ekstensi modul (e.g. Modular Plugin, Event Hook/Listener, Core Patch) |

## 2. Indeks Placeholder Modul

```text
EXTENSION_PATTERN
HOST_APPLICATION
PRIMARY_LANGUAGE
SOURCE_MODEL
```
