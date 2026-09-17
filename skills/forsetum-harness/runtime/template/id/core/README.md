# {{PROJECT_NAME}}

> {{PROJECT_MISSION}}

Repositori ini dikelola di bawah tata kelola **AI Agent Harness** yang mengoordinasikan kerja sama antara kontributor manusia dan AI agent otonom.

---

## 1. Panduan Cepat (Quickstart)

### Prasyarat
- Terminal OS Native (Linux, macOS, Git Bash, atau Windows PowerShell)
- Runtime AI Agent (Cursor, Claude Code, Hermes Agent, OpenClaw, atau Antigravity)

### Struktur Proyek
- [AGENTS.md](AGENTS.md): Petunjuk operasional, protokol kerja, dan safety gate bagi agen AI.
- [QUICKSTART.md](QUICKSTART.md): Panduan penyiapan 5 menit untuk bekerja dengan AI IDE.
- [backlog.md](backlog.md): Peta jalan tugas terprioritasi, tugas aktif, dan pelacak milestone.
- [docs/](docs/INDEX.md): Sumber kebenaran tunggal (*Single source of truth*) yang memuat misi, registri referensi, dan tata kelola.
- `scripts/`: Tooling validasi dan verifikasi mandiri.

---

## 2. Bekerja Bersama AI Agent

Saat membuka proyek ini bersama AI coding agent:
1. Pastikan agen telah membaca [AGENTS.md](AGENTS.md) dan [docs/INDEX.md](docs/INDEX.md).
2. Tinjau [docs/09-governance/implementation-readiness.md](docs/09-governance/implementation-readiness.md) untuk memastikan status gerbang kesiapan saat ini.
3. Kelola dan pilih tugas implementasi dari [backlog.md](backlog.md).

---

## 3. Verifikasi Proyek

Jalankan skrip validator proyek untuk memverifikasi integritas dokumentasi, registrasi placeholder, dan keabsahan tautan:

**POSIX Shell (Linux / macOS / Git Bash):**
```bash
./scripts/validate-template.sh
```

**Windows PowerShell:**
```powershell
powershell -File .\scripts\validate-template.ps1
```
