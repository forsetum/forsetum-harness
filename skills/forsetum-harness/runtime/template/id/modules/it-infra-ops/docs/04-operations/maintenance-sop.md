# SOP Pemeliharaan Rutin Infrastruktur — {{PROJECT_NAME}}

## 1. Jadwal & Jendela Pemeliharaan

Seluruh aktivitas pemeliharaan terencana wajib dilakukan dalam jendela pemeliharaan resmi:
- Jendela Pemeliharaan: `{{MAINTENANCE_WINDOW}}`
- Lingkungan Target: `{{INFRA_ENVIRONMENT}}`
- Penanggung Jawab (*Decision Owner*): Didokumentasikan pada registri keputusan.

## 2. Checklist Pemeliharaan Harian (Daily Routine)

1. **Pemeriksaan Utilisasi Disk:**
   - Jalankan `df -h` pada seluruh node. Pastikan partisi root (`/`) dan data tidak melampaui ambang batas 80%.
2. **Pemeriksaan Service Health:**
   - Jalankan `systemctl status <service_name>` untuk servis utama. Pastikan status `active (running)`.
3. **Pemeriksaan Log Sistem:**
   - Tinjau pesan error kritis via `journalctl -p err -n 50 --no-pager`.

## 3. Checklist Pemeliharaan Mingguan (Weekly Routine)

1. **Rotasi & Pembersihan Log:**
   - Verifikasi bahwa logrotate berjalan optimal dan berkas log lawas terkompresi.
2. **Pembersihan Cache Paket & Ruang Sementara:**
   - Jalankan `apt-get autoremove -y && apt-get clean` (atau `dnf clean all` pada RHEL/CentOS).
3. **Verifikasi Integritas File Backup:**
   - Pastikan snapshot backup mingguan berhasil terkirim ke `{{BACKUP_DESTINATION}}`.

## 4. Checklist Pemeliharaan Bulanan (Monthly Patching & Audit)

1. **Pembaruan Keamanan Sistem Operasi (`{{PRIMARY_OS}}`):**
   - Lakukan update paket keamanan (`apt-get update && apt-get upgrade -y` dengan seleksi patch keamanan).
   - Jika diperlukan reboot kernel, jadwalkan restart bertahap antar-node di dalam jendela pemeliharaan.
2. **Audit Pengguna & SSH Key:**
   - Tinjau `/etc/passwd` dan `~/.ssh/authorized_keys` untuk memastikan tidak ada akun dorman atau tidak dikenal.
3. **Pemeriksaan Masa Berlaku Sertifikat SSL/TLS:**
   - Periksa masa aktif sertifikat web dan internal CA: `openssl x509 -enddate -noout -in /path/to/cert.pem`.
