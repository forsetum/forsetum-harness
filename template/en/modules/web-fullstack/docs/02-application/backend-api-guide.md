# Backend & API Guide — {{PROJECT_NAME}}

## 1. Applicability

Use this document if the project exposes an HTTP API, RPC interface, event contract, CLI boundary, or public service interface. If irrelevant, record `Not Applicable` in the Decision Register and README.

## 2. Layer Boundaries

- Interface / router / controller: `{{ROUTER_PATH}}`
- Business logic / service: `{{SERVICE_PATH}}`
- Schema / DTO / contract: `{{SCHEMA_PATH}}`
- Data access / model: `{{MODEL_PATH}}`

## 3. Interface Change Checklist

- [ ] Impacted Requirement IDs identified.
- [ ] Request/event input and response/output formats documented.
- [ ] Validation, authorization, error status codes, and error shapes remain consistent.
- [ ] Backward compatibility and API versioning strategies evaluated.
- [ ] Idempotency, concurrency controls, and retry behaviors defined where relevant.
- [ ] Audit trails added only when required by domain or regulatory rules.
- [ ] Relevant unit, integration, contract, and end-to-end tests updated.
- [ ] Flow, architecture, security, and acceptance criteria documents synchronized.

## 4. Definition of Done

- Core happy path and failure path scenarios tested.
- Interface contracts do not change without formal documented updates.
- No sensitive data leaks through API responses or logs.
- Interfaces remain backward compatible or provide clear migration paths.
