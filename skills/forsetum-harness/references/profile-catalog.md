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
| `procurement-tender` | `governance` | Structured harness for tender governance, technical specifications, bid proposals & BOQ, vendor evaluation, contracts, and handover certificates. |
| `hr-people-ops` | `operations` | Structured harness for end-to-end employee lifecycle management spanning recruitment, onboarding, performance reviews, and offboarding. |
| `education-training` | `operations` | Structured harness for curriculum design, modular syllabus authoring, training session delivery, and participant learning assessment. |
| `supply-chain-logistics` | `operations` | Operational harness for supply chain workflows, warehouse inventory control, freight dispatch, and return merchandise handling. |
| `event-project-mgmt` | `operations` | Structured harness for planning and executing non-technical corporate projects or events with stakeholder mapping, timelines, budgets, and risk mitigation. |
| `ui-ux-design` | `tech` | Transform concept briefs into standard design tokens, responsive wireframe hierarchies, user research protocols, and seamless developer handoff specs. |
| `content-creator` | `growth` | Viral content engine: structured video scriptwriting, 3-second hook formulas, scene storyboards, multi-channel editorial calendars, and audience retention playbooks. |
| `digital-advertising` | `growth` | High-conversion advertising architecture: compelling ad copy formulas, competitor angle research, Meta/Google ad set structuring, and target ROAS modeling. |
| `academic-education` | `operations` | Scholarly research and teaching framework: course syllabus (RPS) drafting, structured literature reviews, academic rubrics, and research ethics protocols. |
| `health-medical` | `governance` | Healthcare compliance & clinical operations: Electronic Medical Records (EMR) documentation standards, patient education sheets, clinic QA, and health data privacy safeguards. |
| `construction-civil` | `operations` | Civil project execution control: technical specifications (RKS), Bill of Quantities (BoQ), subcontractor management, S-Curve scheduling, and construction HSE inspections. |
| `manufacturing-hse` | `governance` | Zero accident & plant efficiency harness: Job Safety Analysis (JSA), HSE hazard mitigation, 5S audit checklists, OEE tracking, and preventive maintenance routines. |
| `culinary-fnb` | `operations` | Kitchen profitability & taste consistency: Food Cost and COGS calculation, standardized batch recipe sheets, HACCP kitchen hygiene SOPs, and daily waste control. |
| `agribusiness-farming` | `operations` | Precision crop and harvest management: irrigation & fertilizer schedules, feed formulation for livestock, unit crop cost accounting, and cold-chain post-harvest storage. |
| `sme-business` | `growth` | Small business & retail accelerator: customer fast-reply chat playbooks, COGS margin pricing calculators, daily cash register logs, and recurring promo broadcast campaigns. |
| `business-growth` | `growth` | Founder-level management harness for positioning, productized services, repeatable acquisition, recurring value, retention, capacity, and growth measurement. |

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
