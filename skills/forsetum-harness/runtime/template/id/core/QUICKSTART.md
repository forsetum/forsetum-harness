# Panduan Cepat: Bekerja dengan AI IDE

> Selamat datang di AI Agent Harness Anda! Panduan ini membantu Anda mulai bekerja menggunakan perkakas AI coding favorit dalam waktu kurang dari 5 menit.

---

## 1. Lingkungan AI yang Didukung

Harness ini dirancang agar bekerja optimal dengan berbagai tools dan IDE berbasis AI modern:
- **Google Antigravity / Antigravity IDE**
- **Cursor**
- **VS Code** (dengan GitHub Copilot, Roo Code, Cline, atau Continue)
- **Claude Code** (CLI)
- **Windsurf** / **Hermes Agent**

---

## 2. Penyiapan 5 Menit (5-Minute Setup)

### Langkah 1: Buka Proyek di AI IDE Anda
Buka folder hasil ekstrak ini sebagai root workspace pada editor atau terminal AI Anda.

### Langkah 2: Inisiasi AI Agent
Buka sesi chat baru dengan AI agent Anda dan masukkan prompt pembuka berikut:

```text
Tolong baca AGENTS.md dan docs/INDEX.md secara menyeluruh.
Tinjau status kesiapan saat ini pada docs/09-governance/implementation-readiness.md.
Konfirmasikan pemahaman aturan ini dan tanyakan fitur atau backlog task mana yang ingin kita kerjakan pertama kali.
```

### Langkah 3: Sesuaikan Variabel Proyek (Opsional)
Template ini menggunakan placeholder `{{...}}` agar Anda dapat menyesuaikan detail proyek. Anda dapat:
- Melakukan search-and-replace di editor untuk variabel placeholder (seperti `{{PROJECT_NAME}}` dan variabel modul terkait).
- Atau meminta langsung ke AI agent: *"Tolong ganti {{PROJECT_NAME}} dengan 'Aplikasi Keren Saya' dan sesuaikan variabel di seluruh berkas docs."*

---

## 3. Praktik Terbaik untuk Kualitas Kode Tinggi

1. **Jaga Dokumentasi Tetap Selaras**: Setiap kali AI mengubah arsitektur atau menambahkan endpoint API, minta AI memperbarui berkas terkait di folder `docs/`.
2. **Terapkan Test-Driven Development (TDD)**: Instruksikan AI agent untuk menulis unit/integration test sebelum menulis kode logika bisnis.
3. **Periksa Gerbang Kesiapan**: Pastikan kriteria penerimaan telah jelas sebelum meminta AI menulis kode dalam skala besar.

---

## 4. Butuh Harness yang Lebih Mendalam atau Siap Produksi?

Harness starter ini menyediakan tata kelola fondasi untuk aplikasi web MVP.

Jika Anda membutuhkan harness yang lebih komprehensif untuk skala enterprise, kunjungi **AI Harness Generator**:
- **Enterprise Web Fullstack**: Microservices, skema basis data, kontrak API, disaster recovery, dan monitoring panduan.
- **High-Converting Landing Page**: Wireframe visual, formula copywriting, SEO keyword clusters, dan analitik.
- **B2B Sales & Outreach**: Definisi ICP, skrip penanganan keberatan, dan pipeline CRM.
- **Mobile Application**: Sinkronisasi offline, izin biometrik, dan panduan rilis Play Store/App Store.
- **CLI & Otomasi**: Exit code deterministik, daemon systemd/cron, dan pemrosesan batch.

👉 **Buat harness Anda berikutnya:** Cek email Anda atau kunjungi portal web generator untuk membuka preset lanjutan.
