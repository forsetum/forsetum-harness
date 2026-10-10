# Existing System Context & Code Boundaries — {{PROJECT_NAME}}

## 1. Host Application Context

This document defines the architectural boundaries between the host/upstream application and code modifications authored in this project.

- Host application: `{{HOST_APPLICATION}}`
- Source code model: `{{SOURCE_MODEL}}`
- Primary programming language: `{{PRIMARY_LANGUAGE}}`
- Permitted extension pattern: `{{EXTENSION_PATTERN}}`

The target's existing code, configuration, data, behavior, and existing
documented behavior are the factual baseline for this brownfield system.
Forsetum templates and tools guide decisions but do not define target facts;
establish the current system from evidence in the actual project. Any exception
or intended departure from this baseline is a human decision. An `OPEN` or
technically writable zone describes a technical boundary, not permission to
change it.

## 2. Code Zoning: Technical Boundaries

These zones define technical boundaries, not authorization. Obtain human approval unless an explicit, bounded `FULL_ALLOW` covers the routine, non-destructive change; destructive changes always require action-specific human approval. To prevent unexpected regressions and preserve platform maintainability, agents and developers must adhere to strict code zoning:

| Zone | Directory / Component | Technical Boundary | Modification Rules |
|---|---|---|---|
| **Red Zone (No-Touch Core)** | Core framework files, default migrations, upstream libraries | READ-ONLY | Directly editing vendor/upstream core files is strictly prohibited. |
| **Yellow Zone (Patch Window)** | Targeted bug fixes on upstream functionality | RESTRICTED (*Surgical Patch*) | Permitted only via isolated `.patch` files or modular class overrides. |
| **Green Zone (Custom Modules)** | Custom plugin/extension directory (`/custom-addons`, `/plugins`) | OPEN (*Isolated Dev*) | Technically suitable for new domain logic, schema extensions, and custom APIs; changes still require applicable approval. |

## 3. Dependency & Integration Boundaries

- **Database Schemas:** All new tables or custom fields must use dedicated prefixes (e.g. `x_` or `custom_`) to avoid collisions during upstream schema upgrades.
- **Event & Signal Listeners:** Functional integrations must prefer standard *Observer / Event Hook / Signal Listener* interfaces exposed by `{{HOST_APPLICATION}}`.
