# Runbook Penanganan Insiden & Kedaruratan — {{PROJECT_NAME}}

## 1. Matriks Tingkat Keparahan Insiden (Severity Matrix)

| Tingkat (Severity) | Definisi Dampak | Target Waktu Respons | Jalur Eskalasi |
|---|---|---|---|
| **P1 - Kritis** | Seluruh layanan tidak dapat diakses pengguna (Downtime Total) | < 15 Menit | Panggilan darurat ke Sysadmin & Manajemen |
| **P2 - Tinggi** | Fitur utama terganggu atau redundansi node hilang | < 1 Jam | Notifikasi ke Tim Operasional |
| **P3 - Sedang** | Penurunan performa tanpa kegagalan fungsional | < 4 Jam | Tiket antrean kerja normal |
| **P4 - Rendah** | Masalah kosmetik atau peringatan non-kritis | < 24 Jam | Backlog pemeliharaan |

## 2. Runbook Kedaruratan Standar

### Skenario A: Partisi Disk 100% Penuh (Disk Full Emergency)
1. **Identifikasi:** Jalankan `df -h` untuk menemukan partisi yang penuh (misal `/var/log` atau `/var/lib/docker`).
2. **Tindakan Cepat:**
   - Cari berkas terbesar: `du -ahx /var/log | sort -rh | head -n 10`
   - Truncate log aktif (jangan hapus berkas saat proses masih menulis): `> /var/log/<service>/large_file.log`
   - Bersihkan arsip logrotate terkompresi lama: `find /var/log -name "*.gz" -mtime +30 -delete`
3. **Verifikasi:** Pastikan ruang disk kembali di bawah 80% dan servis yang terdampak dapat menulis kembali.

### Skenario B: Beban CPU / RAM Spike Ekstrem
1. **Identifikasi:** Jalankan `top` atau `htop`, tekan `M` untuk sort by memory, atau `P` untuk sort by CPU.
2. **Analisis:** Identifikasi apakah proses merupakan query database macet, memory leak aplikasi, atau serangan DDoS lokal.
3. **Tindakan:**
   - Restart servis secara anggun (*graceful restart*): `systemctl reload <service>` atau `systemctl restart <service>`.
   - Bunuh proses liar (*runaway process*) jika tidak responsif: `kill -15 <PID>` (atau `kill -9 <PID>` sebagai opsi terakhir).

### Skenario C: Basis Data Terkunci (Database Locked / Deadlock)
1. Periksa koneksi aktif: `SELECT * FROM pg_stat_activity WHERE state = 'active';` (PostgreSQL).
2. Batalkan query yang memblokir proses lain: `SELECT pg_cancel_backend(<pid>);`.
