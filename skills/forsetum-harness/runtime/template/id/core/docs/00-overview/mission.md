# Misi & Sasaran Proyek — {{PROJECT_NAME}}

> Spesifikasi kanonikal mengenai tujuan proyek, konteks bisnis, audiens sasaran, dan hasil yang dapat diukur.

---

## 1. Ringkasan Eksekutif

- **Nama Proyek:** `{{PROJECT_NAME}}`
- **Misi Utama:** `{{PROJECT_MISSION}}`
- **Pemangku Kepentingan Utama / Pemilik Keputusan:** `{{DECISION_OWNER}}`

---

## 2. Latar Belakang & Pernyataan Masalah

### 2.1. Latar Belakang
`{{PROJECT_NAME}}` menjawab kebutuhan penting dengan menyediakan eksekusi yang terstruktur, terarah, dan dapat diverifikasi bagi tim manusia dan agen AI otonom.

### 2.2. Pernyataan Masalah
Tanpa batasan yang tegas dan tata kelola yang jelas, proyek sering mengalami pembengkakan cakupan (*scope creep*), ketidaksesuaian deliverable, dan asumsi yang tidak pernah diverifikasi.

---

## 3. Sasaran dan Batasan di Luar Cakupan (Goals & Non-Goals)

### 3.1. Sasaran (Goals)
- Menghasilkan output terverifikasi yang sesuai dengan kriteria penerimaan pemangku kepentingan.
- Menjaga transparansi penuh melalui pencatatan riwayat keputusan pada [decision-register.md](../08-reference/decision-register.md) dan pelacakan pada [backlog.md](../../backlog.md).
- Memastikan seluruh deliverable dapat diuji atau dibuktikan secara objektif.

### 3.2. Batasan di Luar Cakupan (Non-Goals)
- Pekerjaan yang tidak didokumentasikan secara eksplisit dalam rencana implementasi yang disetujui.
- Mengubah arsitektur, parameter, atau batasan proyek secara sepihak tanpa persetujuan pemilik keputusan.

---

## 4. Metrik Keberhasilan & Definisi Selesai (Definition of Done)

Tonggak pencapaian (milestone) proyek dinyatakan selesai apabila:
1. Seluruh hasil kerja memenuhi kriteria yang ditetapkan pada [acceptance-criteria.md](../09-governance/acceptance-criteria.md).
2. Gerbang kesiapan pada [implementation-readiness.md](../09-governance/implementation-readiness.md) mengonfirmasi terpenuhinya seluruh bukti verifikasi.
3. Skrip validasi dan pengujian berjalan sukses dengan kode keluar (*exit code*) 0.
