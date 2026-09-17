# Panduan Penanganan Kendala (Troubleshooting) — {{PROJECT_NAME}}

## 1. Urutan Triase Insiden (Triage Sequence)

1. Konfirmasikan cakupan, waktu kejadian, lingkungan (*environment*), dan kapabilitas yang terdampak.
2. Periksa perubahan rilis, konfigurasi, atau dependensi yang baru saja terjadi.
3. Periksa sinyal kesehatan, log sistem, metrik, jejak (*traces*), dan status database.
4. Lakukan reproduksi masalah secara aman tanpa mengekspos data sensitif.
5. Jalankan mitigasi langsung, catat hasil luaran, dan buat tiket tindak lanjut jika diperlukan.

## 2. Template Rekaman Insiden

- Gejala insiden: {{INCIDENT_SYMPTOM}}
- Dampak bisnis/pengguna: {{INCIDENT_IMPACT}}
- Metode deteksi: {{INCIDENT_DETECTION}}
- Kemungkinan penyebab: {{INCIDENT_CAUSES}}
- Mitigasi langsung: {{INCIDENT_MITIGATION}}
- Langkah verifikasi pemulihan: {{INCIDENT_VERIFICATION}}
- Pemilik eskalasi: {{INCIDENT_OWNER}}
- Rencana pencegahan/tindak lanjut: {{INCIDENT_FOLLOW_UP}}

## 3. Aturan Keselamatan Penanganan Insiden

- Dilarang menjalankan tindakan destruktif sebagai langkah diagnosis tanpa cadangan data (*backup*) dan persetujuan tertulis.
- Dilarang menyalin kredensial, rahasia, atau data pribadi ke tiket pelacak masalah, pesan obrolan, atau log.
- Bedakan secara tegas antara solusi darurat sementara (*workaround*) dengan perbaikan akar masalah permanen (*root cause fix*).
