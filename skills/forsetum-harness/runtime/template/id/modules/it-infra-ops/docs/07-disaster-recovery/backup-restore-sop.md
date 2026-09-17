# SOP Pencadangan & Pemulihan Bencana (Backup & DR) — {{PROJECT_NAME}}

## 1. Kebijakan Pencadangan (Backup Policy)

Infrastruktur `{{INFRA_ENVIRONMENT}}` menerapkan strategi pencadangan 3-2-1 yang disesuaikan untuk lingkungan on-premises:
- 3 Salinan data (1 data produksi aktif, 2 salinan cadangan).
- 2 Media penyimpanan berbeda (Disk lokal dan penyimpanan jaringan).
- 1 Salinan di lokasi terpisah / media terisolasi: `{{BACKUP_DESTINATION}}`.

## 2. Jadwal & Frekuensi Pencadangan

| Jenis Data | Metode Pencadangan | Frekuensi | Retensi Penyimpanan |
|---|---|---|---|
| **Basis Data Relasional** | Dump SQL logis terkompresi | Setiap hari pukul 01:00 WIB | 30 Hari |
| **Berkas Konfigurasi (`/etc`)** | Arsip tar.gz terenkripsi | Setiap hari pukul 02:00 WIB | 14 Hari |
| **Snapshot VM Penuh** | Hypervisor VM snapshot / image | Setiap minggu di `{{MAINTENANCE_WINDOW}}` | 4 Minggu |

## 3. Prosedur Uji Pemulihan (Restoration Drill)

Pencadangan dianggap tidak sah jika tidak pernah diuji pemulihannya. Lakukan simulasi pemulihan setiap kuartal:

1. **Persiapan:** Siapkan VM staging / uji coba yang terisolasi dari jaringan produksi.
2. **Pengambilan Arsip:** Salin berkas cadangan dari `{{BACKUP_DESTINATION}}` ke mesin staging.
3. **Restorasi:** Lakukan proses impor data (misal: `pg_restore` atau `tar -xzvf`).
4. **Verifikasi:** Lakukan query penghitungan baris data (*row count*) dan verifikasi konsistensi relasi data.
5. **Dokumentasi:** Catat durasi waktu pemulihan aktual (*Recovery Time Actual*) dan bandingkan dengan target RTO/RPO.
