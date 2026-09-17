# Application Implementation Guide — {{PROJECT_NAME}}

> Practical implementation guidelines, directory organization, and component patterns for {{PROJECT_NAME}}.

---

## 1. Directory Structure

Recommended application project layout:

```text
src/
├── app/                  # Routes, pages, and layout definitions
│   ├── layout.tsx        # Global shell, navigation, and footer
│   ├── page.tsx          # Homepage / landing view
│   └── api/              # Backend endpoint handlers
├── components/           # Reusable UI components (buttons, modals, inputs)
├── lib/                  # Database client, utility functions, and helpers
└── styles/               # Global CSS styles and design tokens
```

---

## 2. Core Pages and Views

| View Name | Route | Purpose | Key Components |
|---|---|---|---|
| **Home / Landing** | `/` | Welcomes visitors and explains value proposition | Hero, FeatureGrid, ActionButton |
| **App Dashboard** | `/dashboard` | Primary user interface and workflow execution | ItemList, CreateForm, StatusBadge |
| **Settings / Profile**| `/settings` | User preferences and configuration | SettingsForm, ToastFeedback |

---

## 3. Data Fetching and State Flow

1. **Client-to-Server**: Forms submit data via standard POST requests or JSON payloads.
2. **Server-Side Validation**: Validate all incoming parameters before writing to `{{PERSISTENCE_STRATEGY}}`.
3. **Response Structure**: Return consistent JSON responses with clear success indicators and error messages:

```json
{
  "success": true,
  "data": { "id": "123", "name": "Example" },
  "message": "Resource created successfully"
}
```
