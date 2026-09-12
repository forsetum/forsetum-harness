# Spesifikasi Wireframe & Tata Letak — {{PROJECT_NAME}}

> Hierarki visual, bagian-bagian struktural halaman, panduan grid responsif, dan spesifikasi breakpoint perangkat mobile.

---

## 1. Alur Halaman & Urutan Bagian (Sections)

```
[Sticky Header / Navigasi Atas]
               │
[Bagian Hero + CTA Utama]
               │
[Banner Logo / Bukti Sosial]
               │
[Grid Masalah vs Solusi]
               │
[Eksplorasi Fitur (Kolom Bergantian)]
               │
[Testimoni Pelanggan / Ulasan]
               │
[Akordeon FAQ]
               │
[Banner Aksi Penutup (Final CTA)]
               │
[Footer: Legal, Tautan, dan Hak Cipta]
```

---

## 2. Aturan Responsivitas Breakpoint

| Breakpoint | Lebar Layar | Perilaku Tata Letak |
|---|---|---|
| **Mobile (sm)** | `< 640px` | Tumpukan vertikal satu kolom, tombol CTA lebar penuh (full-width), menu hamburger |
| **Tablet (md)** | `640px – 1023px` | Grid fitur 2-kolom, padding hero diperluas |
| **Desktop (lg)** | `1024px – 1279px` | Kontainer lebar maksimal (1140px), kolom fitur bergantian kiri-kanan |
| **Wide (xl)** | `≥ 1280px` | Kontainer lebar maksimal (1280px), tata letak terpusat dengan whitespace lega |

---

## 3. Panduan Status Interaktif (Interactive States)

- **Tombol (Buttons):** Status istirahat (*resting*), sorot (*hover*), ditekan (*active*), fokus aksesibilitas (*focus-visible*), dan dinonaktifkan (*disabled*) yang jelas.
- **FAQ:** Akordeon interaktif yang ramah aksesibilitas (`aria-expanded`, transisi tinggi yang mulus).
- **Navigasi:** Navigasi atas melayang (*sticky*) dengan efek blur kaca (*backdrop filter*) saat halaman digulir.
