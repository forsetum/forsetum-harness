# Protokol AI Agent — {{PROJECT_NAME}} (Universal Core)

> Dokumen ini menetapkan aturan operasional wajib bagi agen AI otonom yang bekerja pada repositori ini (Hermes Agent, OpenClaw, Claude Code, Cursor, Windsurf, Antigravity, dan runtime kompatibel lainnya).

## 1. Konteks Proyek

- Nama Proyek: `{{PROJECT_NAME}}`
- Misi: `{{PROJECT_MISSION}}`
- Pemilik Keputusan Utama: `{{DECISION_OWNER}}`
- Modul Domain Aktif: Lihat `docs/INDEX.md` dan `docs/08-reference/template-variables.md`

### Urutan Membaca Wajib

Sebelum mengusulkan atau mengeksekusi modifikasi non-trivial, agen WAJIB membaca:

1. `README.md` (Gambaran Umum Proyek & Panduan Cepat)
2. `docs/INDEX.md` (Peta Induk Dokumentasi)
3. `docs/00-overview/mission.md` (Misi, Ruang Lingkup, dan Metrik Keberhasilan)
4. Dokumentasi Modul Domain Aktif yang tercantum di `docs/INDEX.md`
5. `docs/08-reference/decision-register.md` (Catatan Keputusan Resmi)
6. `docs/09-governance/implementation-readiness.md` (Status Gerbang Kesiapan)

## 2. Alur Kerja Universal AI Agent

Ikuti siklus bertahap yang ketat ini:
**Understand → Analyze → Discover → Ask/Confirm Decisions → Readiness Gate → Plan → Ask/Confirm Plan → Implement → Verify → Document**.

1. **Understand & Analyze (Pahami & Analisis)**: Periksa berkas ruang kerja, dokumentasi aktif, dan riwayat komit sebelumnya.
2. **Discover & Ask (Temukan & Tanya)**: Identifikasi spesifikasi yang hilang, ambiguitas, atau trade-off. Sajikan 2–3 opsi konkret beserta 1 rekomendasi terbaik. Dilarang mengarang arsitektur atau aturan bisnis tanpa konfirmasi.
3. **Readiness Gate (Gerbang Kesiapan)**:
   - `NOT_READY`: Status bawaan (default). Implementasi tindakan/kode dilarang keras.
   - `READY_FOR_PLAN`: Diizinkan hanya setelah seluruh kebutuhan inti dan keputusan di `decision-register.md` terkonfirmasi.
   - `READY_FOR_IMPLEMENTATION`: Eksekusi implementasi dimulai HANYA setelah rencana kerja disetujui secara eksplisit oleh pengguna dan checklist kesiapan di `docs/09-governance/implementation-readiness.md` terpenuhi.
4. **Implement & Verify (Eksekusi & Verifikasi)**: Kerjakan secara inkremental dalam tugas-tugas kecil. Uji setelah setiap langkah. Tunjukkan bukti eksekusi sebelum mengklaim selesai.
5. **Document (Dokumentasikan)**: Perbarui `backlog.md`, catatan keputusan, dan dokumen modul terkait.

## 3. Batas Wewenang & Eskalasi ke Manusia

Agen WAJIB berhenti dan meminta konfirmasi manusia apabila:
1. Tindakan berpotensi mengakibatkan kehilangan data permanen atau dampak destruktif.
2. Tindakan memerlukan kredensial rahasia, kunci API berbayar, atau pengeluaran finansial.
3. Terdapat kebutuhan yang bertentangan dengan keputusan yang sudah tercatat di `docs/08-reference/decision-register.md`.
4. Rencana kerja menemui pemblokir tak terduga di mana setiap langkah selanjutnya hanya didasarkan pada spekulasi/asumsi.

## 4. Standar Verifikasi dan Kualitas

- Seluruh hasil deliverable (kode, konfigurasi, naskah copywriting, skrip, laporan) wajib diverifikasi menggunakan perintah lokal sebelum melaporkan penyelesaian.
- Jika terdapat test suite atau alat validator, jalankan:
  ```bash
  ./scripts/validate-template.sh
  ```
  atau perintah pengujian spesifik proyek.
- Jangan pernah mengklaim berhasil tanpa menyertakan bukti keluaran eksekusi terminal.
