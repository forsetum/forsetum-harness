# Pelacakan CRM & Pelaporan Penjualan — {{PROJECT_NAME}}

> Spesifikasi pencatatan prospek, status CRM, ritme evaluasi pipeline mingguan, dan pelacakan metrik penjualan untuk `{{PROJECT_NAME}}`.

---

## 1. Skema Pencatatan Prospek CRM

Setiap prospek yang dicatat di CRM atau lembar kerja pelacakan wajib memuat data:
- `lead_id`: ID pengenal unik
- `company_name`: Nama organisasi / perusahaan target
- `contact_name`: Nama lengkap prospek
- `contact_title`: Jabatan prospek (wajib sesuai dengan `{{ICP_PROFILE}}`)
- `channel`: Saluran kontak dari `{{OUTREACH_CHANNELS}}`
- `status`: Salah satu dari `Identified`, `Contacted`, `Engaged`, `Demo`, `Proposal`, `Won`, `Lost`
- `last_touch_date`: Tanggal dan waktu komunikasi terakhir
- `next_action_date`: Tanggal jadwal tindakan berikutnya
- `deal_value`: Estimasi nilai transaksi menuju pencapaian `{{SALES_TARGET}}`

---

## 2. Ritme Evaluasi Pipeline Mingguan (Weekly Sales Cadence)

Diselenggarakan setiap pekan oleh tim dan agen AI:
1. **Tinjauan Aktivitas:** Jumlah kontak baru yang ditambahkan vs pesan sentuhan yang dikirimkan.
2. **Arus Pipeline:** Transaksi yang berhasil bergerak dari tahap Terlibat ➔ Kualifikasi ➔ Proposal.
3. **Transaksi Terhenti (Stalled Deals):** Setiap prospek tanpa aktivitas selama > 5 hari ditandai untuk keterlibatan ulang atau diskualifikasi.
4. **Pelacakan Target:** Pendapatan yang berhasil dimenangkan (closed-won) saat ini dibandingkan terhadap `{{SALES_TARGET}}`.

---

## 3. Metrik Konversi & KPI Utama

- **Tingkat Respons Positif (Positive Reply Rate):** Target `≥ 8%`
- **Tingkat Pertemuan Terjadwal (Meeting Booked Rate):** Target `≥ 3%` dari total kontak
- **Tingkat Closing Demo (Demo-to-Close Rate):** Target `≥ 25%`
