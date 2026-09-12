# Format Memo Keputusan Eksekutif & Rekomendasi — {{PROJECT_NAME}}

> Format standar tata kelola untuk menyajikan temuan riset, analisis kompromi (*trade-off*), penilaian risiko, dan rekomendasi eksekutif.

---

## 1. Ringkasan Eksekutif (Format 1 Halaman)

- **Tanggal:** YYYY-MM-DD
- **Target Pembaca / Pemilik Keputusan:** `{{EXECUTIVE_AUDIENCE}}` / `{{DECISION_OWNER}}`
- **Topik Riset:** `{{RESEARCH_TOPIC}}`
- **Rekomendasi Utama:** Tindakan strategis yang jelas, terukur, dan tidak ambigu berdasarkan bukti temuan riset.
- **Hasil yang Diharapkan:** Efisiensi operasional nyata, penghematan anggaran, atau pencapaian target kecepatan kerja.

---

## 2. Rumusan Masalah & Konteks Industri

Uraian ringkas (2–3 paragraf) yang merangkum latar belakang historis, hambatan operasional yang dihadapi saat ini, dan alasan mengapa penundaan keputusan menimbulkan risiko yang tidak dapat diterima bagi `{{PROJECT_NAME}}`.

---

## 3. Matriks Kompromi Jalur Keputusan (Trade-Off Matrix)

Evaluasi secara objektif alternatif keputusan yang saling bersaing:

| Jalur Keputusan | Keunggulan Utama | Kelemahan / Konsekuensi | Estimasi Biaya | Jadwal Pelaksanaan | Tingkat Risiko |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **Opsi A (Direkomendasikan):** Bangun harness modular terstandarisasi | Mengurangi hambatan tim, bebas vendor lock-in, terulang | Membutuhkan alokasi waktu penyiapan awal | 1 Rekayasawan (2 minggu) | 14 hari | Rendah |
| **Opsi B:** Berlangganan platform SaaS pihak ketiga | Langsung tersedia siap pakai | Biaya langganan berulang, ketergantungan vendor | Rp 25.000.000 / bulan | 7 hari | Sedang |
| **Opsi C (Status Quo):** Pertahankan penyiapan manual tanpa panduan | Tanpa biaya tunai di muka | Beban utang teknis dan kesalahan berulang | Beban tersembunyi | Tak terbatas | Tinggi |

---

## 4. Matriks Penilaian Risiko & Mitigasi

| Identifikasi Risiko | Tingkat Keparahan | Probabilitas | Strategi Mitigasi Terencana | Penanggung Jawab |
| :--- | :---: | :---: | :--- | :--- |
| **Rendahnya adopsi tim pada framework baru** | Tinggi | Sedang | Sediakan CLI scaffolding instan (`init.sh`) dan video panduan ringkas. | Lead Maintainer |
| **Perbedaan makna antara dokumen bilingual** | Sedang | Rendah | Jalankan validasi paritas otomatis (`validate-template.sh`) di CI. | Tim QA / Tooling |
| **Beban pemeliharaan dokumen yang membengkak** | Sedang | Rendah | Bagikan berkas `core/` universal ke seluruh modul tanpa duplikasi. | Tim Arsitektur |

---

## 5. Lembar Persetujuan Keputusan (Sign-Off)

| Peran | Nama / Jabatan | Keputusan (Disetujui / Ditolak / Ditunda) | Tanggal | Tanda Tangan |
| :--- | :--- | :---: | :---: | :--- |
| **Pengambil Keputusan Utama** | `{{DECISION_OWNER}}` | [ ] Disetujui | YYYY-MM-DD | ____________________ |
| **Pemangku Kepentingan Eksekutif** | `{{EXECUTIVE_AUDIENCE}}` | [ ] Disetujui | YYYY-MM-DD | ____________________ |
