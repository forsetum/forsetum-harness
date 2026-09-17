# Panduan Deployment, SEO & Analitik — {{PROJECT_NAME}}

> Spesifikasi deployment hosting statis (`{{HOSTING_TARGET}}`), perutean domain kustom, tag meta SEO, dan pelacakan analitik.

---

## 1. Target Hosting & Konfigurasi Build

- **Platform Target:** `{{HOSTING_TARGET}}` (misal: Vercel, Cloudflare Pages, Netlify, GitHub Pages)
- **Direktori Output:** `dist/` atau `out/` (berkas statis bersih yang memuat `index.html`, CSS, dan JS)
- **Zero Server Overhead:** Seluruh fungsionalitas berjalan sebagai aset statis murni atau interaksi sisi klien (client-side).

---

## 2. Standar SEO & Metadata

Setiap halaman landing page wajib mendeklarasikan:
```html
<title>{{PROJECT_NAME}} — {{PRIMARY_CTA}}</title>
<meta name="description" content="{{PROJECT_MISSION}}" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta property="og:title" content="{{PROJECT_NAME}}" />
<meta property="og:description" content="{{PROJECT_MISSION}}" />
<meta property="og:type" content="website" />
<meta property="og:image" content="/og-image.png" />
<meta name="twitter:card" content="summary_large_image" />
<link rel="icon" href="/favicon.ico" />
```

---

## 3. Analitik & Pelacakan Konversi

1. **Analitik Ramah Privasi:** Integrasikan Plausible, Umami, atau Google Analytics 4.
2. **Event Konversi Utama:**
   - `cta_primary_click`: Dipicu saat pengguna mengklik `{{PRIMARY_CTA}}`.
   - `faq_expand`: Melacak minat pada pertanyaan seputar harga atau fitur spesifik.
   - `scroll_depth_75`: Melacak keterbacaan hingga bagian testimoni pelanggan.
