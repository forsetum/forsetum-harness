# Protokol Manajemen Perubahan & Jendela Pemeliharaan — {{PROJECT_NAME}}

## 1. Prinsip Manajemen Perubahan (Change Management)

Setiap perubahan konfigurasi server, pembaruan kernel OS, atau modifikasi topologi jaringan pada `{{INFRA_ENVIRONMENT}}` dilarang dilakukan secara langsung tanpa rencana terdokumentasi.

## 2. Checklist Pra-Perubahan (Pre-Flight Checklist)

Sebelum memulai eksekusi di jendela `{{MAINTENANCE_WINDOW}}`:

- [ ] Seluruh pemangku kepentingan telah diberi pemberitahuan (*maintenance broadcast*) minimal 24 jam sebelumnya.
- [ ] Snapshot sistem dan cadangan database lengkap telah berhasil dibuat dan diverifikasi di `{{BACKUP_DESTINATION}}`.
- [ ] Prosedur perubahan step-by-step telah ditulis dan ditinjau bersama tim.
- [ ] Rencana pembatalan (*rollback plan*) konkret dan teruji telah disiapkan.

## 3. Prosedur Eksekusi & Rollback

### Langkah Eksekusi Standar:
1. Aktifkan halaman pemeliharaan (*maintenance banner*) pada reverse proxy.
2. Hentikan (*stop*) servis aplikasi pendukung untuk mencegah penulisan data baru.
3. Jalankan perubahan konfigurasi / pembaruan sistem operasi `{{PRIMARY_OS}}`.
4. Jalankan pengujian fungsional dasar (*smoke test*).
5. Lepas halaman pemeliharaan dan buka kembali akses pengguna.

### Prosedur Rollback (Wajib Dipicu Jika):
- Pembaruan gagal diselesaikan 30 menit sebelum batas akhir `{{MAINTENANCE_WINDOW}}`.
- Ditemukan ketidakstabilan kernel atau kerusakan dependensi kritis.
- Layanan utama gagal menyala kembali setelah 3 kali upaya perbaikan.

**Langkah Rollback:**
1. Hentikan proses pembaruan segera.
2. Kembalikan berkas konfigurasi dari backup `/etc` atau pulihkan snapshot VM sebelum perubahan.
3. Nyalakan kembali servis dan pastikan status kembali hijau.
4. Dokumentasikan alasan kegagalan pada catatan insiden.
