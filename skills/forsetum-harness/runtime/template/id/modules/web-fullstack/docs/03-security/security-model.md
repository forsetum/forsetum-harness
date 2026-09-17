# Model Keamanan — {{PROJECT_NAME}}

## 1. Cakupan Keamanan (Security Scope)

Dokumen ini menjelaskan aset yang dilindungi, ancaman (*threats*), kontrol keamanan, dan risiko residual proyek. Cantumkan hanya kontrol yang benar-benar diterapkan.

## 2. Aset dan Batasan Kepercayaan (Assets and Trust Boundaries)

- Aset yang dilindungi: {{PROTECTED_ASSETS}}
- Komponen terpercaya (*trusted components*): {{TRUSTED_COMPONENTS}}
- Masukan tidak terpercaya (*untrusted inputs*): {{UNTRUSTED_INPUTS}}
- Batasan eksternal (*security boundaries*): {{SECURITY_BOUNDARIES}}
- Klasifikasi data: {{DATA_CLASSIFICATION}}
- Strategi autentikasi & manajemen sesi: {{AUTH_STRATEGY}}

## 3. Matriks Ancaman dan Kontrol

- **Akses tidak sah (Unauthorized access):** {{ACCESS_CONTROL}}
- **Penyalahgunaan input / Injeksi:** {{INPUT_VALIDATION_CONTROL}}
- **Kebocoran rahasia (Secret exposure):** {{SECRET_MANAGEMENT_CONTROL}}
- **Kebocoran data / Privasi:** {{DATA_PROTECTION_CONTROL}}
- **Penghabisan sumber daya (Resource exhaustion):** {{RESOURCE_PROTECTION_CONTROL}}
- **Kompromi dependensi eksternal:** {{DEPENDENCY_SECURITY_CONTROL}}
- **Pemalsuan data / Replay attack:** {{INTEGRITY_CONTROL}}

## 4. Kontrol Operasional

- Logging aman tanpa data sensitif: {{SECURE_LOGGING_CONTROL}}
- Pemantauan keamanan & Peringatan: {{SECURITY_MONITORING_CONTROL}}
- Prosedur respons insiden keamanan: {{SECURITY_INCIDENT_PROCEDURE}}
- Kebijakan retensi dan pembersihan data: {{RETENTION_POLICY}}

## 5. Verifikasi Keamanan

- [ ] Seluruh ancaman telah dipetakan ke persyaratan dan skenario pengujian.
- [ ] Kredensial dan rahasia tidak disimpan di source code, repositori, artefak, atau log.
- [ ] Kontrol akses dan validasi masukan telah diuji secara nyata.
- [ ] Risiko residual dan pengecualian yang diterima telah didokumentasikan di Decision Register.
