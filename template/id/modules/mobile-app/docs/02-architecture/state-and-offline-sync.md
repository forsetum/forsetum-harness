# Manajemen State & Sinkronisasi Offline — {{PROJECT_NAME}}

> Spesifikasi arsitektur state sisi klien, persistensi lokal, caching offline, dan sinkronisasi data jarak jauh.

---

## 1. Arsitektur State & Batasan Tanggung Jawab

Arsitektur klien menerapkan aliran data satu arah (*unidirectional data flow*) dan pemisahan tegas antara presentasi, logika bisnis, dan penyimpanan data:

- **Lapisan Presentasi (UI/Widgets):** Mengonsumsi state reaktif dari ViewModels atau Controllers. Bebas dari kode jaringan atau panggilan database langsung.
- **Pola Manajemen State:** Menggunakan pola kontainer state terprediksi sesuai konvensi `{{MOBILE_FRAMEWORK}}` (contoh: Riverpod/Bloc, Zustand/Redux, MVVM/Combine).
- **Lapisan Domain:** Entitas bisnis murni dan use cases tanpa ketergantungan pada pustaka UI.
- **Lapisan Repository:** Pemilih sumber data abstrak yang berpindah mulus antara cache lokal dan endpoint API jaringan.

---

## 2. Strategi Persistensi Lokal

| Tipe Data | Mekanisme Penyimpanan | Enkripsi | Kebijakan Eviksi (Pembersihan) |
| :--- | :--- | :--- | :--- |
| **Token Autentikasi & Kunci Rahasia** | Keychain (iOS) / EncryptedSharedPreferences (Android) | Perangkat Keras AES-256 | Dihapus saat logout atau install ulang aplikasi |
| **Preferensi Pengguna & Pengaturan** | Key-Value Store (UserDefaults / DataStore / MMKV) | Opsional | Persisten lintas sesi |
| **Data Relasional Terstruktur** | Basis Data Lokal (SQLite / Room / Drift / WatermelonDB) | SQLCipher (Opsional) | Cache LRU atau sinkronisasi eksplisit |
| **Media & Berkas Unduhan Sementara** | Direktori Sementara Sandbox Aplikasi | Tingkat OS | Pembersihan otomatis OS saat memori penuh |

---

## 3. Sinkronisasi Offline & Prioritas Jaringan

### 3.1. Alur Kerja Pembacaan (Prioritas Cache / Cache First)
1. Antarmuka UI meminta data ke repository.
2. Repository segera mengembalikan data cache lokal jika tersedia (render cepat tanpa loading).
3. Di latar belakang, permintaan jaringan dikirim ke API server.
4. Saat respons jaringan berhasil, basis data lokal diperbarui dan state reaktif memancarkan data terbaru ke UI.
5. Saat jaringan gagal, UI tetap menampilkan data cache dengan spanduk informatif "Mode Offline".

### 3.2. Alur Kerja Penulisan (Mutasi Optimis & Antrean Sinkronisasi)
1. Pengguna memicu aksi mutasi (misalnya mengirim formulir atau memperbarui status item).
2. UI diperbarui seketika secara optimis, lalu mutasi disimpan ke tabel lokal `outbox_queue` dengan UUID unik.
3. Pendengar jaringan (*connectivity listener*) memicu pemrosesan latar belakang saat koneksi internet pulih:
   - Item dalam `outbox_queue` dikirim berurutan (FIFO).
   - Item yang berhasil terkirim dihapus dari `outbox_queue`.
   - Kegagalan jaringan sementara dicoba ulang dengan *exponential backoff* (maksimal 5 kali).
   - Kesalahan klien 4xx permanen dipindahkan ke karantina (*dead-letter*) disertai notifikasi perbaikan ke pengguna.

---

## 4. Skema Deep Linking & Routing

Aplikasi menangani tautan resmi HTTPS Universal Links (iOS) / Android App Links, serta skema URI kustom sebagai cadangan:

- **Domain Universal / App Link:** `https://app.{{PROJECT_NAME}}.com`
- **Skema URI Kustom:** `{{PROJECT_NAME}}://`
- **Format Rute yang Didukung:**
  - `https://app.{{PROJECT_NAME}}.com/auth/callback` (Penanganan OAuth & tautan masuk langsung)
  - `https://app.{{PROJECT_NAME}}.com/resource/:id` (Pembuka halaman sumber daya langsung)
  - `https://app.{{PROJECT_NAME}}.com/settings/billing` (Navigasi profil akun dan tagihan)
