# Spesifikasi Platform Seluler & Izin Perangkat — {{PROJECT_NAME}}

> Spesifikasi kanonikal untuk sistem operasi seluler yang didukung, framework runtime, justifikasi izin perangkat keras, dan kapabilitas perangkat.

---

## 1. Matriks Platform & Persyaratan Dasar

- **Nama Aplikasi:** `{{PROJECT_NAME}}`
- **Application Bundle ID / Nama Paket:** `{{APP_BUNDLE_ID}}`
- **Framework Utama:** `{{MOBILE_FRAMEWORK}}`
- **Sistem Operasi Target:** `{{TARGET_OS}}`
- **Dukungan OS Minimal:** `{{MIN_OS_VERSION}}`
- **Arsitektur Target:** `arm64-v8a`, `armeabi-v7a`, `x86_64` (iOS 64-bit arm64)
- **Faktor Bentuk Didukung:** Ponsel pintar (Utama Potret, Lanskap adaptif) dan Tablet.

---

## 2. Izin Perangkat Keras & Sistem (Hardware Permissions)

Setiap izin yang diminta wajib melayani fitur aplikasi yang dideklarasikan kepada pengguna. Akses latar belakang tanpa persetujuan eksplisit dilarang.

| Pengenal Izin | Platform | Justifikasi Pengguna (String) | Tingkat Kebutuhan | Penanganan Jika Ditolak |
| :--- | :--- | :--- | :--- | :--- |
| `CAMERA` | iOS / Android | "Pindai kode QR dan ambil foto verifikasi profil." | Opsional / Saat Diperlukan | Ya (Beralih ke entri manual) |
| `READ_MEDIA_IMAGES` / `Photos` | iOS / Android | "Pilih gambar dari galeri untuk mengunggah avatar dan lampiran berkas." | Opsional / Saat Diperlukan | Ya (Batalkan lampiran) |
| `POST_NOTIFICATIONS` | iOS / Android | "Terima pemberitahuan transaksi langsung dan peringatan sistem berkala." | Opsional / Pasca-Onboarding | Ya (Gunakan kotak masuk in-app) |
| `ACCESS_FINE_LOCATION` | iOS / Android | "Menentukan titik lokasi penjemputan atau pengantaran terdekat secara presisi." | Saat Diperlukan | Ya (Pencarian alamat manual) |
| `USE_BIOMETRIC` / `FaceID` | iOS / Android | "Autentikasi akun secara aman menggunakan sidik jari atau pengenalan wajah." | Opsional | Ya (Beralih ke PIN/Kata Sandi master) |

---

## 3. Konfigurasi Manifest Platform

### 3.1. iOS (`Info.plist`)
```xml
<!-- String deklarasi izin wajib untuk tinjauan Apple -->
<key>NSCameraUsageDescription</key>
<string>Izinkan {{PROJECT_NAME}} mengakses kamera untuk memindai kode QR dan mengambil foto verifikasi.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Izinkan {{PROJECT_NAME}} mengakses galeri foto untuk melampirkan tanda terima dan foto profil.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Izinkan {{PROJECT_NAME}} mengakses lokasi Anda saat menggunakan aplikasi untuk menampilkan layanan terdekat.</string>
<key>NSFaceIDUsageDescription</key>
<string>Autentikasi akun secara aman menggunakan Face ID.</string>
```

### 3.2. Android (`AndroidManifest.xml`)
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="{{APP_BUNDLE_ID}}">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="{{PROJECT_NAME}}"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:allowBackup="false"
        android:supportsRtl="true">
        <!-- Konfigurasi aktivitas dan layanan latar belakang -->
    </application>
</manifest>
```

---

## 4. Alur Kerja Permintaan Izin Runtime

1. **Penjelasan Kontekstual:** Tampilkan dialog penjelasan internal aplikasi sebelum memicu dialog izin bawaan sistem operasi.
2. **Jangan Blokir Layar Pembuka:** Dilarang meminta izin sensitif (kamera/lokasi) di layar pembuka (*splash screen*) atau awal onboarding, kecuali jika mutlak diperlukan untuk proposisi nilai utama.
3. **Pemulihan Izin Ditolak:** Jika pengguna menolak izin secara permanen ("Jangan tanya lagi"), sediakan tombol yang langsung membuka halaman pengaturan aplikasi di sistem operasi secara elegan.
