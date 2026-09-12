# Template Variable Registry (app-maintenance Module) — {{PROJECT_NAME}}

This registry defines configuration variables specific to the Application Maintenance & Brownfield Engineering (`app-maintenance`) module:

## 1. Module Variables

| Variable | Required? | Template Value | Purpose |
|---|---:|---|---|
| `HOST_APPLICATION` | Yes | `{{HOST_APPLICATION}}` | Host/upstream application name and version (e.g. Odoo 17, WordPress, Legacy ERP) |
| `SOURCE_MODEL` | Yes | `{{SOURCE_MODEL}}` | Code source model (e.g. Open Source Upstream, Closed Source Vendor) |
| `PRIMARY_LANGUAGE` | Yes | `{{PRIMARY_LANGUAGE}}` | Core programming language of the module/application |
| `EXTENSION_PATTERN` | Yes | `{{EXTENSION_PATTERN}}` | Permitted extension pattern (e.g. Modular Plugin, Event Hook/Listener, Core Patch) |

## 2. Module Placeholder Index

```text
EXTENSION_PATTERN
HOST_APPLICATION
PRIMARY_LANGUAGE
SOURCE_MODEL
```
