# Panduan Pengembangan Modul Kustom — {{PROJECT_NAME}}

## 1. Prinsip Isolasi Modul (Module Isolation Principles)

Pengembangan modul tambahan pada `{{HOST_APPLICATION}}` wajib mematuhi pola: `{{EXTENSION_PATTERN}}`.
Bahasa utama yang digunakan: `{{PRIMARY_LANGUAGE}}`.

Prinsip utama:
1. **Zero Core Pollution:** Dilarang mengedit file di luar direktori modul kustom yang ditentukan.
2. **Backward Compatibility:** Perubahan model data tidak boleh menghapus atau mengubah tipe kolom bawaan dari `{{HOST_APPLICATION}}`.
3. **Pluggable & Decoupled:** Modul kustom harus dapat diaktifkan (*installed*) dan dinonaktifkan (*uninstalled*) tanpa meninggalkan artefak yang merusak sistem inti.

## 2. Standar Struktur Direktori Modul Kustom

Modul kustom disusun dengan konvensi berikut:
```text
custom_module_name/
├── manifest/config file      # Metadata modul, dependensi, dan deklarasi hook
├── models/                   # Definisi model data tambahan (dengan prefix custom)
├── views/ / templates/       # Tampilan antarmuka atau override template
├── controllers/ / api/       # Endpoint API kustom
└── tests/                    # Pengujian unit dan integrasi non-regresi
```

## 3. Aturan Ekstensi Skema Basis Data

- **Penambahan Kolom Baru:** Kolom baru pada tabel eksisting hanya boleh bernilai opsional (`nullable`) atau memiliki nilai default yang valid agar tidak memecahkan query bawaan upstream.
- **Tabel Baru:** Nama tabel wajib menggunakan awalan nama modul kustom untuk mencegah konflik migrasi di masa depan.
