# Panduan Kepatuhan App Store & Google Play — {{PROJECT_NAME}}

> Protokol kepatuhan, kebijakan peninjauan toko aplikasi, deklarasi privasi, dan daftar periksa pencegahan penolakan (rejection).

---

## 1. Kepatuhan Apple App Store (App Review Guidelines)

1. **Penghapusan Akun (Bagian 5.1.1(v)):** Jika aplikasi mendukung pembuatan akun, pengguna wajib dapat menghapus akun dan membersihkan data pribadinya langsung dari dalam aplikasi tanpa perlu mengirim email manual atau dialihkan ke web eksternal.
2. **Transparansi Pelacakan Aplikasi (ATT):** Jika menggunakan pelacak iklan (IDFA) atau analitik pihak ketiga lintas aplikasi, dialog izin ATT wajib ditampilkan sebelum pelacak diinisialisasi.
3. **Pembelian Dalam Aplikasi (Bagian 3.1.1):** Barang digital, langganan fitur, dan akses konten premium wajib menggunakan StoreKit IAP Apple. Dilarang menyertakan tautan pembayaran eksternal untuk konten digital.
4. **Label Nutrisi Privasi:** Lengkapi deklarasi jenis data yang dikumpulkan (informasi kontak, pengenal perangkat, riwayat penggunaan) yang ditautkan ke identitas pengguna pada App Store Connect.

---

## 2. Kepatuhan Google Play Store (Kebijakan Pengembang)

1. **Target Level API:** Build Android wajib menargetkan versi API Android terbaru yang diwajibkan oleh Google Play (saat ini API 34+ / Android 14+).
2. **Formulir Keamanan Data (Data Safety Form):** Wajib mendeklarasikan seluruh data yang dikumpulkan, dibagikan, dan dienkripsi saat transit di Google Play Console sebelum rilis publik.
3. **Layanan Latar Depan (Foreground Services):** Penggunaan izin `FOREGROUND_SERVICE` memerlukan justifikasi fitur aktif yang terlihat oleh pengguna (audio, pelacakan navigasi, unduhan berkas besar) disertai kontrol notifikasi.
4. **Izin Foto & Video:** Gunakan Pemilih Foto Android modern (`ActivityResultContracts.PickVisualMedia`) daripada meminta izin umum `READ_EXTERNAL_STORAGE`.

---

## 3. Daftar Periksa Pencegahan Penolakan Rilis (Pre-Submission Checklist)

Jalankan daftar periksa ini sebelum mengirimkan paket biner ke Apple Review atau Google Play Console:

| Item Tinjauan | Metode Verifikasi | Status | Catatan |
| :--- | :--- | :---: | :--- |
| **Kredensial Akun Peninjau (Demo)** | Sediakan akun uji coba lengkap dengan data awal simulasi | [ ] | Pada Catatan Tinjauan App Store Connect |
| **Bebas Tautan Rusak & Placeholder** | Verifikasi URL syarat layanan, kebijakan privasi, dan dukungan | [ ] | Wajib mengembalikan status HTTP 200 |
| **Tanpa Teks "Beta" atau "Demo"** | Pindai string biner dari sisa artefak pengujian pada build rilis | [ ] | Pengecekan biner produksi |
| **Jalur Penghapusan Akun Aktif** | Uji alur Pengaturan > Akun > Hapus Akun secara nyata | [ ] | Syarat wajib Apple 5.1.1 |
| **Layar Awal Bebas Crash Offline** | Buka aplikasi pada perangkat fisik tanpa koneksi internet | [ ] | Pastikan aplikasi tidak menutup mendadak |
| **Tata Letak Layar Tablet** | Pastikan antarmuka tidak terpotong saat dibuka di iPad/Tablet | [ ] | Uji coba pada emulator iPad / Tablet |
