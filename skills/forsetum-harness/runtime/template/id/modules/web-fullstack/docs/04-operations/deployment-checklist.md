# Checklist Penyebaran & Validasi Runtime — {{PROJECT_NAME}}

## 1. Cakupan (Scope)

Gunakan checklist ini saat menyiapkan lingkungan kerja (*environment*), melakukan rilis aplikasi, atau mendiagnosis kendala startup/runtime. Item bersyarat hanya dicentang jika kapabilitas tersebut benar-benar digunakan.

## 2. Konfigurasi

- [ ] Runtime dan toolchain sesuai dengan [konteks teknis](../00-overview/mission.md).
- [ ] Konfigurasi non-rahasia (*non-secret*) tersedia dan valid.
- [ ] Kredensial/rahasia tersedia melalui secret manager atau environment variables, bukan di dalam source code.
- [ ] Endpoint atau dependensi eksternal yang digunakan dapat dijangkau (*reachable*).
- [ ] Batas sumber daya (*resource limit*) dan batas waktu (*timeout*) telah disesuaikan.
- [ ] Antarmuka atau port terbuka yang diperlukan telah diverifikasi keamanannya.

## 3. Keamanan

- [ ] Mekanisme otentikasi/otorisasi telah diverifikasi jika berlaku.
- [ ] Validasi input dan pembatasan laju (*rate limiting*) telah diverifikasi jika berlaku.
- [ ] Kontrol privasi dan klasifikasi data telah diverifikasi jika berlaku.
- [ ] Respons aplikasi, artefak build, dan log tidak membocorkan rahasia atau data pribadi.

## 4. Validasi Runtime

- [ ] Layanan/aplikasi dapat menyala (*startup*) dengan sukses atau artefak dapat digunakan.
- [ ] Pemeriksaan kesehatan (*health/readiness check*) berhasil dijalankan.
- [ ] Koneksi persistensi, antrean pesan, atau dependensi eksternal tervalidasi.
- [ ] Uji asap (*smoke test*) pada alur utama berhasil.
- [ ] Penanganan kegagalan dan percobaan ulang (*retry behavior*) utama tervalidasi.
- [ ] Metrik pemantauan, peringatan (*alerts*), dan logging terstruktur aktif.

## 5. Pembatalan Rilis (Rollback)

- [ ] Cadangan data (*backup/snapshot*) atau referensi commit rollback tersedia jika ada perubahan data/skema.
- [ ] Prosedur rollback telah diuji atau direview secara mendalam.
- [ ] Nomor versi rilis dan hasil validasi dicatat pada rekam jejak rilis.

## 6. Definisi Selesai (Definition of Done)

- [ ] Seluruh item yang berlaku telah lulus verifikasi.
- [ ] Seluruh item yang tidak berlaku memiliki alasan tertulis.
- [ ] Tidak ada kendala kritis (*critical blocker*) untuk lingkungan target.
