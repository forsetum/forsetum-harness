# Tata Kelola Faskes & Standarisasi Rekam Medis — {{PROJECT_NAME}}

> Panduan kanonikal tata kelola operasional fasilitas kesehatan, standarisasi Rekam Medis Elektronik (RME), kepatuhan SATUSEHAT, dan perlindungan privasi medis pasien untuk `{{PROJECT_NAME}}`.

---

## 1. Profil Fasilitas Kesehatan & Standar Kepatuhan

| Parameter | Nilai Instansiasi |
|---|---|
| **Jenis Fasilitas Kesehatan** | `{{HEALTHCARE_FACILITY_TYPE}}` |
| **Standar Rekam Medis Elektronik** | `{{EMR_STANDARD}}` |
| **Alur Pelayanan Pasien** | `{{PATIENT_SERVICE_FLOW}}` |
| **Tingkat Perlindungan Privasi Data** | `{{DATA_PRIVACY_TIER}}` |
| **Penanggung Jawab Medis / Dokter PJ** | `{{DECISION_OWNER}}` |
| **Misi Layanan Kesehatan** | `{{PROJECT_MISSION}}` |

---

## 2. Standarisasi Alur Pelayanan & Dokumentasi Klinis

1. **Registrasi & Persetujuan Tindakan Medis (Informed Consent):**
   - Verifikasi identitas pasien (NIK / No BPJS / Paspor).
   - Penjelasan risiko dan manfaat tindakan medis secara tertulis sebelum intervensi diagnostik atau terapeutik.
2. **Dokumentasi Klinis Berstandar SOAP:**
   - **S (Subjektif):** Keluhan utama, riwayat penyakit sekarang, dan riwayat alergi.
   - **O (Objektif):** Tanda vital (Tensi, Nadi, Suhu, RR), pemeriksaan fisik umum, dan hasil lab.
   - **A (Asesmen):** Diagnosis kerja dan diagnosis banding terkode ICD-10.
   - **P (Planning):** Terapi farmakologis, instruksi diet, jadwal kontrol, dan edukasi discharge planning.

---

## 3. Protokol Keamanan & Kepatuhan Privasi Pasien

- [ ] Integrasi interoperabilitas SATUSEHAT Kemenkes RI telah lulus uji sandbox API.
- [ ] Hak akses data rekam medis berbasis peran (*Role-Based Access Control* / RBAC) dengan audit log per akses.
- [ ] Dilarang keras mengunggah data identitas pasien (PHI) yang tidak disamarkan (*unmasked*) ke model LLM publik.
- [ ] SOP penanganan insiden keselamatan pasien (IKP) dan register sentinel terdokumentasi rapi.
