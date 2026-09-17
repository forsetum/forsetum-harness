# Panduan Pemantauan & Observabilitas — {{PROJECT_NAME}}

## 1. Keterpakaian Modul (Applicability)

Gunakan modul ini untuk proyek yang memiliki proses runtime, pekerjaan terjadwal (*scheduled job*), pemrosesan asinkron, antarmuka publik, atau SLO operasional. Untuk proyek pustaka statis (*library/CLI*), tandai `Not Applicable` di Decision Register dan jelaskan metode validasi rilis.

## 2. Sinyal Observabilitas (Telemetry Signals)

- Pemeriksaan kesehatan / Kesiapan (*Health/readiness*): {{HEALTH_SIGNAL}}
- Metrik kinerja (*Metrics*): {{METRICS_SIGNAL}}
- Pencatatan log (*Structured Logs*): {{LOGGING_SIGNAL}}
- Pelacakan terdistribusi (*Traces*): {{TRACING_SIGNAL}}
- Sinyal bisnis & mutu: {{BUSINESS_SIGNAL}}

## 3. Peringatan Dini (Alerts)

- Kondisi kritis (P1/Critical): {{CRITICAL_ALERT}}
- Kondisi peringatan (P2/Warning): {{WARNING_ALERT}}
- Penanggung jawab eskalasi: {{ALERT_OWNER}}
- Aturan pembungkaman/pemeliharaan (*suppression rule*): {{ALERT_MAINTENANCE_RULE}}

## 4. Privasi dan Efisiensi Biaya

- Data sensitif wajib disamarkan (*redacted*) atau dikeluarkan dari telemetri.
- Kebijakan retensi dan sampling mengikuti aturan tata kelola data proyek.
- Payload tanpa batas (*unbounded*) atau kardinalitas tinggi tidak dipancarkan secara default.

## 5. Verifikasi

- [ ] Sinyal kesehatan berfungsi dengan baik jika berlaku.
- [ ] Logika peringatan (*alert rule*) dapat diuji tanpa membocorkan data sensitif.
- [ ] Tautan dasbor dan buku panduan insiden (*runbook*) valid.
