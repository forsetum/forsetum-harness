# SOP Triage Bug & Pencegahan Regresi — {{PROJECT_NAME}}

## 1. Alur Kerja Perbaikan Bug (Bug Triage Workflow)

Setiap laporan bug pada `{{HOST_APPLICATION}}` wajib diselesaikan melalui 4 tahap disiplin:
**Reproduksi → Isolasi Akar Masalah → Patch Bedah Minimal → Verifikasi Non-Regresi**.

## 2. Prosedur 4 Tahap

### Tahap 1: Reproduksi Bug (Reproduction Steps)
- Dilarang membuat kesimpulan atau mengubah kode sebelum bug berhasil direproduksi di lingkungan staging / lokal.
- Catat: Masukan (*inputs*), status data sebelum kejadian, pesan kesalahan (*stack trace*), dan perilaku yang diharapkan.

### Tahap 2: Analisis Akar Masalah (Root Cause Analysis - RCA)
- Telusuri alur eksekusi pada `{{PRIMARY_LANGUAGE}}`.
- Bedakan apakah masalah bersumber dari kode modul kustom, kesalahan konfigurasi, inkonsistensi data lama, atau bug upstream.

### Tahap 3: Patch Bedah Minimal (Surgical Patch)
- Perubahan kode wajib seminimal mungkin (*atomic & surgical*).
- Hindari refactoring luas saat memperbaiki bug darurat.

### Tahap 4: Verifikasi Non-Regresi (Regression Checklist)
Sebelum rilis ke lingkungan produksi:
- [ ] Pengujian kasus kegagalan awal kini berhasil (*failing test now passes*).
- [ ] Seluruh alur kerja standar di sekitar area perbaikan diuji dan berjalan normal.
- [ ] Tidak ada query database yang memicu lonjakan penggunaan memori atau CPU.
