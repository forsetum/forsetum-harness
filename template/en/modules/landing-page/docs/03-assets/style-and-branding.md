# Style, Typography & Branding Guide — {{PROJECT_NAME}}

> Visual design tokens, typography rules, color palettes, and asset guidelines for `{{PROJECT_NAME}}`.

---

## 1. Typography Hierarchy

- **Primary Font Family:** System font stack or Google Fonts (e.g., *Inter*, *Plus Jakarta Sans*, or *Outfit*).
- **Scale:**
  - `Hero Display (H1)`: `40px` (mobile) / `56px–64px` (desktop), Line height: `1.1`, Weight: `700/800`.
  - `Section Headline (H2)`: `28px` (mobile) / `36px–40px` (desktop), Line height: `1.2`, Weight: `700`.
  - `Sub-headline (H3)`: `20px` (mobile) / `24px` (desktop), Line height: `1.3`, Weight: `600`.
  - `Body Regular`: `16px`, Line height: `1.6`, Weight: `400`.
  - `Micro / Badge Copy`: `12px–14px`, Line height: `1.4`, Weight: `500/600`.

---

## 2. Color System & Design Tokens

| Token | Role | Recommended HSL / Hex Palette |
|---|---|---|
| `color-primary` | Brand Identity & Primary CTA | Modern Vibrant Indigo/Violet or Emerald |
| `color-primary-hover` | Hover state for CTA | 10% darker than primary |
| `color-surface` | Page Background | Pure white or sleek dark mode (`#0B0F19`) |
| `color-card` | Container Card Surface | Slight elevation with subtle border (`rgba(255,255,255,0.05)` or `#F9FAFB`) |
| `color-text-main` | Primary Body Text | High-contrast neutral (`#111827` light / `#F3F4F6` dark) |
| `color-text-muted` | Sub-headlines & Meta | Mid-contrast neutral (`#4B5563` light / `#9CA3AF` dark) |

---

## 3. Visual Assets & Media Rules

- **Imagery:** High-resolution WebP/SVG assets. No generic stock placeholders.
- **Icons:** Modern SVG icon set (Lucide, Heroicons, or Feather).
- **OpenGraph Image:** 1200x630px social share card image in `/public/og-image.png`.
