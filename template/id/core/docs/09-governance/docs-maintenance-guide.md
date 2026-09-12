# Panduan Pemeliharaan Dokumentasi — {{PROJECT_NAME}}

> Aturan untuk menjaga integritas dokumentasi, keabsahan tautan, dan sinkronisasi arsitektural.

---

## 1. Pemicu Pembaruan Dokumentasi

Setiap kali pekerjaan memengaruhi arsitektur, konvensi, atau variabel proyek, berkas-berkas berikut WAJIB diperbarui:

1. **Keputusan Arsitektur Baru:** Tambahkan entri pada [decision-register.md](../08-reference/decision-register.md).
2. **Variabel Substitusi Baru:** Daftarkan pada [template-variables.md](../08-reference/template-variables.md).
3. **Status Milestone atau Tugas:** Perbarui status pada [backlog.md](../../backlog.md).
4. **Penambahan Dokumen Baru:** Daftarkan pada [INDEX.md](../INDEX.md).

---

## 2. Standar Tautan & Format Markdown

- Seluruh tautan relatif wajib mengarah ke berkas yang benar-benar ada (tidak boleh broken link).
- Hindari anchor tag atau referensi yang tidak valid.
- Selalu jalankan `./scripts/validate-template.sh` sebelum menyelesaikan perubahan.
