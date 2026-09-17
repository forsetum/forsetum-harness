# Wireframe & Layout Specifications — {{PROJECT_NAME}}

> Visual hierarchy, structural sections, responsive grid guidelines, and mobile breakpoint specifications.

---

## 1. Page Flow & Section Order

```
[Sticky Header / Navigation Bar]
       │
[Hero Section + Primary CTA]
       │
[Logo Banner / Social Proof Strip]
       │
[Problem vs. Solution Grid]
       │
[Feature Deep-Dives (Alternating 2-column)]
       │
[Customer Testimonials / Reviews Carousel]
       │
[FAQ Accordion]
       │
[Final Call-to-Action Banner]
       │
[Footer with Legal, Links, and Copyright]
```

---

## 2. Responsive Breakpoint Rules

| Breakpoint | Screen Width | Layout Behaviors |
|---|---|---|
| **Mobile (sm)** | `< 640px` | Single column vertical stack, full-width CTA buttons, hamburger menu |
| **Tablet (md)** | `640px – 1023px` | 2-column feature grids, expanded hero padding |
| **Desktop (lg)** | `1024px – 1279px` | Max-width container (1140px), alternating layout columns |
| **Wide (xl)** | `≥ 1280px` | Max-width container (1280px), centered layout with generous whitespace |

---

## 3. Interactive State Guidelines

- **Buttons:** Distinct resting, hover, active, focus-visible, and disabled states.
- **FAQ:** Accessible accordion toggling (`aria-expanded`, smooth height transition).
- **Navigation:** Sticky top bar with blur backdrop filter on scroll.
