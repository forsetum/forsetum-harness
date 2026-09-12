# Documentation Maintenance Guide — {{PROJECT_NAME}}

> Rules for preserving documentation integrity, link validity, and architectural synchronization.

---

## 1. Documentation Change Triggers

Whenever work impacts architecture, conventions, or project variables, the following files MUST be updated:

1. **New Architectural Decision:** Append to [`docs/08-reference/decision-register.md`](file:///docs/08-reference/decision-register.md).
2. **New Substitution Variable:** Register in [`docs/08-reference/template-variables.md`](file:///docs/08-reference/template-variables.md).
3. **Milestone or Task Status:** Update [`backlog.md`](file:///backlog.md).
4. **New Document Added:** Add entry to [`docs/INDEX.md`](file:///docs/INDEX.md).

---

## 2. Link Validity & Markdown Standards

- All relative links must resolve to existing files.
- Avoid broken anchor tags or missing references.
- Always run `./scripts/validate-template.sh` before finalizing changes.
