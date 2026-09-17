# Governance Profile Catalog

The canonical profile IDs are the keys of `template/en/manifest.json` and
`template/id/manifest.json`. Both manifests must expose the same IDs. The
manifest remains the source of truth for names, descriptions, variables,
readiness checks, and module directories; this catalog only provides routing
signals for the adoption conversation.

| Stable profile ID | Category | Use when repository signals indicate |
| --- | --- | --- |
| `web-fullstack` | `tech` | A database-backed web application, service, or API |
| `landing-page` | `tech` | A marketing landing page or responsive static site |
| `sales-outreach` | `growth` | A B2B outreach campaign, lead pipeline, or deal workflow |
| `general-office` | `operations` | Office operations, recurring reporting, or procedural work |
| `mobile-app` | `tech` | A native or cross-platform mobile application |
| `cli-automation` | `tech` | A command-line tool, scheduled job, daemon, or data script |
| `content-marketing` | `growth` | Editorial planning, SEO content, or multi-channel publishing |
| `research-analysis` | `operations` | Industry research, benchmarking, or decision analysis |
| `web-starter` | `tech` | A lightweight MVP, prototype, or beginner web project |
| `it-infra-ops` | `operations` | On-premises infrastructure maintenance or incident runbooks |
| `app-maintenance` | `tech` | Existing-system bug fixing or isolated brownfield extensions |

## Selection Rules

- Read both manifests before presenting a profile list and verify that the
  candidate ID exists in the selected language manifest.
- Recommend exactly one profile when signals are sufficient; show the signals
  supporting the recommendation.
- If signals support multiple profiles, present the candidates and ask the
  user to choose; do not silently select among materially different domains.
- If signals are insufficient, ask one focused question with two or three
  concrete profile choices drawn from this catalog.
- The selected profile ID must be copied unchanged into the preview and the
  canonical initializer command.
- A profile recommendation never authorizes file mutation; the conflict and
  explicit-decision gates in `adoption-contract.md` still apply.

## Manifest Parity Check

Before relying on this catalog, compare the module key sets from both
manifests. If they differ, stop and report the parity failure instead of
inventing a translated or fallback profile ID.
