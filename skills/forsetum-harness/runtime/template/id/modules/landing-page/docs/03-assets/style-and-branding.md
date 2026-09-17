# Panduan Gaya, Tipografi & Branding — {{PROJECT_NAME}}

> Token desain visual, aturan tipografi, palet warna, dan panduan aset media untuk `{{PROJECT_NAME}}`.

---

## 1. Hierarki Tipografi

- **Font Utama:** System font stack atau Google Fonts modern (*Plus Jakarta Sans*, *Inter*, atau *Outfit*).
- **Skala Ukuran:**
  - `Hero Display (H1)`: `40px` (mobile) / `56px–64px` (desktop), Line height: `1.1`, Weight: `700/800`.
  - `Section Headline (H2)`: `28px` (mobile) / `36px–40px` (desktop), Line height: `1.2`, Weight: `700`.
  - `Sub-headline (H3)`: `20px` (mobile) / `24px` (desktop), Line height: `1.3`, Weight: `600`.
  - `Teks Bodi Utama`: `16px`, Line height: `1.6`, Weight: `400`.
  - `Mikro / Teks Badge`: `12px–14px`, Line height: `1.4`, Weight: `500/600`.

---

## 2. Sistem Warna & Token Desain

| Token | Peran | Rekomendasi Palet HSL / Hex |
|---|---|---|
| `color-primary` | Identitas Brand & CTA Utama | Indigo/Violet modern cerah atau Emerald |
| `color-primary-hover` | Efek hover tombol CTA | 10% lebih gelap dari primary |
| `color-surface` | Latar Belakang Halaman | Putih bersih atau dark mode elegan (`#0B0F19`) |
| `color-card` | Permukaan Kartu Kontainer | Sedikit elevasi dengan border halus (`rgba(255,255,255,0.05)` atau `#F9FAFB`) |
| `color-text-main` | Teks Bodi Utama | Kontras tinggi netral (`#111827` terang / `#F3F4F6` gelap) |
| `color-text-muted` | Sub-judul & Teks Sekunder | Kontras menengah (`#4B5563` terang / `#9CA3AF` gelap) |

---

## 3. Aturan Aset Visual & Media

- **Gambar:** Aset WebP/SVG beresolusi tinggi. Dilarang menggunakan placeholder gambar generik/buram.
- **Ikon:** Set ikon SVG modern (Lucide, Heroicons, atau Feather).
- **Gambar OpenGraph:** Gambar kartu pratinjau media sosial ukuran 1200x630px pada `/public/og-image.png`.
