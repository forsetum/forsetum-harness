# Panduan Kontrak Backend & API — {{PROJECT_NAME}}

## 1. Keterpakaian Modul (Applicability)

Gunakan dokumen ini jika proyek menyediakan HTTP API, RPC, kontrak event, antarmuka CLI, atau batasan layanan publik (*service boundary*). Jika tidak relevan, tandai `Not Applicable` di Decision Register dan README.

## 2. Batasan Lapisan Arsitektur (Layer Boundaries)

- Antarmuka / router / controller: `{{ROUTER_PATH}}`
- Logika bisnis / service: `{{SERVICE_PATH}}`
- Skema / DTO / kontrak: `{{SCHEMA_PATH}}`
- Akses data / model: `{{MODEL_PATH}}`

## 3. Checklist Perubahan Antarmuka

- [ ] Requirement ID yang terdampak telah diidentifikasi.
- [ ] Format permintaan (*request/event input*) dan tanggapan (*response/output*) terdokumentasi.
- [ ] Validasi, otorisasi, status kode kesalahan, dan format pesan kesalahan konsisten.
- [ ] Kompatibilitas ke belakang (*backward compatibility*) dan strategi versi telah dipertimbangkan.
- [ ] Idempotensi, penanganan konkurensi, dan percobaan ulang telah ditentukan jika relevan.
- [ ] Jejak audit (*audit trail*) ditambahkan hanya jika diwajibkan oleh domain atau regulasi.
- [ ] Uji unit, integrasi, kontrak, dan end-to-end yang relevan diperbarui.
- [ ] Dokumen alur bisnis, arsitektur, keamanan, dan kriteria penerimaan disinkronkan.

## 4. Definisi Selesai (Definition of Done)

- Skenario sukses (*happy path*) dan skenario kegagalan utama teruji.
- Kontrak antarmuka tidak berubah tanpa dokumentasi pembaruan yang sah.
- Tidak ada data sensitif yang bocor melalui respons API atau log.
- Antarmuka tetap kompatibel atau memiliki rencana migrasi/versi yang jelas.
