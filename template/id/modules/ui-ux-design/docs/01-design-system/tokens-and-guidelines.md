# Panduan Design System & Handoff Desain — {{PROJECT_NAME}}

> Dokumen kanonikal panduan design system, spesifikasi design tokens, wireframe hierarkis, dan protokol handoff developer untuk `{{PROJECT_NAME}}`.

---

## 1. Parameter Fondasi Desain

| Parameter | Nilai Instansiasi |
|---|---|
| **Alat Desain Utama** | `{{DESIGN_TOOL}}` |
| **Framework Token Desain** | `{{DESIGN_SYSTEM_FRAMEWORK}}` |
| **Prioritas Form Factor Layar** | `{{TARGET_DEVICES}}` |
| **Format Dokumentasi Handoff** | `{{HANDOFF_SPEC_FORMAT}}` |
| **Pemilik Keputusan Desain** | `{{DECISION_OWNER}}` |
| **Misi Produk** | `{{PROJECT_MISSION}}` |

---

## 2. Fondasi Token Desain (Design Tokens)

1. **Palet Warna & Kontras:**
   - Background dominan gelap (*Sleek Dark Mode*) dan panel kaca (*Glassmorphism*).
   - Aksentuasi kontras tinggi sesuai standar aksesibilitas WCAG 2.1 AA (rasio kontras minimal 4.5:1).
2. **Tipografi Modern:**
   - Heading: Sans-serif modern (e.g. Outfit / Inter Display).
   - Body: Clean variable sans-serif (e.g. Inter / Geist).
   - Monospace: Code & technical metrics (e.g. JetBrains Mono).
3. **Spacing & Radii:**
   - Skala 4px / 8px grid modular (`p-2`, `p-4`, `p-6`, `p-8`).
   - Radius sudut konsisten: `rounded-xl` (12px) dan `rounded-2xl` (16px).

---

## 3. Protokol Handoff Developer (Zero-Friction Handoff)

- [ ] Seluruh komponen memiliki penamaan layer terstandar (*Component / Variant / State*).
- [ ] Dokumentasi state interaktif lengkap: *Default, Hover, Active, Focus-Visible, Disabled, Loading*.
- [ ] Export aset ikon dan ilustrasi dalam format SVG bersih teroptimasi (*optimized vectors*).
- [ ] Konvensi token warna disinkronkan langsung dengan konfigurasi CSS / Tailwind proyek.
