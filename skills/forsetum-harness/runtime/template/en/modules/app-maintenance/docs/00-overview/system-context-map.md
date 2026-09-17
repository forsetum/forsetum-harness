# Existing System Context & Code Boundaries — {{PROJECT_NAME}}

## 1. Host Application Context

This document defines the architectural boundaries between the host/upstream application and code modifications authored in this project.

- Host application: `{{HOST_APPLICATION}}`
- Source code model: `{{SOURCE_MODEL}}`
- Primary programming language: `{{PRIMARY_LANGUAGE}}`
- Permitted extension pattern: `{{EXTENSION_PATTERN}}`

## 2. Code Zoning: Permitted vs Restricted Areas

To prevent unexpected regressions and preserve platform maintainability, agents and developers must adhere to strict code zoning:

| Zone | Directory / Component | Access Policy | Modification Rules |
|---|---|---|---|
| **Red Zone (No-Touch Core)** | Core framework files, default migrations, upstream libraries | READ-ONLY | Directly editing vendor/upstream core files is strictly prohibited. |
| **Yellow Zone (Patch Window)** | Targeted bug fixes on upstream functionality | RESTRICTED (*Surgical Patch*) | Permitted only via isolated `.patch` files or modular class overrides. |
| **Green Zone (Custom Modules)** | Custom plugin/extension directory (`/custom-addons`, `/plugins`) | OPEN (*Isolated Dev*) | Authorized area for new domain logic, schema extensions, and custom APIs. |

## 3. Dependency & Integration Boundaries

- **Database Schemas:** All new tables or custom fields must use dedicated prefixes (e.g. `x_` or `custom_`) to avoid collisions during upstream schema upgrades.
- **Event & Signal Listeners:** Functional integrations must prefer standard *Observer / Event Hook / Signal Listener* interfaces exposed by `{{HOST_APPLICATION}}`.
