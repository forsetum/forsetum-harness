# Gerbang Kesiapan Implementasi Adaptif — {{PROJECT_NAME}}

> Titik pemeriksaan kesiapan (Readiness Checkpoint) yang mengontrol transisi antara tahap penemuan fakta, perencanaan, dan eksekusi aktif.

## Status Kesiapan Saat Ini: `NOT_READY`

- Status yang Diizinkan: `NOT_READY` (Status bawaan pemblokir), `READY_FOR_PLAN`, `READY_FOR_IMPLEMENTATION`.
- Perubahan status wajib memenuhi seluruh kriteria checklist terkait yang terverifikasi.

---

## 1. Checklist Kesiapan Universal (Semua Proyek)

| Butir Pemeriksaan | Kebutuhan | Status | Bukti / Catatan |
|---|---|---|---|
| Misi Proyek Didefinisikan | `docs/00-overview/mission.md` lengkap | [ ] | Tercantum di mission.md |
| Pemilik Keputusan Dikonfirmasi | `{{DECISION_OWNER}}` teridentifikasi | [ ] | Tercatat di decision-register.md |
| Variabel Inti Terisi | Variabel wajib di `template-variables.md` telah diisi | [ ] | Diperiksa di template-variables.md |
| Protokol Dipahami | Alur kerja agen pada `AGENTS.md` dipatuhi | [ ] | Terverifikasi di AGENTS.md |
| Verifikasi Awal Bersih | Eksekusi skrip baseline lolos tanpa error | [ ] | Output terminal tercatat |

---

## 2. Checklist Kesiapan Modul Domain Aktif

<!-- MODULE_READINESS_START -->
| Butir Pemeriksaan | Modul | Kebutuhan | Status | Bukti / Catatan |
|---|---|---|---|---|
| *None* | Core | Tidak ada checklist modul domain tambahan | [x] | Khusus core |
<!-- MODULE_READINESS_END -->
