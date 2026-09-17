# Kriteria Penerimaan Fungsional & Daftar Periksa Kualitas — {{PROJECT_NAME}}

> Kriteria verifikasi dan gerbang pengujian sebelum merilis {{PROJECT_NAME}}.

---

## 1. Daftar Periksa Penerimaan Fungsional

| Butir Uji | Persyaratan | Metode Verifikasi | Status |
|---|---|---|---|
| **Boot Aplikasi** | Aplikasi dapat dikompilasi dan berjalan lokal tanpa error | Jalankan skrip dev server (`npm run dev` atau sepadan) | [ ] |
| **Navigasi Halaman** | Seluruh rute utama (`/`, `/dashboard`, `/settings`) ter-render dengan benar | Uji klik langsung di browser | [ ] |
| **Pengiriman Form** | Masukan form berhasil disimpan dan menampilkan umpan balik | Uji form dengan masukan valid dan tidak valid | [ ] |
| **Persistensi Data** | Data yang disimpan tetap ada setelah restart server | Simpan data, restart dev server, pastikan data tersimpan | [ ] |
| **Responsivitas Mobile** | Antarmuka tampil rapi tanpa horizontal scroll pada viewport mobile (< 480px) | Emulasi perangkat di Browser DevTools | [ ] |

---

## 2. Gerbang Kualitas Kode

- [ ] **Bebas Pesan Error Konsol**: Konsol DevTools bersih dari pengecualian yang tidak tertangani dan peringatan React key.
- [ ] **Linting Bersih**: Tool linting berjalan dengan 0 error dan 0 peringatan kritis.
- [ ] **Isolasi Lingkungan**: Rahasia dan konfigurasi disimpan di environment variable, dilarang hardcode di kode.
- [ ] **Keselarasan Dokumentasi**: Setiap rute atau perubahan skema baru tercermin di folder `docs/`.
