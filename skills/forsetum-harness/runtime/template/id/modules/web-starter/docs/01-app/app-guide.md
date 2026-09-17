# Panduan Implementasi Aplikasi — {{PROJECT_NAME}}

> Petunjuk implementasi praktis, pengorganisasian direktori, dan pola komponen untuk {{PROJECT_NAME}}.

---

## 1. Struktur Direktori

Rekomendasi tata letak folder proyek aplikasi:

```text
src/
├── app/                  # Rute, halaman, dan definisi layout
│   ├── layout.tsx        # Shell global, navigasi, dan footer
│   ├── page.tsx          # Tampilan beranda / landing
│   └── api/              # Penangan endpoint backend
├── components/           # Komponen UI modular (tombol, modal, form input)
├── lib/                  # Klien basis data, fungsi utilitas, dan helper
└── styles/               # File CSS global dan token desain visual
```

---

## 2. Halaman dan Tampilan Utama

| Nama Tampilan | Rute | Tujuan | Komponen Kunci |
|---|---|---|---|
| **Beranda / Landing** | `/` | Menyambut pengunjung dan menjelaskan proposisi nilai | Hero, FeatureGrid, ActionButton |
| **Dashboard Aplikasi**| `/dashboard` | Antarmuka pengguna utama dan eksekusi alur kerja | ItemList, CreateForm, StatusBadge |
| **Pengaturan / Profil**| `/settings` | Konfigurasi akun dan preferensi pengguna | SettingsForm, ToastFeedback |

---

## 3. Alur Pengambilan Data & State

1. **Klien ke Server**: Formulir mengirimkan data melalui form POST standar atau muatan JSON.
2. **Validasi Sisi Server**: Validasi semua parameter masukan sebelum disimpan ke `{{PERSISTENCE_STRATEGY}}`.
3. **Format Respons**: Kembalikan respons JSON seragam dengan indikator status dan pesan yang jelas:

```json
{
  "success": true,
  "data": { "id": "123", "name": "Contoh" },
  "message": "Data berhasil disimpan"
}
```
