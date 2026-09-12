# Deployment, SEO & Analytics Guide — {{PROJECT_NAME}}

> Specifications for static hosting deployment (`{{HOSTING_TARGET}}`), custom domain routing, SEO meta tags, and analytics tracking.

---

## 1. Hosting Target & Build Configuration

- **Target Platform:** `{{HOSTING_TARGET}}` (e.g., Vercel, Cloudflare Pages, Netlify, GitHub Pages)
- **Output Directory:** `dist/` or `out/` (clean static bundle containing `index.html`, CSS, and JS)
- **Zero Server Overhead:** All functionality runs as static assets or client-side interactions.

---

## 2. SEO & Metadata Standards

Every landing page page must declare:
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

## 3. Analytics & Conversion Tracking

1. **Privacy-Respecting Analytics:** Integrate Plausible, Umami, or Google Analytics 4.
2. **Key Conversion Events:**
   - `cta_primary_click`: Triggered when user clicks `{{PRIMARY_CTA}}`.
   - `faq_expand`: Track interest in specific pricing/product questions.
   - `scroll_depth_75`: Track engagement down to the testimonials section.
