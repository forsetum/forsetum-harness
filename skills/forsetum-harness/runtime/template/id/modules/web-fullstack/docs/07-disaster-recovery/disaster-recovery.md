# Rencana Pemulihan Bencana (Disaster Recovery) — {{PROJECT_NAME}}

## 1. Keterpakaian Modul (Applicability)

Gunakan modul ini jika kegagalan runtime, kehilangan data, rusaknya artefak, atau matinya dependensi eksternal dapat mengganggu kelangsungan bisnis (*business continuity*).

## 2. Target Pemulihan (Recovery Objectives)

- Target Waktu Pemulihan (*Recovery Time Objective* / RTO): {{RTO}}
- Target Titik Pemulihan (*Recovery Point Objective* / RPO): {{RPO}}
- Kapabilitas kritis yang diprioritaskan: {{CRITICAL_CAPABILITIES}}
- Penanggung jawab pemulihan: {{RECOVERY_OWNER}}

## 3. Pencadangan dan Pemulihan Data (Backup & Restore)

- Cakupan pencadangan (*Backup scope*): {{BACKUP_SCOPE}}
- Frekuensi dan retensi cadangan data: {{BACKUP_RETENTION}}
- Sumber dan prosedur pemulihan data: {{RESTORE_PROCEDURE}}
- Verifikasi integritas hasil pemulihan: {{RESTORE_VERIFICATION}}

## 4. Skenario Penanganan Kegagalan

- Lingkungan runtime mati/tidak tersedia: {{RUNTIME_FAILURE_RECOVERY}}
- Dependensi stateful / basis data tidak tersedia: {{STATE_FAILURE_RECOVERY}}
- Layanan dependensi eksternal tidak tersedia: {{EXTERNAL_FAILURE_RECOVERY}}
- Rilis korup atau tidak kompatibel: {{RELEASE_ROLLBACK_RECOVERY}}

## 5. Verifikasi Kesiapan Pemulihan

- [ ] Prosedur pemulihan data memiliki pemilik tanggung jawab yang jelas.
- [ ] Akses terhadap berkas cadangan data terproteksi dengan kontrol otorisasi ketat.
- [ ] Jadwal pengujian pemulihan data berkala telah ditentukan.
- [ ] Hasil simulasi pemulihan dan celah risiko terdokumentasi.
