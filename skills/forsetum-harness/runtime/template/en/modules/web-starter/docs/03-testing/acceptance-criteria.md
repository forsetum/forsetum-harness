# Functional Acceptance Criteria & Quality Checklist — {{PROJECT_NAME}}

> Verification criteria and testing gates before shipping {{PROJECT_NAME}}.

---

## 1. Functional Acceptance Checklist

| Item | Requirement | Verification Method | Status |
|---|---|---|---|
| **App Boot** | Application compiles and starts locally without errors | Run dev server script (`npm run dev` or equivalent) | [ ] |
| **Page Navigation** | All primary routes (`/`, `/dashboard`, `/settings`) render correctly | Manual clickthrough in browser | [ ] |
| **Form Submission** | User input submits successfully and displays feedback | Test form with valid and invalid inputs | [ ] |
| **Data Persistence** | Saved records persist across server restarts | Create record, restart dev server, verify record exists | [ ] |
| **Mobile Responsiveness** | UI renders without horizontal scroll on mobile viewport (< 480px) | Browser DevTools device emulation | [ ] |

---

## 2. Code Quality Gates

- [ ] **No Console Errors**: DevTools console is free of uncaught exceptions and React key warnings.
- [ ] **Clean Linting**: Lint tool runs with 0 errors and 0 critical warnings.
- [ ] **Environment Isolation**: Secrets and configuration stored in environment variables, never hardcoded.
- [ ] **Documentation Parity**: New routes or schema changes reflected in `docs/`.
