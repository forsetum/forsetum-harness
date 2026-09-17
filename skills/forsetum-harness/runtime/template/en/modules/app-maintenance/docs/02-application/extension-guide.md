# Custom Module Development Guide — {{PROJECT_NAME}}

## 1. Module Isolation Principles

All extension development for `{{HOST_APPLICATION}}` must adhere to pattern: `{{EXTENSION_PATTERN}}`.
Primary programming language: `{{PRIMARY_LANGUAGE}}`.

Key Principles:
1. **Zero Core Pollution:** Do not edit files outside the designated custom module directory.
2. **Backward Compatibility:** Data model changes must never delete or retype default columns in `{{HOST_APPLICATION}}`.
3. **Pluggable & Decoupled:** Custom modules must be cleanly installable and uninstallable without leaving orphan artifacts that destabilize the host application.

## 2. Standard Directory Layout for Custom Modules

Custom modules should be organized following standard conventions:
```text
custom_module_name/
├── manifest/config file      # Module metadata, dependencies, and hook declarations
├── models/                   # Additional data model definitions (with custom prefix)
├── views/ / templates/       # UI extensions or template overrides
├── controllers/ / api/       # Custom API handlers and routes
└── tests/                    # Unit tests and non-regression test suites
```

## 3. Database Schema Extension Guidelines

- **Adding New Columns:** New columns added to existing host tables must be optional (`nullable`) or carry safe defaults to avoid breaking upstream queries.
- **New Tables:** Custom table names must use module-specific prefixes to prevent future migration collisions.
