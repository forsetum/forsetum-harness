# Design System & Developer Handoff Guidelines — {{PROJECT_NAME}}

> Canonical design system reference, design tokens specification, screen wireframes, and developer handoff protocol for `{{PROJECT_NAME}}`.

---

## 1. Design Foundation Parameters

| Parameter | Instantiation Value |
|---|---|
| **Primary Design Tool** | `{{DESIGN_TOOL}}` |
| **Design Token Framework** | `{{DESIGN_SYSTEM_FRAMEWORK}}` |
| **Priority Screen Form Factor** | `{{TARGET_DEVICES}}` |
| **Handoff Documentation Format** | `{{HANDOFF_SPEC_FORMAT}}` |
| **Design Decision Owner** | `{{DECISION_OWNER}}` |
| **Product Mission** | `{{PROJECT_MISSION}}` |

---

## 2. Design Token Foundations

1. **Color Palette & Contrast:**
   - Sleek dark theme default with subtle glassmorphism panels.
   - High-contrast accents satisfying WCAG 2.1 AA accessibility ratios (minimum 4.5:1).
2. **Modern Typography:**
   - Heading: Modern sans-serif (e.g., Outfit / Inter Display).
   - Body: Clean variable sans-serif (e.g., Inter / Geist).
   - Monospace: Technical metrics & code symbols (e.g., JetBrains Mono).
3. **Spacing & Radii:**
   - 4px / 8px modular spacing scale (`p-2`, `p-4`, `p-6`, `p-8`).
   - Standardized border radii: `rounded-xl` (12px) and `rounded-2xl` (16px).

---

## 3. Developer Handoff Protocol

- [ ] All components follow standardized naming conventions (*Component / Variant / State*).
- [ ] Complete interactive state documentation: *Default, Hover, Active, Focus-Visible, Disabled, Loading*.
- [ ] Clean SVG icon exports with stroke alignment and no extraneous metadata.
- [ ] Direct token mapping to project Tailwind / CSS variables.
