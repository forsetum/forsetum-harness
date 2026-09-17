# Kebijakan Kompatibilitas Upstream & Manajemen Patch — {{PROJECT_NAME}}

## 1. Strategi Kompatibilitas Upstream

Aplikasi induk `{{HOST_APPLICATION}}` beroperasi dengan model sumber: `{{SOURCE_MODEL}}`.
Saat rilis pembaruan (*upstream update / vendor patch*) diluncurkan, seluruh kustomisasi lokal harus tetap utuh dan kompatibel.

## 2. Manajemen Patch Bedah (Surgical Patching)

Jika penambalan bug terpaksa menyentuh kode upstream (karena ketiadaan hook yang memadai):

1. **Format Patch Standar:** Seluruh modifikasi kode upstream wajib diekspor ke dalam berkas patch terpisah:
   ```bash
   git diff upstream/main > patches/0001-fix-critical-bug.patch
   ```
2. **Automated Re-apply:** Sediakan skrip otomatis untuk menerapkan ulang patch setelah upstream di-update:
   ```bash
   git apply --check patches/0001-fix-critical-bug.patch
   ```
3. **Dokumentasi Patch:** Catat alasan penambalan, issue tracker ID, dan tautan upstream pull request jika open-source.

## 3. Isolasi Dependensi Pihak Ketiga

- Dependensi pustaka baru yang dibutuhkan modul kustom dilarang menimpa (*downgrade/upgrade*) pustaka inti yang dibutuhkan oleh `{{HOST_APPLICATION}}`.
- Gunakan virtual environment terisolasi, vendor directory lokal modul, atau container namespace.
