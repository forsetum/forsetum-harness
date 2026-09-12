# Peta Konteks Sistem Eksisting & Batasan Kode — {{PROJECT_NAME}}

## 1. Konteks Aplikasi Induk (Host Application Context)

Dokumen ini memetakan batas arsitektur antara aplikasi induk (*upstream/host*) dan perubahan kode yang dibuat pada proyek ini.

- Aplikasi induk: `{{HOST_APPLICATION}}`
- Model sumber kode: `{{SOURCE_MODEL}}`
- Bahasa pemrograman utama: `{{PRIMARY_LANGUAGE}}`
- Pola ekstensi yang diizinkan: `{{EXTENSION_PATTERN}}`

## 2. Zonasi Kode: Area Boleh Disentuh vs Area Terlarang

Untuk mencegah kerusakan sistem dan menjaga stabilitas aplikasi, agen AI dan pengembang wajib mematuhi zonasi berikut:

| Zona | Direktori / Komponen | Kebijakan Akses | Aturan Modifikasi |
|---|---|---|---|
| **Zona Merah (No-Touch Core)** | Kernel aplikasi induk, migration file bawaan, core framework | DILARANG UBAH (*Read-Only*) | Dilarang memodifikasi langsung file core bawaan vendor/upstream. |
| **Zona Kuning (Patch Window)** | Bug fix spesifik pada fungsi upstream | TERBATAS (*Surgical Patch*) | Hanya boleh diubah dengan file `.patch` terisolasi atau override modular. |
| **Zona Hijau (Custom Modules)** | Direktori plugin/addons/ekstensi kustom (`/custom-addons`, `/plugins`) | BEBAS (*Isolated Dev*) | Area resmi penulisan fitur baru, skema tambahan, dan handler API. |

## 3. Matriks Dependensi & Integrasi

- **Penyimpanan Data:** Seluruh tabel database baru wajib menggunakan prefix unik (contoh: `x_` atau `custom_`) agar tidak bertabrakan dengan rilis upstream.
- **Event & Signal Listener:** Integrasi fungsional diutamakan menggunakan *Observer / Event Hook / Signal Listener* resmi dari `{{HOST_APPLICATION}}`.
