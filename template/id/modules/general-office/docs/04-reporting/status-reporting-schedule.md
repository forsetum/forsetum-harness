# Jadwal Pelaporan Status & Ritme Rapat — {{PROJECT_NAME}}

> Ritme pelaporan berkala, template ringkasan status mingguan, dan kalender peninjauan untuk `{{PROJECT_NAME}}`.

---

## 1. Ritme Pelaporan

- **Frekuensi:** `{{REPORTING_SCHEDULE}}` (misal: Mingguan setiap Jumat pukul 17:00, Dua mingguan, Bulanan)
- **Penerima Laporan:** `{{DECISION_OWNER}}` dan kelompok pemangku kepentingan yang ditunjuk.
- **Format:** Ringkasan asinkron tertulis di `backlog.md` + memo/email ringkasan formal.

---

## 2. Template Laporan Status Mingguan

```markdown
### Laporan Progres Mingguan — {{PROJECT_NAME}} (Periode berakhir YYYY-MM-DD)

#### 1. Ringkasan Eksekutif
- Status keseluruhan: [SESUAI JADWAL / BERISIKO / TERHAMBAT]
- Pencapaian milestone utama pada periode ini.

#### 2. Pencapaian Utama
- [x] Butir 1: Deliverable selesai dan terverifikasi.
- [x] Butir 2: Optimalisasi proses berhasil diterapkan.

#### 3. Rencana Periode Berikutnya
- [ ] Butir 1: Prioritas milestone yang akan datang.
- [ ] Butir 2: Sesi peninjauan bersama pemangku kepentingan.

#### 4. Risiko, Kendala & Keputusan yang Dibutuhkan
- Kendala/Keputusan: [Deskripsi] — Penanggung Jawab: {{DECISION_OWNER}} — Tenggat Waktu: YYYY-MM-DD
```

---

## 3. Standar Notula Rapat (Meeting Minutes)

Untuk setiap pertemuan evaluasi formal:
- Catat Daftar Hadir, Tanggal, dan Durasi.
- Dokumentasikan Keputusan yang Ditetapkan (wajib dicatat pada `docs/08-reference/decision-register.md`).
- Catat secara eksplisit Butir Aksi (*Action Items*) lengkap dengan penanggung jawab tunggal dan tenggat waktu tegas.
